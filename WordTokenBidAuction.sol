pragma solidity ^0.4.18;

import "./TokenBidAuction.sol";

contract WordTokenBidAuction is TokenBidAuction {

    struct Bid {
        ERC20Interface token;
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

    function token() public view returns (ERC20Interface) {
        return maximumBid.token;
    }

    function setToken(address _token) internal {
        maximumBid.token = ERC20Interface(_token);
    }
}