pragma solidity ^0.4.18;

import "./Auction.sol";

contract EtherBidAuction is Auction {

    struct Bid {
        address bidder;
        uint96 amount;
    }

    Bid private maximumBid;
    

    function EtherBidAuction(
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
    {
    }
 
    /// Increase your bid on the auction by the value sent together with this transaction. You can withdraw your bid once you are outbid. Mind that this transaction might take a while to be included, so bid early and high enough. Higher gas prices can alleviate but not fully avoid this. Successful bid costs ~40000 gas, unsuccessful ~2000 gas before transaction costs.
    function increaseBid() external payable {
        registerBid(msg.value);
    }

    // Transfers a bid.
    function untrustedTransferBid(address receiver, uint256 amount) private {
        receiver.transfer(amount);
    }

    function setHighestBid(address bidder, uint256 amount) internal {
        maximumBid.bidder = bidder;
        maximumBid.amount = uint96(amount);
    }

    function highestBidder() public view returns (address) {
        return maximumBid.bidder;
    }

    function highestBid() public view returns (uint256) {
        return maximumBid.amount;
    }
}
