const ddnsToken = artifacts.require("DDNSToken");
const auction = artifacts.require("DomainOwnership");

let initialSupply = 50_000_000;
let tokenCap = 100_000_000;
let tokenBlockReward = 50;

module.exports = async function (_deployer) {
    await _deployer.deploy(ddnsToken, initialSupply, tokenCap, tokenBlockReward)
    await _deployer.deploy(auction, ddnsToken.address)
};
