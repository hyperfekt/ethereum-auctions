pragma solidity ^0.4.18;

contract Auction {

    struct AuctionStatus {
        uint40 endBlock;
        uint40 auctionEnd; //absolute unix timestamp, note that a miner could choose the timestamp to be different from realtime and thus enter bids slightly after this moment. An extension of the auction end by >0 blocks will make that irrelevant.
        uint32 endExtension; // note that miners can choose to exclude transactions and insert their own, meaning that they can could limit the price and place winning bids by colluding with this many successive other miners.
        uint80 fixedIncrement;
        uint24 fractionalIncrement;
        bool started;
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
    }

    function registerBid(uint256 amount) internal {
        uint256 newbid;
        if (msg.sender == highestBidder()) {
            newbid = highestBid() + amount;
        } else {
            uint256 unreturned = pendingReturns[msg.sender];
            newbid = unreturned + amount;

            pendingReturns[msg.sender] = 0;
            pendingReturns[highestBidder()] = highestBid();
        }
        require(validBid(newbid));
        newHighestBid(msg.sender, newbid);
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
    

    /// Return tokens mistakenly sent to the auction.
    function abort() external {
        require(msg.sender == beneficiary);
        require(!status.started || highestBid() == 0);


        if (status.started) {
            status.started = false;
            AuctionAborted();
        }


        untrustedReturnItem(beneficiary);
    }

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

    // Transfers the auctioned item back to the beneficary.
    function untrustedReturnItem(address receiver) internal;
}
