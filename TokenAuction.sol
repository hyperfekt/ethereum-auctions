pragma solidity ^0.4.18;

import "./EIP20NoAllowanceInterface.sol";

contract TokenAuction {

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

    EIP20Interface public auctionedToken;
    uint public auctionedAmount;
    address public beneficiary;
    
    mapping(address => uint96) private pendingReturns;
    Bid public highestBid;
    AuctionStatus public status;
    bool public finalized;

    event AuctionStarted(address token, uint amount);
    event HighestBidIncreased(address bidder, uint96 amount);
    event AuctionFinalized(address winner, uint winningBid);

    /// Prepare an auction for `_amount` of the ERC20 token at `_token` with minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the tokens to the auction's address.
    function TokenAuction(
        address _token,
        uint _amount,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public
    {
        auctionedToken = EIP20Interface(_token);
        auctionedAmount = _amount;
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


        if (!finalized) {
            finalized = true;
            AuctionFinalized(highestBid.bidder, highestBid.amount);
        }
        

        beneficiary.transfer(highestBid.amount);
    }

    /// Transfer the won tokens to the highest bidder.
    function receiveTokens() external {
        require(msg.sender == highestBid.bidder);
        require(ended());


        if (!finalized) {
            finalized = true;
            AuctionFinalized(highestBid.bidder, highestBid.amount);
        }


        auctionedToken.transfer(highestBid.bidder, auctionedAmount);
    }

    function ended() public view returns (bool) {
        return block.timestamp > status.auctionEnd && block.number > status.endBlock;
    }
    
    function start() external {
        require(msg.sender == beneficiary);
        require(auctionedToken.balanceOf(this) == auctionedAmount);
        require(!status.started);


        status.started = true;
        AuctionStarted(auctionedToken, auctionedAmount);
    }

    /// Return tokens mistakenly sent to the auction.
    function abort(EIP20Interface token) external {
        require(msg.sender == beneficiary);
        require(token != auctionedToken || !status.started || highestBid.amount == 0);
        uint amount = token.balanceOf(this);
        require(amount != 0);

        if (token == auctionedToken && status.started) {
            status.started = false;
        }

        token.transfer(beneficiary, amount);
    }
}
