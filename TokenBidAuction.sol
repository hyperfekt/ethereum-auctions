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
        setBidToken(_token);
        require(bidToken().totalSupply() <= maximumTokenSupply());
    }
 
    function increaseBid(uint amount) external {
        status.selfInitiatedTransfer = true;
        require(bidToken().transferFrom(msg.sender, this, amount));
        status.selfInitiatedTransfer = false;
    }

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) internal {
        require(bidToken().transfer(receiver, amount));
    }

    function bidBalance() internal view returns (uint) {
        return bidToken().balanceOf(this);
    }

    function setBidToken(address _token) internal;

    function maximumTokenSupply() public pure returns (uint);
}