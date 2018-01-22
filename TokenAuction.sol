pragma solidity ^0.4.18;

import "./EIP179/ERC179Interface.sol";
import "./Auction.sol";

contract TokenAuction is Auction {

    event AuctionStarted(ERC179Interface token, uint amount);

    ERC179Interface public auctionedToken;
    uint public auctionedAmount;

    function TokenAuction(
        address _token,
        uint _amount,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
    {
        auctionedToken = ERC179Interface(_token);
        auctionedAmount = _amount;
    }

    function untrustedTransferItem(address receiver) internal {
        auctionedToken.transfer(receiver, auctionedAmount);
    }

    function funded() public view returns (bool) {
        return auctionedToken.balanceOf(this) == auctionedAmount;
    }

    function logStart() internal {
        AuctionStarted(auctionedToken, auctionedAmount);
    }

    function untrustedReturnItem(address receiver) internal {
        auctionedToken.transfer(receiver, auctionedToken.balanceOf(this));
    }
}
