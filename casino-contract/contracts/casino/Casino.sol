pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Superuser.sol";

import "../erc223/ERC223Receiver.sol";

import "./CasinoToken.sol";

contract Casino is Superuser, ERC223Receiver {

    string public constant ROLE_ORACLE = "oracle";
    string public constant CASINO_TOKEN_SUPPLY = "CASINO_TOKEN_SUPPLY";

    using SafeMath for uint;

    CasinoToken internal casinoTokenContract;
    uint256 internal casinoTokenPrice;

    constructor(uint256 _initialCasinoTokenPrice) public {
        require(_initialCasinoTokenPrice > 0);
        casinoTokenPrice = _initialCasinoTokenPrice;
        addRole(msg.sender, ROLE_ORACLE);
    }

    event CasinoTokensSupplied(uint256 _amount);
    event OracleInformationReceived(uint256 _utcTimestamp, uint256 _price);

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
        // check if token is supply
        if (keccak256(_data) == keccak256(CASINO_TOKEN_SUPPLY)) {
            require(_sender == owner || isSuperuser(_sender));
            emit CasinoTokensSupplied(_value);
            return true;
        }
        // TODO: check if token is sold and contract has enough funds to accept the token
        return false;
    }

    // Payout

    function payout(address _receiver, uint256 _amount) external onlyOwner {
        _receiver.transfer(_amount);
    }

    // Oracle

    function setInformation(uint256 _utcTimestamp, uint256 _price) external onlyOracle {
        emit OracleInformationReceived(_utcTimestamp, _price);
    }

    modifier onlyOracle() {
        checkRole(msg.sender, ROLE_ORACLE);
        _;
    }


}
