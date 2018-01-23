pragma solidity ^0.4.18;

import "./IBid.sol";
import "./IAuctionStatus.sol";
import "./Auction.sol";

contract TwelveByteBidAuction is Auction {

    struct Bid {
        address bidder;
        uint96 amount;
    }

    struct AuctionStatus {
        uint40 endBlock;
        uint40 auctionEnd; //absolute unix timestamp, note that a miner could choose the timestamp to be different from realtime and thus enter bids slightly after this moment. An extension of the auction end by >0 blocks will make that irrelevant.
        uint32 endExtension; // note that miners can choose to exclude transactions and insert their own, meaning that they can could limit the price and place winning bids by colluding with this many successive other miners.
        uint24 fractionalIncrement;
        bool started;
        bool selfInitiatedTransfer;
        uint96 fixedIncrement;
    }

    Bid internal maximumBid;
    AuctionStatus internal status;


    function setHighestBid(address bidder, uint256 amount) internal {
        maximumBid.bidder = bidder;
        maximumBid.amount = uint96(amount);
    }

    function highestBidder() public view returns (address) {
        return maximumBid.bidder;
    }

    function highestBid() public view returns (uint256) {
        return maximumBid.amount;
    }

    function maximumTokenSupply() public pure returns (uint) {
        return 2^96-1;
    }
    
    function endBlock() public view returns (uint40) {
        return status.endBlock;
    }
    function auctionEnd() public view returns (uint40) {
        return status.auctionEnd;
    }
    function endExtension() public view returns (uint32) {
        return status.endExtension;
    }
    function fixedIncrement() public view returns (uint) {
        return status.fixedIncrement;
    }
    function fractionalIncrement() public view returns (uint24) {
        return status.fractionalIncrement;
    }
    function started() public view returns (bool) {
        return status.started;
    }
    function selfInitiatedTransfer() internal view returns (bool) {
        return status.selfInitiatedTransfer;
    }
    
    function setEndBlock(uint40 set) internal {
        status.endBlock = set;
    }
    function setAuctionEnd(uint40 set) internal {
        status.auctionEnd = set;
    }
    function setEndExtension(uint32 set) internal {
        status.endExtension = set;
    }
    function setFixedIncrement(uint set) internal {
        status.fixedIncrement = uint96(set);
    }
    function setFractionalIncrement(uint24 set) internal {
        status.fractionalIncrement = set;
    }
    function setStarted(bool set) internal {
        status.started = set;
    }
    function setSelfInitiatedTransfer(bool set) internal {
        status.selfInitiatedTransfer = set;
    }
}
