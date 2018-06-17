pragma solidity ^0.4.24;

import "../erc223/Basic223Token.sol";
import "../erc223/Burnable223Token.sol";
import "../erc223/Mintable223Token.sol";

contract CasinoToken is Basic223Token, Burnable223Token, Mintable223Token {

    string public constant name = "CasinoToken";
    string public constant symbol = "🎰";

    uint public constant INITIAL_SUPPLY = 42;

    constructor() public {
        mint(msg.sender, INITIAL_SUPPLY);
    }

}
