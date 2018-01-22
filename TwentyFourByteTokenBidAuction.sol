pragma solidity ^0.4.18;

import "./TokenBidAuction.sol";

contract TwentyFourByteTokenBidAuction is TokenBidAuction {

    struct Bid {
        ERC20Interface token;
        address bidder;
        uint192 amount;
    }

    Bid public maximumBid;
    

    function setHighestBid(address bidder, uint256 amount) internal {
        maximumBid.bidder = bidder;
        maximumBid.amount = uint192(amount);
    }

    function highestBidder() public view returns (address) {
        return maximumBid.bidder;
    }

    function highestBid() public view returns (uint256) {
        return maximumBid.amount;
    }

    function bidToken() internal view returns (ERC20Interface) {
        return maximumBid.token;
    }

    function setBidToken(address _token) internal {
        maximumBid.token = ERC20Interface(_token);
    }

    function maximumTokenSupply() public pure returns (uint) {
        return 2^192-1;
    }
}