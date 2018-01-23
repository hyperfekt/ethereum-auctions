pragma solidity ^0.4.18;

import "./EIP179/ERC179Interface.sol";
import "./EIP721+821/NFTRegistry.sol";
import "./EIP20/ERC20Interface.sol";
import "./EIP820/EIP820.sol";
import "./EIP777/ITokenRecipient.sol";
import "./EIP777/EIP777.sol";
import "./EIP821/IAssetHolder.sol";

contract Auction is EIP820, ITokenRecipient, IAssetHolder {

    struct AuctionStatus {
        uint40 endBlock;
        uint40 auctionEnd; //absolute unix timestamp, note that a miner could choose the timestamp to be different from realtime and thus enter bids slightly after this moment. An extension of the auction end by >0 blocks will make that irrelevant.
        uint32 endExtension; // note that miners can choose to exclude transactions and insert their own, meaning that they can could limit the price and place winning bids by colluding with this many successive other miners.
        uint80 fixedIncrement;
        uint24 fractionalIncrement;
        bool started;
        bool selfInitiatedTransfer;
    }

    address public beneficiary;
    
    mapping(address => uint256) public pendingReturns;
    AuctionStatus public status;
    bool public finalized;
    bool public bidReceived;
    
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionFinalized(address winner, uint winningBid);
    event AuctionAborted();

    function Auction(
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public
    {
        status.auctionEnd = _endTime;
        status.endExtension = _extendBlocks;
        status.fixedIncrement = _fixedIncrement;
        status.fractionalIncrement = _fractionalIncrement;
        beneficiary = msg.sender;

        setInterfaceImplementation("ITokenRecipient", this);
    }

    function registerBid(address source, uint256 amount) internal {
        uint256 newbid;
        if (source == highestBidder()) {
            newbid = highestBid() + amount;
        } else {
            uint256 unreturned = pendingReturns[source];
            newbid = unreturned + amount;

            pendingReturns[source] = 0;
            pendingReturns[highestBidder()] = highestBid();
        }
        require(validBid(newbid));
        newHighestBid(source, newbid);
    }

    function newHighestBid(address bidder, uint256 amount) internal {
        setHighestBid(bidder, amount);
        status.endBlock = uint40(block.number) + status.endExtension;
        HighestBidIncreased(bidder, amount);
    }

    function validBid(uint256 amount) public view returns (bool) {
        return amount >= highestBid() + currentIncrement() && amount > highestBid() && status.started && !ended();
    }

    function currentIncrement() public view returns (uint256) {
        if (status.fractionalIncrement == 0) {
            return status.fixedIncrement;
        } else {
            return max(status.fixedIncrement, highestBid() / status.fractionalIncrement);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }

     /// Withdraw your outbid balance from the auction.
    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        pendingReturns[msg.sender] = 0;


        untrustedTransferBid(msg.sender, amount);
    }

    /// Get your current bid in the auction.
    function currentBid() external view returns (uint256) {
        if (msg.sender == highestBidder()) {
            return highestBid();
        } else {
            return pendingReturns[msg.sender];
        }
    }

    /// Transfer the winning bid to the beneficiary.
    function receiveBid() external {
        require(msg.sender == beneficiary);
        require(ended());
        require(!bidReceived);


        finalize();
        
        bidReceived = true;


        untrustedTransferBid(beneficiary, highestBid());
    }

    /// Transfer the won item to the highest bidder.
    function receiveItem() external {
        require(msg.sender == highestBidder());
        require(ended());

        
        finalize();


        untrustedTransferItem(highestBidder());
    }

    function finalize() internal {
        if (!finalized) {
            finalized = true;
            AuctionFinalized(highestBidder(), highestBid());
        }
    }

    function ended() public view returns (bool) {
        return block.timestamp > status.auctionEnd && block.number > status.endBlock;
    }
    
    function start() external {
        require(msg.sender == beneficiary);
        require(funded());
        require(!status.started);


        status.started = true;
        logStart();
    }
    

    /// Abort the auction.
    function abort() external {
        require(msg.sender == beneficiary);
        require(status.started && highestBid() == 0);
        
        
        status.started = false;
        AuctionAborted();
    }

    function emptyToken(address token, uint asset) external {
        require(msg.sender == beneficiary);

        if (untrustedEmptyBid(beneficiary, token)) {
            if (untrustedTransferExcessAuctioned(beneficiary, token, asset)) {
                if (token == 0) {
                    beneficiary.transfer(this.balance);
                } else if (asset == 0) {
                    require(ERC179Interface(token).transfer(beneficiary, ERC179Interface(token).balanceOf(this)));
                } else {
                    NFTRegistry(token).transfer(beneficiary, asset);
                }
            }
        }
    }

    function untrustedEmptyBid(address receiver, address token) internal  returns (bool notBid) {
        if (ERC20Interface(token) == bidToken()) {
            if (!status.started) {
                untrustedTransferBid(receiver, bidBalance());
            }
            return false;
        } else {
            return true;
        }
    }

    function onAssetReceived(uint256, address, address, bytes, address, bytes) public {
        require(false);
    }

    function tokensReceived(address from, address to, uint amount, bytes, address, bytes) public {
        require(Auction(to) == this);

        if (status.started) {
            require(incomingBid(EIP777(msg.sender), from, amount));
        } else {
            require(from == beneficiary);
            require(incomingFunds(EIP777(msg.sender), amount));
        }
    }

    function incomingBid(EIP777 token, address source, uint amount) internal returns (bool accepted) {
        if (token == EIP777(bidToken())) {
            if (!status.selfInitiatedTransfer) {
                registerBid(source, amount);
            }
            return true;
        } else {
            return false;
        }
    }

    function incomingFunds(EIP777, uint) internal returns (bool accepted) {
        return false;
    }

    function bidToken() internal view returns (ERC20Interface);

    function bidBalance() internal view returns (uint);

    function untrustedTransferExcessAuctioned(address receiver, address token, uint asset) internal returns (bool notAuctioned);

    function setHighestBid(address bidder, uint256 amount) internal;

    function highestBidder() public view returns (address);

    function highestBid() public view returns (uint256);

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) internal;

    // Transfers the auctioned item.
    function untrustedTransferItem(address receiver) internal;

    // Checks the auction contract possesses the auctioned item.
    function funded() public view returns (bool);

    // Logs the start of the auction to the chain via AuctionStarted.
    function logStart() internal;

}
