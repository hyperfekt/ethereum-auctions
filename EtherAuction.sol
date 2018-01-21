pragma solidity ^0.4.18;

contract EtherAuction {

    struct Bid {
        address bidder;
        uint96 amount;
    }

    struct AuctionStatus {
        uint40 endBlock;
        uint40 auctionEnd; //absolute unix timestamp, note that a miner could choose the timestamp to be different from realtime and thus enter bids slightly after this moment. An extension of the auction end by >0 blocks will make that irrelevant.
        uint32 endExtension; // note that miners can choose to exclude transactions and insert their own, meaning that they can could limit the price and place winning bids by colluding with this many successive other miners.
        uint80 fixedIncrement;
        uint24 fractionalIncrement;
        bool started;
    }


    event AuctionStarted;

    address public beneficiary;
    
    mapping(address => uint96) private pendingReturns;
    Bid public highestBid;
    AuctionStatus public status;
    bool public finalized;
    bool public bidReceived;
    
    event HighestBidIncreased(address bidder, uint96 amount);
    event AuctionFinalized(address winner, uint winningBid);
    event AuctionAborted();

    /// Prepare an auction with minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the tokens to the auction's address.
    function EtherAuction(
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

    /// Increase your bid on the auction by the value sent together with this transaction. You can withdraw your bid once you are outbid. Mind that this transaction might take a while to be included, so bid early and high enough. Higher gas prices can alleviate but not fully avoid this. Successful bid costs ~40000 gas, unsuccessful ~2000 gas before transaction costs.
    function increaseBid() external payable {
        require(status.started && !ended());
        
        if (msg.sender == highestBid.bidder) {
            require(uint96(msg.value) >= currentIncrement());


            highestBid.amount += uint96(msg.value);
        } else {
            uint96 unreturned = pendingReturns[msg.sender];
            uint96 newbid = uint96(msg.value)+unreturned;
            require(newbid > highestBid.amount && newbid >= highestBid.amount + currentIncrement());


            pendingReturns[msg.sender] = 0;
            pendingReturns[highestBid.bidder] = highestBid.amount;
            highestBid.bidder = msg.sender;
            highestBid.amount = newbid;
            status.endBlock = uint40(block.number) + status.endExtension;
        }
        HighestBidIncreased(highestBid.bidder, highestBid.amount);
    }

    function currentIncrement() public view returns (uint96) {
        if (status.fractionalIncrement == 0) {
            return status.fixedIncrement;
        } else {
            return max(status.fixedIncrement, highestBid.amount / status.fractionalIncrement);
        }
    }

    function max(uint96 a, uint96 b) private pure returns (uint96) {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }

    /// Withdraw your outbid balance from the auction.
    function withdraw() external {
        uint96 amount = pendingReturns[msg.sender];
        pendingReturns[msg.sender] = 0;


        msg.sender.transfer(amount);
    }

    /// Get your current bid in the auction.
    function currentBid() external view returns (uint96) {
        if (msg.sender == highestBid.bidder) {
            return highestBid.amount;
        } else {
            return pendingReturns[msg.sender];
        }
    }

    /// Transfer the winning bid to the beneficiary.
    function receiveBid() external {
        require(msg.sender == beneficiary);
        require(ended());
        require(!bidReceived);


        if (!finalized) {
            finalized = true;
            AuctionFinalized(highestBid.bidder, highestBid.amount);
        }
        
        bidReceived = true;


        beneficiary.transfer(highestBid.amount);
    }

    /// Transfer the won item to the highest bidder.
    function receiveItem() external {
        require(msg.sender == highestBid.bidder);
        require(ended());


        if (!finalized) {
            finalized = true;
            AuctionFinalized(highestBid.bidder, highestBid.amount);
        }

        transferItem(highestBid.bidder);
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
        require(!status.started || highestBid.amount == 0);


        if (status.started) {
            status.started = false;
            AuctionAborted();
        }


        returnItem(beneficiary);
    }

    // Transfers the auctioned item to the winning bidder.
    function transferItem(address receiver) private;

    // Checks the auction contract possesses the auctioned item.
    function funded() public view returns (bool);

    // Logs the start of the auction to the chain via AuctionStarted.
    function logStart() private;

    // Transfers the auctioned item back to the beneficary.
    function returnItem(address receiver) private;
}
