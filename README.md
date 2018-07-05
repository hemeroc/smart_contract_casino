# Smart Contracts Casino

## Author
* Dominik Moser (e0726744)
* Martin Prebio (e1025737)

## Description

This project is an ethereum binary betting casino: The luck searching can bet whether the ethereum
price will rise or fall. For this purpose, they interact with the casino contract and the casino token.
The interaction is done via an HTML application. The actual price information is retrieved via a Java
Oracle which listens to the events emitted by the contract. For simplification there is only a single 
Oracle instance but in practice there should be several and a mechanism for consensus. In the case 
the oracle is not available the bet is reimbursed.

Note that error handling is not perfect and the focus lied on the technologies and not perfect software
engineering :)

## Starting

The applications require a running ethereum network. Best (and tested) way is to use Ganache.
Additionally, Java 8+ is required. All other dependencies are loaded by gradle and npm.

* Contract: `./gradlew :casino-contract:truffleMigrate`. This will compile and install the token and casino contract.
Further, the last migration sets some sensible defaults like connection the token and casino and transfer an initial
balance to it.
* Oracle: `./gradlew :casino-oracle:bootRun`. Its actions can be watched on stdout.
* Web: `/gradlew :casino-web:run`. It will be available on http://localhost:3000.

Be aware that you have to set the oracle/contract addresses in `application.yml`.
The owner or superuser has to add the oracle address to the contract `addOracle(_oracleAddress)`.

## Technlogy

 * Contracts: Solidity & Truffle
 * Oracle: Kotlin, Spring, web3j
 * Web: React, web3, material-ui

## Open Todos

 * Graph of the ethereum price combined with the Betting and Oracle events.
 * Allow a consensus of multiple oracles.

## Final todo notes

Sadly, the payout method always reverts and we couldn't find the issue in the given time. Please imagine the working
payout :)

PS: Thanks for the awesome workshops and insights! The exercises - sometimes easy to solve, sometimes hard to crack
 - were a lot of fun despite the horrifying Javascript.
