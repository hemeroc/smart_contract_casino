pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Superuser.sol";

import "../ERC223/ERC223Receiver.sol";


contract Casino is Superuser, ERC223Receiver {

    using SafeMath for uint;

    constructor() public {

    }

}
