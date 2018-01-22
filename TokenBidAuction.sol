pragma solidity ^0.4.18;

import "./Auction.sol";
import "./EIP20/ERC20Interface.sol";

contract TokenBidAuction is Auction {

    function TokenBidAuction(
        address _token,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
    {
        setToken(_token);
        require(token().totalSupply() <= maximumTokenSupply());
    }
 
    function increaseBid(uint amount) external {
        require(token().transferFrom(msg.sender, this, amount));
        registerBid(amount);
    }

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) internal {
        require(token().transfer(receiver, amount));
    }

    function token() public view returns (ERC20Interface);

    function setToken(address _token) internal;

    function maximumTokenSupply() public pure returns (uint);
}