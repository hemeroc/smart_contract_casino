pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Superuser.sol";

import "../erc223/ERC223Receiver.sol";

import "./CasinoToken.sol";

contract Casino is Superuser, ERC223Receiver {

    string public constant ROLE_ORACLE = "oracle";
    bytes32 public constant CASINO_TOKEN_SUPPLY = keccak256("CASINO_TOKEN_SUPPLY");
    bytes32 public constant CASINO_TOKEN_SELL = keccak256("CASINO_TOKEN_SELL");

    uint256 private constant BET_TIMESTAMP_IN_FUTURE = 30 * 60; // 30 Minutes in Seconds

    using SafeMath for uint;

    CasinoToken internal casinoTokenContract;
    uint256 internal casinoTokenPrice;

    mapping(address => uint) tokenBalance;
    mapping(uint256 => uint) priceInformation;

    constructor(uint256 _initialCasinoTokenPrice) public {
        require(_initialCasinoTokenPrice > 0);
        casinoTokenPrice = _initialCasinoTokenPrice;
        addRole(msg.sender, ROLE_ORACLE);
    }

    event CasinoTokensSupplied(uint _amount);
    event OracleInformationReceived(uint256 _timestamp, uint _price);

    event TokenSold(address _address, uint _amount);
    event TokenAdded(address _address, uint _oldTokenBalance, uint _newTokenBalance);

    event BetPlaced(address _address, uint256 _betPlacedTimestamp, uint256 _betTimestamp, bool _rise);
    event BetLost(address _address, uint256 _betPlacedTimestamp, uint _initialPrice, uint256 _betTimestamp, uint _finalPrice);
    event BetWon(address _address, uint256 _betPlacedTimestamp, uint _initialPrice, uint256 _betTimestamp, uint _finalPrice);

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

    function tokenFallback(address _sender, address origin_, uint256 _value, bytes _data) public returns (bool success) {
        origin_;
        require(CasinoToken(msg.sender) == casinoTokenContract);
        bytes32 operation = keccak256(_data);
        // check if token is supply
        if (operation == CASINO_TOKEN_SUPPLY) {
            require(_sender == owner || isSuperuser(_sender));
            emit CasinoTokensSupplied(_value);
            return true;
        }
        // check if token is sold
        if (operation == CASINO_TOKEN_SELL) {
            _sender.transfer(_value * casinoTokenPrice);
            emit TokenSold(_sender, _value);
            return true;
        }
        // add token to senders balance
        uint oldTokenBalance = tokenBalance[_sender];
        uint newTokenBalance = oldTokenBalance.add(_value);
        tokenBalance[_sender] = newTokenBalance;
        emit TokenAdded(_sender, oldTokenBalance, newTokenBalance);
        return true;
    }

    function getCasinoTokenBalance() external view returns (uint256) {
        return tokenBalance[msg.sender];
    }

    // Bet placement

    function placeBet(uint256 _amount, bool _rise) external {
        require(_amount >= 10);
        tokenBalance[msg.sender] = tokenBalance[msg.sender].sub(_amount);
        require(tokenBalance[msg.sender] >= 0);
        uint _betTimestamp = block.timestamp + BET_TIMESTAMP_IN_FUTURE;
        // TODO: store bet placement
        emit BetPlaced(msg.sender, block.timestamp, _betTimestamp, _rise);
    }

    function closeFinishedBets() external {
        // TODO: close all finished bets of the user
        // TODO: close all overdue bets
        // TODO: transfer resulting tokens to user
        // TODO: emit BetLost and/or BetWon
    }

    // Payout

    function payout(address _receiver, uint256 _amount) external onlyOwner {
        _receiver.transfer(_amount);
    }

    // Oracle

    function setInformation(uint256 _timestamp, uint _price) external onlyOracle {
        priceInformation[_timestamp] = _price;
        emit OracleInformationReceived(_timestamp, _price);
    }

    modifier onlyOracle() {
        checkRole(msg.sender, ROLE_ORACLE);
        _;
    }

}
