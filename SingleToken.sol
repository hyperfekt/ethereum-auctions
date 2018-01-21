// This implements the ERC20 token standard minus the allowance feature for a single indivisible token.

pragma solidity ^0.4.18;

import "./EIP20NoAllowanceInterface.sol";


contract SingleToken is EIP20Interface {
    address public owner;
    
    string public name;
    uint8 public decimals = 0;
    string public symbol;

    function SingleToken(
        string _tokenName,
        string _tokenSymbol
    ) public 
    {
        owner = msg.sender;               // Give the creator the initial tokens
        totalSupply = 1;                  // Update total supply
        name = _tokenName;                // Set the name for display purposes
        symbol = _tokenSymbol;            // Set the symbol for display purposes
    }
    

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value == 1);


        return transfer(_to);
    }
    function transfer(address _to) public returns (bool success) {
        require(msg.sender == owner);

        owner = _to;

        Transfer(msg.sender, _to, 1);


        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        if (_owner == owner) {
            return 1;
        } else {
            return 0;
        }
    }
}