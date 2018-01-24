pragma solidity ^0.4.18;

import "./Auction.sol";

contract EtherBidAuction is Auction {

    function EtherBidAuction(uint _etherSupply) public {
        require(_etherSupply <= maximumTokenSupply());
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