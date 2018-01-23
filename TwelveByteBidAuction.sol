pragma solidity ^0.4.18;

import "./Auction.sol";

contract TwelveByteBidAuction is Auction {

    struct Bid {
        address bidder;
        uint96 amount;
    }

    Bid internal maximumBid;

    function TwelveByteBidAuction(
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
    {
    }

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
}
