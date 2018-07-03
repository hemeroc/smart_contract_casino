var Casino = artifacts.require("./casino/Casino.sol");

module.exports = function(deployer) {
    let initialBeerTokenPrice = web3.toWei(0.1, "ether");
    deployer.deploy(Casino, initialBeerTokenPrice);
};
