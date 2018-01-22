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
 
    /// Increase your bid on the auction by `amount`. You can withdraw your bid once you are outbid. Make sure the auction has a sufficient allowance to withdraw the tokens. Mind that this transaction might take a while to be included, so bid early and high enough. Higher gas prices can alleviate but not fully avoid this. Successful bid costs ~40000 gas, unsuccessful ~2000 gas before transaction costs.
    function increaseBid(uint amount) external {
        token().transferFrom(msg.sender, this, amount);
        registerBid(amount);
    }

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) private {
        token().transfer(receiver, amount);
    }

    function token() public view returns (ERC20Interface);

    function setToken(address _token) internal;

    function maximumTokenSupply() public pure returns (uint);
}