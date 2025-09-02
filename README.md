# Reactive Hook Plugins

A sophisticated, upgradeable smart contract system that implements reactive components for DeFi hooks using the Beacon Proxy pattern and reactive callback compliance.


## Set Up


clone the repo and run 
```sh

cast wallet import reactiveHookPlugins --interactive
history -c && history -w  # Bash/Zsh
```

## 🎯 Overview

The ReactiveHook lies on the destination chain, An original Hook is designed to react to before/After poolManager actions, such as donations, swaps and liquidity provision.

The idea is that the ReactiveHook can react to events emitted by the PoolManager but for other Pools and/or other protocols.        

This is where the BeaconPattern comes into play.


The hook:

- Defines a set of connected interfaces, and events that belong to those interfaces that are already deployed on the origin chain. (This reactive contracts are Proxy contracts and are deployed on the reactive network )


- Deploys a custom reactive contract that reacts to such events defined.

## ✨ Features

- **Beacon Proxy Architecture**: Centralized upgrade management through a beacon contract
- **Reactive Components**: Each component implements reactive callback compliance
- **Extension Factory Pattern**: Streamlines extension deployment

## 🚀 Use Cases


### APR Calculation
- On-chain APR computation without off-chain dependencies
- Real-time yield optimization
- Dynamic fee structure based on performance

### LP Metrics
- Liquidity provider performance tracking
- Impermanent loss calculations
- Risk assessment metrics

### Custom Extensions
