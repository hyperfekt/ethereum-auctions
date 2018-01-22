pragma solidity ^0.4.18;

import "./EtherBidAuction.sol";
import "./TokenAuction.sol";

contract EtherTokenAuction is EtherBidAuction, TokenAuction {
    /// Prepare an auction for `_amount` of the ERC20 token at `_token` in exchange for Ether in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the tokens to the auction's address.
    function EtherTokenAuction(
        address _token,
        uint _amount,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public EtherBidAuction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement) TokenAuction(_token, _amount, _endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
    {
    }
}