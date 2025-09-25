# 🍯 Honeypot Trap Smart Contracts

This repository contains two related **honeypot trap smart contracts** designed to simulate and detect a fake withdrawal vulnerability, focusing on integration with the **Drosera** monitoring system.

| Contract | Purpose |
| :--- | :--- |
| **`HoneypotTrap.sol`** | The original **Hardhat proof-of-concept (PoC)** honeypot. |
| **`DroseraHoneypotTrap.sol`** | The **Drosera-compliant** version, implementing the `ITrap` interface for shadow-fork analysis. |

-----

## ✨ Concept: The Fake Withdraw Vulnerability

The trap simulates a **fake withdraw vulnerability** to catch would-be attackers:

  - An attacker calls the `withdraw()` function, believing they can drain funds.
  - The contract flags the caller as an attacker and records their address on-chain.
  - A `TrapTriggered` event is emitted.
  - The Drosera-compliant version exposes **`collect()`** and **`shouldRespond()`** methods, allowing Drosera nodes to monitor state changes (like a new attacker being flagged) and decide when to trigger a response.

-----

## 📂 Project Structure

This project follows a standard Hardhat structure, with an added configuration file for Drosera.

```
contracts/
├── HoneypotTrap.sol           # Original PoC (Hardhat)
└── DroseraHoneypotTrap.sol    # Drosera-compliant trap (implements ITrap)

scripts/
├── deploy.js                  # Hardhat deploy script (Sepolia)
└── test.js                    # Executes local tests

test/
└── honeypot.test.js           # Local Hardhat tests

drosera.toml                   # Drosera trap descriptor
.env.example
hardhat.config.js
package.json
```

-----

## ⚙️ Local Usage & Testing (Hardhat PoC)

### 1\. Setup

Start by installing dependencies and configuring your environment.

```bash
# Install dependencies
npm install

# Create a .env file from .env.example with your keys
# SEPOLIA_RPC=...
# PRIVATE_KEY=...
```

### 2\. Compile and Test

You can run both the PoC and the Drosera-compliant contract tests locally using Hardhat.

```bash
# Compile contracts
npx hardhat compile

# Run local tests (both PoC and Drosera-compliant)
npm test
```

### 3\. Test Examples

#### PoC Test (`HoneypotTrap.sol`)

This test ensures an attacker is flagged when they call `withdraw()`.

```javascript
// test/honeypot.test.js

// ... imports and describe block

  it("flags an attacker when withdraw is called", async function () {
    // ... deployment
    await trap.connect(attacker).withdraw();
    expect(await trap.attackers(attacker.address)).to.equal(true);
  });
```

#### Drosera-Compliant Test (`DroseraHoneypotTrap.sol`)

This test verifies the `collect`/`shouldRespond` flow works correctly by checking the state before and after a withdrawal attempt.

```javascript
// test/droseraHoneypot.test.js

// ... imports and describe block

  it("collect/shouldRespond flow works", async function () {
    // ... deployment
    const snap0 = await trap.collect();
    await trap.connect(attacker).withdraw();
    const snap1 = await trap.collect();

    const res = await trap.shouldRespond([snap0, snap1]);
    expect(res[0]).to.equal(true); // Should trigger a response
  });
```

-----

## 🔗 Drosera Integration

The core value of this repository is the **`DroseraHoneypotTrap.sol`**, which adheres to the `ITrap` interface for integration with the Drosera monitoring network.

### 1\. ITrap Interface

The Drosera-compliant contract implements:

```solidity
interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```

### 2\. `drosera.toml` Configuration

This file defines how the trap is deployed and monitored by the Drosera system.

```toml
[trap]
name = "DroseraHoneypotTrap"
description = "Honeypot trap that triggers when attackerCount increases"
contract = "contracts/DroseraHoneypotTrap.sol"
class = "DroseraHoneypotTrap"

[config]
network = "sepolia"
sample_size = 3
```

### 3\. Run with Drosera CLI

If you have the Drosera CLI installed, you can run the trap descriptor locally or against a Sepolia fork:

```bash
# Install CLI (if needed)
cargo install drosera-cli

# Run against a local shadow-fork
drosera run

# Run against a Sepolia fork
drosera run --network sepolia
```

**Expected Output (Example):**

```
✅ Trap DroseraHoneypotTrap initialized
📡 Collecting state...
⚡ shouldRespond() => true (triggered)
```

-----

## 🚀 Deployment

### Hardhat PoC Deployment

The PoC version can be deployed to Sepolia using the Hardhat script:

```bash
npm run deploy:sepolia
```

**Latest Sepolia Deployment (PoC):**
`0x4Ba8eca8966409AD866c82A78DeBD295b520720a`
[View on Etherscan](https://sepolia.etherscan.io/address/0x4Ba8eca8966409AD866c82A78DeBD295b520720a)

-----

## ⚠️ Notes & Ethics

  - This repository is for **research and testing on testnets only**.
  - Do **not** use this or similar contracts to trick or defraud real users.
  - The Drosera nodes will only interact with the `DroseraHoneypotTrap.sol` contract; local JS scripts are for validation only.

-----
