var CasinoToken = artifacts.require("./casino/CasinoToken.sol");

module.exports = function(deployer) {
    deployer.deploy(CasinoToken);
};
