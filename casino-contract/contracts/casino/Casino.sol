pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Superuser.sol";

import "../erc223/ERC223Receiver.sol";

import "./CasinoToken.sol";

contract Casino is Superuser, ERC223Receiver {

    using SafeMath for uint;

    CasinoToken internal casinoTokenContract;
    uint256 internal casinoTokenPrice;

    constructor(uint256 _initialCasinoTokenPrice) public {
        require(_initialCasinoTokenPrice > 0);
        casinoTokenPrice = _initialCasinoTokenPrice;
    }

    // Casino Token

    function setCasinoTokenContractAddress(address _address) external onlyOwnerOrSuperuser {
        casinoTokenContract = CasinoToken(_address);
    }

    function casinoTokenContractAddress() external view returns (address) {
        return casinoTokenContract;
    }

    function setCasinoTokenPrice(uint256 _newCasinoTokenPrice) external onlyOwnerOrSuperuser {
        require(_newCasinoTokenPrice > 0);
        casinoTokenPrice = _newCasinoTokenPrice;
    }

    function getCasinoTokenPrice() external view returns (uint256) {
        return casinoTokenPrice;
    }

    function buyCasinoToken() external payable {
        uint tokens = msg.value / casinoTokenPrice;
        if (tokens > 0) {
            casinoTokenContract.transfer(msg.sender, tokens, "Good Luck 🍀");
        }
    }

    function tokenFallback(address _sender, address _origin, uint256 _value, bytes _data) public returns (bool success) {
        require(CasinoToken(msg.sender) == casinoTokenContract);
        // TODO implement me
        return true;
    }

    // Payout

    function payout(address _receiver, uint256 _amount) external onlyOwner {
        _receiver.transfer(_amount);
    }

}
