# Crop Insurance Pool

A decentralized insurance pool for crop farmers built on the Stacks blockchain.

## Overview

This smart contract implements a decentralized insurance pool where farmers can:
- Join the pool by paying a premium in STX
- Receive coverage worth 3x their premium amount
- File claims to receive payouts in case of crop damage/loss

## Features

- Minimum premium requirement to prevent spam
- Configurable payout multiplier
- Protection against double claims
- Pool balance tracking
- Owner-only administrative functions

## How it works

1. Farmers join by paying a premium (minimum 100 STX)
2. Coverage amount is calculated as premium * multiplier
3. In case of crop damage, farmers can file claims
4. Valid claims receive instant payouts from the pool

The contract maintains a pool of funds and tracks all insurances and claims to ensure fair operation.
