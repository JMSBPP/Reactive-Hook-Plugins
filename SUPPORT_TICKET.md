# Reactive Network Support Ticket

## Issue Summary
**Title**: Persistent "replacement transaction underpriced" error blocking contract deployments on reactive-testnet (Lasna)

**Severity**: High - Blocking all contract deployments

**Date**: September 26, 2025

## Problem Description
Unable to deploy contracts to reactive-testnet due to a persistent "replacement transaction underpriced" error that blocks all new transactions, even with extremely high gas prices.

## Error Details
```
Error: server returned an error response: error code -32000: replacement transaction underpriced
Details: {
  "code": "ErrFailsafeRetryExceeded",
  "message": "gave up retrying on network-level after 4.17266ms",
  "details": {
    "durationMs": 4,
    "cause": {
      "code": "ErrUpstreamRequest",
      "message": "failed to make request to upstream",
      "details": {
        "attempts": 1,
        "retries": 0,
        "hedges": 0,
        "upstreamId": "prq-dc1-0",
        "durationMs": 3,
        "networkId": "evm:5318007",
        "method": "eth_sendRawTransaction"
      },
      "cause": {
        "code": "ErrEndpointServerSideException",
        "message": "an internal error on remote endpoint",
        "cause": {
          "code": "ErrJsonRpcExceptionInternal",
          "message": "replacement transaction underpriced",
          "details": {
            "statusCode": 200,
            "headers": {
              "date": "Fri, 26 Sep 2025 13:46:47 GMT",
              "content-length": "108",
              "content-type": "application/json"
            },
            "data": null,
            "originalCode": -32000,
            "normalizedCode": -32000
          }
        }
      }
    }
  }
}
```

## System Information
- **Account Address**: `0xBD8A7d2a59C7452b411f01797fd82f8270aefFF3`
- **Current Balance**: `756281162861000000` wei (0.756 ETH)
- **Current Nonce**: `4`
- **Chain ID**: `5318007` (reactive-testnet/Lasna)
- **RPC URL**: `https://lasna-rpc.rnk.dev/`
- **Forge Version**: `1.3.1-stable`
- **Build Date**: August 15, 2025

## Attempted Solutions
1. **Various Gas Prices**: Tried gas prices from 1 Gwei to 100,000 Gwei
2. **Different Gas Limits**: Tested limits from 1M to 3M gas
3. **Legacy Transactions**: Used `--legacy` flag
4. **Different Nonces**: Attempted nonces 3, 4, 5, 6, 7
5. **Different Transaction Types**: Tried both `forge create` and `forge script`
6. **Wait Periods**: Waited 30+ minutes between attempts

## Commands That Failed
```bash
# Basic deployment attempt
forge create src/ReactivePluginFactory.sol:ReactivePluginFactory \
  --broadcast \
  --rpc-url https://lasna-rpc.rnk.dev/ \
  --chain-id 5318007 \
  --private-key $PRIVATE_KEY \
  --constructor-args 0x0000000000000000000000000000000000000000 5318007

# High gas price attempt
forge create src/ReactivePluginFactory.sol:ReactivePluginFactory \
  --legacy \
  --broadcast \
  --rpc-url https://lasna-rpc.rnk.dev/ \
  --chain-id 5318007 \
  --private-key $PRIVATE_KEY \
  --gas-price 100000000000 \
  --gas-limit 1000000 \
  --constructor-args 0xf314e6bff0250e7e489e8337c129006178101000 11155111
```

## RPC Endpoint Status
- **Basic Queries Work**: `eth_chainId`, `eth_getBalance`, `eth_getBlockByNumber` all work
- **Transaction Count Issues**: `eth_getTransactionCount` sometimes returns empty responses
- **Transaction Sending**: `eth_sendRawTransaction` consistently fails with "replacement transaction underpriced"

## Expected Behavior
Should be able to deploy contracts to reactive-testnet using standard Forge commands.

## Actual Behavior
All deployment attempts fail with "replacement transaction underpriced" error, suggesting a stuck transaction is blocking new deployments.

## Impact
- **High**: Cannot deploy any contracts to reactive-testnet
- **Blocking**: All development work on reactive-testnet is halted
- **Workaround**: Currently deploying to Sepolia instead

## Additional Context
- Successfully deployed the same contract to Sepolia (Chain ID: 11155111)
- The issue appears to be specific to reactive-testnet infrastructure
- Account has sufficient balance (0.756 ETH)
- No issues with other EVM networks

## Request
Please investigate and resolve the "replacement transaction underpriced" error on reactive-testnet that is preventing contract deployments.

## Contact Information
- **Project**: Reactive Hook Plugins
- **Repository**: Reactive-Hook-Plugins
- **Account**: 0xBD8A7d2a59C7452b411f01797fd82f8270aefFF3

---
**Ticket Created**: September 26, 2025
**Status**: Open
**Priority**: High
