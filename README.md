
# Honeypot Trap — Hardhat PoC

This project implements a simple Honeypot Trap contract to capture addresses that attempt to "exploit" a fake withdraw function. Use it as a base for your Drosera Sergeant PoC.

## What it does

- Deploys a contract that looks "vulnerable" (a `withdraw()` function). Instead of paying callers, it flags them as attackers and emits an event.
- Contract accepts ETH so it _appears_ funded.

## Quick start

1. Install dependencies

```bash
npm install
```

2. Create a `.env` file copying `.env.example` and fill your Sepolia RPC endpoint and your deployer private key.

3. Compile

```bash
npm run compile
```

4. Run tests (local)

```bash
npm test
```

5. Deploy to Sepolia

```bash
npm run deploy:sepolia
```
