const GameShop = artifacts.require('./GameShop.sol')

module.exports = deployer => {
	deployer.deploy(GameShop).then(instance => {
		console.log('ABI:', JSON.stringify(instance.abi))
	})
}