This repository contains two related smart contracts:

1. **HoneypotTrap.sol** – the original Hardhat proof-of-concept honeypot contract.  
2. **DroseraHoneypotTrap.sol** – the updated, Drosera-compliant version that implements the \`ITrap\` interface, making it usable inside Drosera’s shadow-fork analysis.

---

## ✨ Concept

The HoneypotTrap simulates a **fake withdraw vulnerability**:

- Attackers calling \`withdraw()\` are flagged and recorded on-chain.  
- The contract emits a \`TrapTriggered\` event.  
- The Drosera-compliant trap exposes \`collect()\` and \`shouldRespond()\` so Drosera nodes can decide when to trigger based on state changes (e.g., when a new attacker is flagged).

---

## 📂 Project Structure

\`\`\`
contracts/
HoneypotTrap.sol # Original PoC (Hardhat)
DroseraHoneypotTrap.sol # Drosera-compliant trap (implements ITrap)

scripts/
deploy.js # Hardhat deploy script (Sepolia)
test.js 

test/
honeypot.test.js # Local tests

drosera.toml # Drosera trap descriptor
.env # Example env file
hardhat.config.js
package.json
README.md # This file
\`\`\`

---

## ⚙️ Usage (PoC with Hardhat)

1. **Install dependencies**
\`\`\`bash
npm install
\`\`\`

2. **Set up environment**  
Create a \`.env\` file from \`.env.example\`:
\`\`\`ini
SEPOLIA_RPC=https://eth-sepolia.g.alchemy.com/v2/<YOUR_KEY>
PRIVATE_KEY=0x<YOUR_PRIVATE_KEY>
\`\`\`

3. **Compile contracts**
\`\`\`bash
npx hardhat compile
\`\`\`

4. **Run local tests**
\`\`\`bash
npm test
\`\`\`

5. **Deploy to Sepolia**
\`\`\`bash
npm run deploy:sepolia
\`\`\`

---

## 🧪 Tests

### PoC test (\`HoneypotTrap.sol\`)

\`\`\`js
// test/honeypot.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HoneypotTrap", function () {
  it("flags an attacker when withdraw is called", async function () {
    const [owner, attacker] = await ethers.getSigners();
    const Honeypot = await ethers.getContractFactory("HoneypotTrap");
    const trap = await Honeypot.deploy();
    await trap.waitForDeployment();

    await trap.connect(attacker).withdraw();
    expect(await trap.attackers(attacker.address)).to.equal(true);
  });
});
\`\`\`

### Drosera-compliant test (\`DroseraHoneypotTrap.sol\`)

\`\`\`js
// test/droseraHoneypot.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DroseraHoneypotTrap", function () {
  it("collect/shouldRespond flow works", async function () {
    const [owner, attacker] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("DroseraHoneypotTrap");
    const trap = await Factory.deploy();
    await trap.waitForDeployment();

    const snap0 = await trap.collect();
    await trap.connect(attacker).withdraw();
    const snap1 = await trap.collect();

    const res = await trap.shouldRespond([snap0, snap1]);
    expect(res[0]).to.equal(true); // should trigger
  });
});
\`\`\`

Run:
\`\`\`bash
npm test
\`\`\`

---

## 🔗 Drosera Integration

The Drosera-compliant trap implements:

\`\`\`solidity
interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
\`\`\`

### \`drosera.toml\`

\`\`\`toml
[trap]
name = "DroseraHoneypotTrap"
description = "Honeypot trap that triggers when attackerCount increases"
contract = "contracts/DroseraHoneypotTrap.sol"
class = "DroseraHoneypotTrap"

[config]
network = "sepolia"
sample_size = 3
\`\`\`

### Run with Drosera CLI

\`\`\`bash
# Install CLI (example, may differ depending on docs)
cargo install drosera-cli

# Local shadow-fork run
drosera run

# Or against Sepolia fork
drosera run --network sepolia
\`\`\`

Expected output (example):
\`\`\`
✅ Trap DroseraHoneypotTrap initialized
📡 Collecting state...
⚡ shouldRespond() => true (triggered)
\`\`\`

---

## 🚀 Deployment

Latest Sepolia deployment (PoC):
\`\`\`
0x4Ba8eca8966409AD866c82A78DeBD295b520720a
https://sepolia.etherscan.io/address/0x4Ba8eca8966409AD866c82A78DeBD295b520720a
\`\`\`


## ⚠️ Notes & Ethics

- This trap is for **research and testing on testnets only**.  
- Do **not** trick real users into interacting with honeypots.  
- Keep private keys and \`.env\` files safe.  
- Drosera nodes will ignore local JS scripts; only the Drosera-compliant trap is relevant in production.  

---

## ✅ Summary

- \`HoneypotTrap.sol\`: simple PoC with Hardhat.  
- \`DroseraHoneypotTrap.sol\`: Drosera-ready trap implementing \`ITrap\`.  
- \`drosera.toml\`: defines how the trap is run in Drosera.  
- Local validation with Hardhat, full integration tested via \`drosera run\`.  

---.
