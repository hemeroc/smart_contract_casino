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
    mapping(address => Bet[]) bets;

    struct Bet {
        uint256 amount;
        uint256 betPlacedTimestamp;
        uint256 betTimestamp;
        bool rise;
    }

    constructor(uint256 _initialCasinoTokenPrice) public {
        require(_initialCasinoTokenPrice > 0);
        casinoTokenPrice = _initialCasinoTokenPrice;
        addRole(msg.sender, ROLE_ORACLE);
    }

    event CasinoTokensSupplied(uint _amount);

    event OracleInformationStored(uint256 _timestamp, uint _price);
    event OracleInformationDiscarded(uint256 _timestamp, uint _storedPrice, uint _oraclePrice);

    event TokenSold(address _address, uint _amount);
    event TokenAdded(address _address, uint _oldTokenBalance, uint _newTokenBalance);

    event BetPlaced(address _address, uint256 amount, uint256 _betPlacedTimestamp, uint256 _betTimestamp, bool _rise);
    event BetLost(address _address, uint256 amount, uint256 _betPlacedTimestamp, uint _initialPrice, uint256 _betTimestamp, uint _finalPrice);
    event BetWon(address _address, uint256 amount, uint256 _betPlacedTimestamp, uint _initialPrice, uint256 _betTimestamp, uint _finalPrice);
    event BetRefunded(address _address, uint256 amount, uint256 _betPlacedTimestamp, uint _initialPrice, uint256 _betTimestamp, uint _finalPrice);

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
        bets[msg.sender].push(Bet(_amount, block.timestamp, _betTimestamp, _rise));
        emit BetPlaced(msg.sender, _amount, block.timestamp, _betTimestamp, _rise);
    }

    function closeFinishedBets() external {
        Bet[] storage senderBets = bets[msg.sender];
        for (uint i = 0; i < senderBets.length; i++) {
            Bet storage bet = senderBets[i];
            if (bet.betTimestamp >= block.timestamp) {
                continue;
            }
            if (priceInformation[bet.betPlacedTimestamp] != 0 && priceInformation[bet.betTimestamp] != 0) {
                if ((priceInformation[bet.betPlacedTimestamp] < priceInformation[bet.betTimestamp] && bet.rise) ||
                    (priceInformation[bet.betPlacedTimestamp] > priceInformation[bet.betTimestamp] && !bet.rise)) {
                    uint256 wonTokens = bet.amount.mul(9).div(5);
                    tokenBalance[msg.sender].add(wonTokens);
                    emit BetWon(msg.sender, wonTokens,
                        bet.betPlacedTimestamp, priceInformation[bet.betPlacedTimestamp],
                        bet.betTimestamp, priceInformation[bet.betTimestamp]);
                } else {
                    emit BetLost(msg.sender, bet.amount,
                        bet.betPlacedTimestamp, priceInformation[bet.betPlacedTimestamp],
                        bet.betTimestamp, priceInformation[bet.betTimestamp]);
                }
                senderBets[i] = senderBets[senderBets.length - 1];
                senderBets.length--;
                i--;
                continue;
            } else if (bet.betTimestamp >= block.timestamp + BET_TIMESTAMP_IN_FUTURE) {
                tokenBalance[msg.sender].add(bet.amount);
                emit BetRefunded(msg.sender, bet.amount,
                    bet.betPlacedTimestamp, priceInformation[bet.betPlacedTimestamp],
                    bet.betTimestamp, priceInformation[bet.betTimestamp]);
                senderBets[i] = senderBets[senderBets.length - 1];
                senderBets.length--;
                i--;
                continue;
            }
        }
        uint tokensToTransfer = tokenBalance[msg.sender];
        tokenBalance[msg.sender] = 0;
        if (tokensToTransfer > 0) {
            casinoTokenContract.transfer(msg.sender, tokensToTransfer, "Thanks for playing 🍀");
        }
    }

    // Payout

    function payout(address _receiver, uint256 _amount) external onlyOwner {
        _receiver.transfer(_amount);
    }

    // Oracle

    function addOracle(address _oracleAddress) external onlyOwnerOrSuperuser {
        addRole(_oracleAddress, ROLE_ORACLE);
    }

    function removeOracle(address _oracleAddress) external onlyOwnerOrSuperuser {
        removeRole(_oracleAddress, ROLE_ORACLE);
    }

    function setInformation(uint256 _timestamp, uint _price) external onlyOracle {
        uint currentPriceInformation = priceInformation[_timestamp];
        if (currentPriceInformation != 0) {
            emit OracleInformationDiscarded(_timestamp, currentPriceInformation, _price);
            return;
        }
        priceInformation[_timestamp] = _price;
        emit OracleInformationStored(_timestamp, _price);
    }

    modifier onlyOracle() {
        checkRole(msg.sender, ROLE_ORACLE);
        _;
    }

}
