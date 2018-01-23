contract IBid {
    function maximumTokenSupply() public pure returns (uint);

    function highestBidder() public view returns (address);
    function highestBid() public view returns (uint256);

    function setHighestBid(address bidder, uint256 amount) internal;
}
