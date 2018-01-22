pragma solidity ^0.4.18;

import "./EIP721+821/NFTRegistry.sol";
import "./EIP821/IAssetHolder.sol";
import "./EIP821/IAssetRegistry.sol";
import "./EIP820/EIP820.sol";
import "./Auction.sol";

contract NFTAuction is Auction, EIP820, IAssetHolder {

    event AuctionStarted(address registry, uint256 id);

    NFTRegistry public assetRegistry;
    uint256 public assetId;

    function NFTAuction(
        address _assetRegistry,
        uint256 _assetId,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
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
            return this == assetRegistry.ownerOf(assetId);
        }
    }

    function logStart() internal {
        AuctionStarted(assetRegistry, assetId);
    }

    function untrustedReturnItem(address receiver) internal {
        untrustedTransferItem(receiver);
    }

    function onAssetReceived(uint256 _assetId, address, address, bytes, address, bytes) public {
        require(assetRegistry == msg.sender);
        require(assetId == _assetId);
    }
}