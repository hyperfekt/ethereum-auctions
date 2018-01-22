pragma solidity ^0.4.18;

import "./EIP179/ERC179Interface.sol";
import "./Auction.sol";

contract TokenAuction is Auction {

    event AuctionStarted(ERC179Interface token, uint amount);

    ERC179Interface public auctionedToken;
    uint public auctionedAmount;

    /// Prepare an auction for `_amount` of the ERC20 token at `_token` with minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the tokens to the auction's address.
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

    function transferItem(address receiver) private {
        auctionedToken.transfer(receiver, auctionedAmount);
    }

    function funded() public view returns (bool) {
        return auctionedToken.balanceOf(this) == auctionedAmount;
    }

    function logStart() private {
        AuctionStarted(auctionedToken, auctionedAmount);
    }

    function returnItem(address receiver) private {
        auctionedToken.transfer(receiver, auctionedToken.balanceOf(this));
    }
}
