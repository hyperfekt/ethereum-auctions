pragma solidity ^0.4.18;

import "./TwelveByteBidAuction.sol";
import "./TokenAuction.sol";
import "./TokenBidAuction.sol";

contract TokenTokenAuction is TokenBidAuction, TwelveByteBidAuction, TokenAuction {
    /// Prepare an auction for `_amount` of the token at `_token` in exchange for the ERC20 token at `_token` in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the asset to the auction's address.
    function TokenTokenAuction(
        address _token,
        uint _amount,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice
    ) public TokenAuction(_token, _amount) TokenBidAuction(_bidToken) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice)
    {
        require(_bidToken != _token);
    }
}