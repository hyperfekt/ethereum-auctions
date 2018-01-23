pragma solidity ^0.4.18;

import "./Auction.sol";

contract WordBidAuction is Auction {

    struct Bid {
        address bidder;
        uint256 amount;
    }

    Bid public maximumBid;
    

    function setHighestBid(address bidder, uint256 amount) internal {
        maximumBid.bidder = bidder;
        maximumBid.amount = amount;
    }

    function highestBidder() public view returns (address) {
        return maximumBid.bidder;
    }

    function highestBid() public view returns (uint256) {
        return maximumBid.amount;
    }

     function maximumTokenSupply() public pure returns (uint) {
        return 2^256-1;
    }
}