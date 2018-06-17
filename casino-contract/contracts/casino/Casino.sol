pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Superuser.sol";

import "../ERC223/ERC223Receiver.sol";


contract Casino is Superuser, ERC223Receiver {

    using SafeMath for uint;

    constructor() public {

    }

    function tokenFallback(address _sender, address _origin, uint256 _value, bytes _data) public returns (bool success) {
        return false;
    }

}
