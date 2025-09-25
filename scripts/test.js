const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HoneypotTrap", function () {
  it("flags an attacker when withdraw is called", async function () {
    const [owner, attacker] = await ethers.getSigners();

    // Deploy HoneypotTrap
    const HoneypotTrap = await ethers.getContractFactory("HoneypotTrap");
    const trap = await HoneypotTrap.deploy();
    await trap.deployed();

    // Attacker calls withdraw()
    await trap.connect(attacker).withdraw();

    // Verify attacker was flagged
    expect(await trap.attackers(attacker.address)).to.equal(true);
  });
});
