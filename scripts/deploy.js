const hre = require('hardhat');

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log('Deploying with:', deployer.address);

  const Honeypot = await hre.ethers.getContractFactory('HoneypotTrap');
  const instance = await Honeypot.deploy();
  await instance.waitForDeployment();

  console.log('Honeypot deployed to:', await instance.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
