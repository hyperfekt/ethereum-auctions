pragma solidity ^0.4.18;

import "./TokenBidAuction.sol";

contract TwentyFourByteTokenBidAuction is TokenBidAuction {

    struct Bid {
        ERC20Interface token;
        bytes12 amountA;
        bytes12 amountB;
        address bidder;
    }

    Bid public maximumBid;
    

    function setHighestBid(address bidder, uint256 amount) internal {
        maximumBid.bidder = bidder;

        maximumBid.amountA = bytes12(amount);
        maximumBid.amountB = bytes12(amount >> 96);
    }

    function highestBidder() public view returns (address) {
        return maximumBid.bidder;
    }

    function highestBid() public view returns (uint256) {
        uint192 a = uint192(maximumBid.amountA);
        uint192 b = uint192(maximumBid.amountB);
        a = a << 96;
        a = a | b;
        return uint256(a);
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