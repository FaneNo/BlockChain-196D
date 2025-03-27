const DonationPlatform = artifacts.require("./DonationPlatform.sol");

module.exports = function(deployer) {
	deployer.deploy(DonationPlatform);

};
