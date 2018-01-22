pragma solidity ^0.4.18;

contract NFTRegistry {
    function totalSupply() public view returns (uint256 total);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function holderOf(uint256 assetId) public view returns (address);
    function transfer(address _to, uint256 _tokenId) public;
    function noReturn(uint256 assetId) public;
}