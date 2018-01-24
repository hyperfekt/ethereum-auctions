pragma solidity ^0.4.18;

import "./interfaces/EIP721+821/NFTRegistry.sol";
import "./interfaces/EIP721/ERC721.sol";
import "./interfaces/EIP821/IAssetRegistry.sol";
import "./Auction.sol";

contract NFTAuction is Auction {

    event AuctionStarted(ERC20Interface bidToken, NFTRegistry token, uint asset);

    NFTRegistry public assetRegistry;
    uint256 public assetId;

    function NFTAuction(
        address _assetRegistry,
        uint256 _assetId
    ) public
    {
        assetRegistry = NFTRegistry(_assetRegistry);
        assetId = _assetId;
        setInterfaceImplementation("IAssetHolder", this);
    }

    function untrustedTransferItem(address receiver) internal {
        assetRegistry.transfer(receiver, assetId);
    }

    function funded() public view returns (bool) {
        address registryImplementer = interfaceAddr(assetRegistry, "IAssetRegistry");
        if (registryImplementer != 0) {
            return this == IAssetRegistry(registryImplementer).holderOf(assetId);
        } else {
            return this == ERC721(assetRegistry).ownerOf(assetId);
        }
    }

    function logStart() internal {
        AuctionStarted(bidToken(), assetRegistry, assetId);
    }

    function untrustedTransferExcessAuctioned(address receiver, address registry, uint asset) internal returns (bool notAuctioned) {
        if (NFTRegistry(registry) == assetRegistry && asset == assetId) {
            if (!started()) {
                assetRegistry.transfer(receiver, assetId);
            }
            return false;
        } else {
            return true;
        }
    }

    function onAssetReceived(uint256 _assetId, address _previousHolder, address _currentHolder, bytes, address, bytes) public {
        require(this == _currentHolder);
        require(beneficiary == _previousHolder);
        require(assetRegistry == msg.sender);
        require(assetId == _assetId);
    }
}