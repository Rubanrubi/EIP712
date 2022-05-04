const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TestEIP714 = artifacts.require("TestEIP714");

module.exports = async function (deployer) {
  await deployProxy(TestEIP714, { deployer, kind: "uups" });
};
