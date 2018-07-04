const CasinoToken = artifacts.require("./casino/CasinoToken.sol");
const Casino = artifacts.require("./casino/Casino.sol");

module.exports = async function (deployer) {
    const casino = await Casino.deployed();
    const casinoToken = await CasinoToken.deployed();

    await casino.setCasinoTokenContractAddress(casinoToken.address);
    await casinoToken.mint(casino.address, 100);
};
