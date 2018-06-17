var Casino = artifacts.require("./casino/Casino.sol");

module.exports = function(deployer) {
  deployer.deploy(Casino);
};
