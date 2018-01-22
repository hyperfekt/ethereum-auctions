pragma solidity ^0.4.18;

import "./EIP821/IAssetRegistry.sol";
import "./EIP821/IAssetHolder.sol";
import "./EIP820/EIP820.sol";
import "./EtherAuction.sol";

contract NFTAuction is EtherAuction, EIP820, IAssetHolder {

    event AuctionStarted(address registry, uint256 id);

    IAssetRegistry public assetRegistry;
    uint256 public assetId;

    /// Prepare an auction for asset with ID `_assetId` on the ERC821 registry at `_assetRegistry` with minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the tokens to the auction's address.
    function NFTAuction(
        address _assetRegistry,
        uint256 _assetId,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement
    ) public EtherAuction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement)
    {
        assetRegistry = IAssetRegistry(_assetRegistry);
        assetId = _assetId;
        setInterfaceImplementation("IAssetHolder", this);
    }

    function transferItem(address receiver) private {
        assetRegistry.transfer(receiver, assetId);
    }

    function funded() public view returns (bool) {
        return this == assetRegistry.holderOf(assetId);
    }

    function logStart() private {
        AuctionStarted(assetRegistry, assetId);
    }

    function returnItem(address receiver) private {
        assetRegistry.transfer(receiver, assetId);
    }

    function onAssetReceived(uint256 _assetId, address, address, bytes, address, bytes) public {
        require(assetRegistry == msg.sender);
        require(assetId == _assetId);
    }
}