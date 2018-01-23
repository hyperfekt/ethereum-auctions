pragma solidity ^0.4.18;

import "./IAuctionStatus.sol";
import "./IBid.sol";
import "./interfaces/EIP179/ERC179Interface.sol";
import "./interfaces/EIP721+821/NFTRegistry.sol";
import "./interfaces/EIP20/ERC20Interface.sol";
import "./interfaces/EIP820/EIP820.sol";
import "./interfaces/EIP777/ITokenRecipient.sol";
import "./interfaces/EIP777/EIP777.sol";
import "./interfaces/EIP821/IAssetHolder.sol";

contract Auction is IAuctionStatus, IBid, EIP820, ITokenRecipient, IAssetHolder {

    uint public reservePrice;
    address public beneficiary;
    
    mapping(address => uint256) public pendingReturns;
    bool public finalized;
    
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionFinalized(address winner, uint winningBid);
    event AuctionAborted();

    function Auction(
        uint40 _endTime,
        uint32 _extendBlocks,
        uint256 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint256 _reservePrice
    ) public
    {
        setAuctionEnd(_endTime);
        setEndExtension(_extendBlocks);
        setFixedIncrement(_fixedIncrement);
        setFractionalIncrement(_fractionalIncrement);
        reservePrice = _reservePrice;
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
        setEndBlock(uint40(block.number) + endExtension());
        HighestBidIncreased(bidder, amount);
    }

    function validBid(uint256 amount) public view returns (bool) {
        return amount >= highestBid() + currentIncrement() && amount > highestBid() && started() && !ended();
    }

    function currentIncrement() public view returns (uint256) {
        if (fractionalIncrement() == 0) {
            return fixedIncrement();
        } else {
            return max(fixedIncrement(), highestBid() / fractionalIncrement());
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

    /// Exchange the auction item and winning bid.
    function finalize() external {
        require(msg.sender == beneficiary);
        require(ended());
        require(!finalized);

        finalized = true;
        AuctionFinalized(highestBidder(), highestBid());
        

        if (highestBid() >= reservePrice) {
            untrustedTransferBid(beneficiary, highestBid());
            untrustedTransferItem(highestBidder());
        } else {
            untrustedTransferBid(highestBidder(), highestBid());
            untrustedTransferItem(beneficiary);
        }
    }

    function ended() public view returns (bool) {
        return block.timestamp > auctionEnd() && block.number > endBlock();
    }
    
    function start() external {
        require(msg.sender == beneficiary);
        require(funded());
        require(!started());


        setStarted(true);
        logStart();
    }
    

    /// Abort the auction.
    function abort() external {
        require(msg.sender == beneficiary);
        require(started() && highestBid() == 0);
        
        
        setStarted(false);
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
            if (!started()) {
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

        if (started()) {
            require(incomingBid(EIP777(msg.sender), from, amount));
        } else {
            require(from == beneficiary);
            require(incomingFunds(EIP777(msg.sender), amount));
        }
    }

    function incomingBid(EIP777 token, address source, uint amount) internal returns (bool accepted) {
        if (token == EIP777(bidToken())) {
            if (!selfInitiatedTransfer()) {
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

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) internal;

    // Transfers the auctioned item.
    function untrustedTransferItem(address receiver) internal;

    // Checks the auction contract possesses the auctioned item.
    function funded() public view returns (bool);

    // Logs the start of the auction to the chain via AuctionStarted.
    function logStart() internal;

}
