// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {StdAssertions} from "forge-std/StdAssertions.sol";
import {console2} from "forge-std/Test.sol";

import {CounterHook} from "../../../src/mocks/pocHook/origin/CounterHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import "./SepoliaLasnaConstants.sol";



import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";

contract SepoliaDeployPocHook is Script, StdAssertions {

    function run() public {
        vm.chainId(SEPOLIA_CHAIN_ID);
        address hookAddress = DevOpsTools.get_most_recent_deployment("CounterHook", block.chainid);
        bytes32 salt;
        
        // TODO: There needs to be control over not deploying this twice
        // if (hookAddress == address(0)){
        uint256 sepoliaForkId = vm.createSelectFork("sepolia");
        // NOTE: The vm.addr(1) does not return my imported reactiveHookPlugins
        // account address
        if (hookAddress == address(0x00)){
            vm.startBroadcast();
    
                //=======ORIGIN DEPLOYMENT: HOOK==========
            uint160 flags = uint160(
                Hooks.AFTER_INITIALIZE_FLAG
            );

            bytes memory constructorArgs = abi.encode(POOL_MANAGER);
                
            (hookAddress,salt) = HookMiner.find(
                CREATE2_DEPLOYER,
                flags,
                type(CounterHook).creationCode,
                constructorArgs
            );

            // TODO: We are missing logic for
            // verifying the contract here instead of doing it on the command line
            // Also how can he use the rpcUrl here to avoid using it as a flag when running forge
            // script
            CounterHook counterHook = new CounterHook{salt: salt}(
                IPoolManager(POOL_MANAGER)
            );
            require(address(counterHook) == hookAddress, "CounterHookScript: Hook address missmatch");
            vm.stopBroadcast();
        
        }
        
 
   }



}