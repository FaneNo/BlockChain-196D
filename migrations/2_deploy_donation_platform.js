const DonationPlatform = artifact.required("./DonationPlatform.sol");

module.exports = function(deployer) {
	deployer.deploy(DonationPlatform);

};
