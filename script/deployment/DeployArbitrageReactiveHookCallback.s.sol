// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;


import "forge-std/Script.sol";
import "./SepoliaLasnaConstants.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {ArbitrageReactiveHookCallback} from "../../src/ArbitrageReactiveHookCallback.sol";


contract DeployArbitrageReactiveHookCallback is Script{
    
    function run() public {
        uint160 flags = uint160(
            Hooks.BEFORE_INITIALIZE_FLAG   
        );

        bytes memory constructorArgs = abi.encode(
            CALLBACK_PROXY_SEPOLIA,
            IPoolManager(POOL_MANAGER)
        );

        (address hookAddress, bytes32 salt) = HookMiner.find(
            CREATE2_DEPLOYER,
            flags,
            type(ArbitrageReactiveHookCallback).creationCode,
            constructorArgs
        );

        vm.startBroadcast();

        ArbitrageReactiveHookCallback callbackHook = new ArbitrageReactiveHookCallback{salt: salt}(
            CALLBACK_PROXY_SEPOLIA,
            IPoolManager(POOL_MANAGER)
        );

    }
}
