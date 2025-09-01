// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";


uint256 constant LASNA_CHAIN_ID = uint256(0xaa36a7);
uint256 constant SEPOLIA_CHAIN_ID = uint256(5318007);
address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
address constant POOL_MANAGER = address(IPoolManager(0xE03A1074c86CFeDd5C142C4F04F1a1536e203543));
address constant CALLBACK_PROXY_SEPOLIA = address(0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA);
address constant CALLBACK_PROXY_LASNA  = address(0x0000000000000000000000000000000000fffFfF);
address constant SEPOLIA_LASNA_FAUCET = address(0x9b9BB25f1A81078C544C829c5EB7822d747Cf434);
