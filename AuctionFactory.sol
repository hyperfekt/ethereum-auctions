pragma solidity ^0.4.18;

import "./Auction.sol";
import "./NFTAuction.sol";
import "./TokenAuction.sol";
import "./TokenBidAuction.sol";
import "./EtherBidAuction.sol";
import "./WordBidAuction.sol";
import "./TwelveByteBidAuction.sol";

contract AuctionFactory {
    uint secondsPerYear = 31557600;
    uint version = 0;
    uint currentEtherSupply;
    uint fixedInflation;
    uint fractionalCut;

    uint creationDate;
    mapping(string => bool) optionOffered;
    mapping(address => bool) product;

    function AuctionFactory(uint _currentEtherSupply, uint _fixedInflation, uint _fractionalCut) public {
        currentEtherSupply = _currentEtherSupply;
        fixedInflation = _fixedInflation;
        fractionalCut = _fractionalCut;
        creationDate = now;
    }

    /// True for the first option, false for the second
    function createAuction(
        string bid, 
        string item, 
        string bidsize, 
        uint40 _endTime,
        uint32 _extendBlocks,
        address _token,
        uint _amount,
        address _bidToken,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice
        ) public returns (address)
        {
        address auction;
        if (eqstr(bid,"Ether")) {
            if (eqstr(item,"Token")) {
                if (eqstr(bidsize,"TwelveByte")) {
                    auction = new TwelveByteEtherTokenAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                } else if (eqstr(bidsize,"Word")) {
                    auction = new WordEtherTokenAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                }
            } else if (eqstr(item,"NFT")) {
                if (eqstr(bidsize,"TwelveByte")) {
                    auction = new TwelveByteEtherNFTAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                } else if (eqstr(bidsize,"Word")) {
                    auction = new WordEtherTokenAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                }
            }
        } else if (eqstr(bid,"Token")) {
            if (eqstr(item,"Token")) {
                if (eqstr(bidsize,"TwelveByte")) {
                    auction = new TwelveByteTokenTokenAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                } else if (eqstr(bidsize,"Word")) {
                    auction = new WordTokenTokenAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                }
            } else if (eqstr(item,"NFT")) {
                if (eqstr(bidsize,"TwelveByte")) {
                    auction = new TwelveByteTokenNFTAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                } else if (eqstr(bidsize,"Word")) {
                    auction = new WordTokenNFTAuction(_token,_amount,_bidToken,_endTime,_extendBlocks,_fixedIncrement,_fractionalIncrement,_reservePrice,expectedSupply(),msg.sender,fractionalCut);
                }
            }
        }
        product[auction] = true;
        return auction;
    }

    function expectedSupply() public view returns (uint) {
        return currentEtherSupply + (now-creationDate)/secondsPerYear*fixedInflation;
    }

    function isProduct(address auction) public view returns (bool) {
        return product[auction];
    }

    function eqstr(string a, string b) public pure returns (bool) {
        return keccak256(a) == keccak256(b);
    }
}

contract TwelveByteTokenTokenAuction is TwelveByteBidAuction, TokenBidAuction, TokenAuction {
    /// Prepare an auction for `_amount` of the token at `_token` in exchange for the ERC20 token at `_token` in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the asset to the auction's address.
    function TwelveByteTokenTokenAuction(
        address _token,
        uint _amount,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
    ) public TokenAuction(_token, _amount) TokenBidAuction(_bidToken) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    {
        require(_bidToken != _token);
    }
}

contract WordTokenTokenAuction is WordBidAuction, TokenBidAuction, TokenAuction {
    /// Prepare an auction for `_amount` of the token at `_token` in exchange for the ERC20 token at `_token` in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the asset to the auction's address.
    function WordTokenTokenAuction(
        address _token,
        uint _amount,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
    ) public TokenAuction(_token, _amount) TokenBidAuction(_bidToken) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    {
        require(_bidToken != _token);
    }
}

contract TwelveByteTokenNFTAuction is TwelveByteBidAuction, TokenBidAuction, NFTAuction {
    /// Prepare an auction for asset with ID `_assetId` on the registry at `_assetRegistry` in exchange for the ERC20 token at `_bidToken` in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the asset to the auction's address.
    function TwelveByteTokenNFTAuction(
        address _assetRegistry,
        uint256 _assetId,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
    ) public NFTAuction(_assetRegistry, _assetId) TokenBidAuction(_bidToken) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    {
    }
}

contract WordTokenNFTAuction is WordBidAuction, TokenBidAuction, NFTAuction {
    /// Prepare an auction for asset with ID `_assetId` on the registry at `_assetRegistry` in exchange for the ERC20 token at `_bidToken` in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the asset to the auction's address.
    function WordTokenNFTAuction(
        address _assetRegistry,
        uint256 _assetId,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
    ) public NFTAuction(_assetRegistry, _assetId) TokenBidAuction(_bidToken) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    {
    }
}

contract TwelveByteEtherTokenAuction is TwelveByteBidAuction, EtherBidAuction, TokenAuction {
    /// Prepare an auction for `_amount` of the token at `_token` in exchange for Ether in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the tokens to the auction's address.
    function TwelveByteEtherTokenAuction(
        address _token,
        uint _amount,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
    ) public TokenAuction(_token, _amount) EtherBidAuction(_expectedSupply) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    {
    }
}

contract WordEtherTokenAuction is WordBidAuction, EtherBidAuction, TokenAuction {
    /// Prepare an auction for `_amount` of the token at `_token` in exchange for Ether in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the tokens to the auction's address.
    function WordEtherTokenAuction(
        address _token,
        uint _amount,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
    ) public TokenAuction(_token, _amount) EtherBidAuction(_expectedSupply) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    {
    }
}

contract TwelveByteEtherNFTAuction is TwelveByteBidAuction, EtherBidAuction, NFTAuction {
    /// Prepare an auction for asset with ID `_assetId` on the registry at `_assetRegistry` in exchange for Ether in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the asset to the auction's address.
    function TwelveByteEtherNFTAuction(
        address _assetRegistry,
        uint256 _assetId,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
       ) public NFTAuction(_assetRegistry, _assetId) EtherBidAuction(_expectedSupply) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    { }
}

contract WordEtherNFTAuction is WordBidAuction, EtherBidAuction, NFTAuction {
    /// Prepare an auction for asset with ID `_assetId` on the registry at `_assetRegistry` in exchange for Ether in minimum increments of `_fixedIncrement` or current bid / `_fractionalIncrement`, whichever is greater, ending at epoch `_endTime` or `_extendBlocks` blocks after the last bid (both inclusive, whichever comes last, choose a sufficient number of blocks to decrease the chance of miner frontrunning) . Call start() after transferring the asset to the auction's address.
    function WordEtherNFTAuction(
        address _assetRegistry,
        uint256 _assetId,
        address _bidToken,
        uint40 _endTime,
        uint32 _extendBlocks,
        uint80 _fixedIncrement,
        uint24 _fractionalIncrement,
        uint _reservePrice,
        uint _expectedSupply,
        address _beneficiary,
        uint _fractionalCut
       ) public NFTAuction(_assetRegistry, _assetId) EtherBidAuction(_expectedSupply) Auction(_endTime, _extendBlocks, _fixedIncrement, _fractionalIncrement, _reservePrice, _beneficiary, _fractionalCut, this)
    { }
}