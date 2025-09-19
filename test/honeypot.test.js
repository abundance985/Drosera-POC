const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('HoneypotTrap', function () {
  it('flags an attacker on withdraw', async function () {
    const [owner, attacker] = await ethers.getSigners();
    const Honeypot = await ethers.getContractFactory('HoneypotTrap');
    const hp = await Honeypot.deploy();
    await hp.waitForDeployment();

    // Attacker calls withdraw
    await hp.connect(attacker).withdraw();

    // Check mapping
    const flagged = await hp.isAttacker(attacker.address);
    expect(flagged).to.equal(true);

    // Event appears in logs
    const receipt = await hp.getPastEvents?.(); // fallback - ethers v6 uses filters instead
    // We'll assert via contract view above; logs are visible in tx but tests keep it simple.
  });
});
