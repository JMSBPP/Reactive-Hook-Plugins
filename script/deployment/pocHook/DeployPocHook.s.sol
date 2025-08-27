// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/Test.sol";

import {CounterHook} from "../../../src/mocks/pocHook/origin/CounterHook.sol";
import {DonatorCallback} from "../../../src/mocks/pocHook/destination/DonatorCallback.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "@unsiwap/v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

contract SepoliaDeployPocHook is Script{
    //TODO: These are placeholders for compilation before commiting
    // changes, these are not the addresses of the contracts on 
    // sepolia ...
    address constant CREATE2_DEPLOYER = address(0x123);
    address constant POOL_MANAGER = IPoolManager(0x456);

    
    DonatorCallback private donatorCallback;

    function run() public {
        address hookAddress;
        // TODO: There needs to be control over not deploying this twice
        {
            //=======ORIGIN DEPLOYMENT: HOOK==========
            uint160 flags = uint160(
                Hooks.BEFORE_INITIALIZE_FLAG
            );

            bytes memory constructorArgs = abi.encode(POOL_MANAGER);
            
            (hookAddress, bytes32 salt) = HookMiner.find(
                CREATE2_DEPLOYER,
                flags,
                type(CounterHook).creationCode,
                constructorArgs
            );

            vm.broadcast(); 
        }

        CounterHook counterHook = new CounterHook{salt: salt}(
            IPoolManager(POOL_MANAGER)
        );

        require(address(counterHook) == hookAddress, "CounterHookScript: Hook address missmatch");
        
    }
}