pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Superuser.sol";

import "../erc223/ERC223Receiver.sol";

import "./CasinoToken.sol";

contract Casino is Superuser, ERC223Receiver {

    string public constant ROLE_ORACLE = "oracle";
    string public constant CASINO_TOKEN_SUPPLY = "CASINO_TOKEN_SUPPLY";

    uint256 private constant MIN_BET_TIMESTAMP_IN_FUTURE = 60 * 25; // 15 Minutes in Seconds
    uint256 private constant MAX_BET_TIMESTAMP_IN_FUTURE = 60 * 60; // 60 Minutes in Seconds

    using SafeMath for uint;

    CasinoToken internal casinoTokenContract;
    uint256 internal casinoTokenPrice;

    constructor(uint256 _initialCasinoTokenPrice) public {
        require(_initialCasinoTokenPrice > 0);
        casinoTokenPrice = _initialCasinoTokenPrice;
        addRole(msg.sender, ROLE_ORACLE);
    }

    event CasinoTokensSupplied(uint256 _amount);
    event OracleInformationReceived(uint256 _timestamp, uint256 _price);
    event BetPlaced(address _address, uint256 _betPlacedTimestamp, uint256 _betTimestamp, bool _rise);

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
        // TODO: add tokens from user to his balance
        // TODO: add a possibility to sell tokens
        return false;
    }

    function getCasinoTokenBalance() external view returns (uint256) {
        // TODO: return the users casino token balance
        return 0;
    }

    // Bet placement

    function placeBet(uint256 _amount, bool _rise) {
        require(_amount >= 10);
        uint _betTimestamp = 123;
//        require(_betTimestamp >= block.timestamp + MIN_BET_TIMESTAMP_IN_FUTURE);
//        require(_betTimestamp <= block.timestamp + MAX_BET_TIMESTAMP_IN_FUTURE);
        // TODO:
        // - Set _betTimestamp
        // - check if the user has given amount of tokens
        // - remove given amount of tokens from user balance
        // - store bet placement
        emit BetPlaced(msg.sender, block.timestamp, _betTimestamp, _rise);
    }

    function closeFinishedBets() {
        // TODO:
        // - close all finished bets of the user
        // - close all overdue bets
        // - transfer resulting tokens to user
    }

    // Payout

    function payout(address _receiver, uint256 _amount) external onlyOwner {
        _receiver.transfer(_amount);
    }

    // Oracle

    function setInformation(uint256 _timestamp, uint256 _price) external onlyOracle {
        // TODO: store oracle information mapping from timestamp to price
        emit OracleInformationReceived(_timestamp, _price);
    }

    modifier onlyOracle() {
        checkRole(msg.sender, ROLE_ORACLE);
        _;
    }

}
