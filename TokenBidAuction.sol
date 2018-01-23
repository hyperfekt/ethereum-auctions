pragma solidity ^0.4.18;

import "./Auction.sol";
import "./interfaces/EIP20/ERC20Interface.sol";


contract TokenBidAuction is Auction {

    ERC20Interface public _bidToken;

    function TokenBidAuction(
        address _token
    ) public
    {
        _bidToken = ERC20Interface(_token);
        require(bidToken().totalSupply() <= maximumTokenSupply());
    }
 
    function increaseBid(uint amount) external {
        setSelfInitiatedTransfer(true);
        require(bidToken().transferFrom(msg.sender, this, amount));
        setSelfInitiatedTransfer(false);
    }

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) internal {
        require(bidToken().transfer(receiver, amount));
    }

    function bidBalance() internal view returns (uint) {
        return bidToken().balanceOf(this);
    }

    function bidToken() internal view returns (ERC20Interface) {
        return _bidToken;
    }

    function maximumTokenSupply() public pure returns (uint);
}