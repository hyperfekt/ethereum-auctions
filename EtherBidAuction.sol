pragma solidity ^0.4.18;

import "./TwelveByteBidAuction.sol";

contract EtherBidAuction is TwelveByteBidAuction {

    function EtherBidAuction(
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public TwelveByteBidAuction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
    {
    }
 
    function increaseBid() external payable {
        registerBid(msg.sender, msg.value);
    }

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) internal {
        receiver.transfer(amount);
    }

    function bidToken() internal view returns (ERC20Interface) {
        return ERC20Interface(0);
    }

    function bidBalance() internal view returns (uint) {
        return this.balance;
    }
}
