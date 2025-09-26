// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {Script} from "forge-std/Script.sol";
import {ReactivePluginFactory} from "../src/ReactivePluginFactory.sol";
import {IReactiveHooks} from "../src/interfaces/IReactiveHooks.sol";
import {MockDoubleSwapReactiveHook} from "../test/mocks/MockDoubleSwapReactiveHook.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUniversalRouter} from "@uniswap/universal-router/interfaces/IUniversalRouter.sol";
import {ISystemContract} from "@reactive-network/interfaces/ISystemContract.sol";
import {console2} from "forge-std/console2.sol";

import {DevOpsTools} from "@Cyfrin/foundry-devops/DevOpsTools.sol";

import {DeployDoubleSwapReactiveHook} from "./DeployDoubleSwapReactiveHook.s.sol";

contract DeployReactivePluginFactory is Script {

    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    function setUp() public {}


    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        uint256 chainId = vm.envUint("SEPOLIA_CHAIN_ID");
        
        // For reactive-testnet, we need to deploy a ReactiveHook first
        // Let's check if there's already a deployment
        address latestReactiveHook;
        try DevOpsTools.get_most_recent_deployment("MockDoubleSwapReactiveHook", chainId) returns (address hook) {
            latestReactiveHook = hook;
            console2.log("Found existing ReactiveHook:", latestReactiveHook);
        } catch {

            console2.log("No existing ReactiveHook found, deploying new one...");
            

            vm.startBroadcast(privateKey);

            DeployDoubleSwapReactiveHook deployDoubleSwapReactiveHook = new DeployDoubleSwapReactiveHook();
            (IReactiveHooks reactiveHook, uint256 blockNumber) = deployDoubleSwapReactiveHook.run();

            latestReactiveHook = address(reactiveHook);

            console2.log("Deployed new ReactiveHook:", latestReactiveHook);
            
            vm.stopBroadcast();
            
            run();
        }

        // Now deploy the ReactivePluginFactory
        vm.startBroadcast(privateKey);

        ReactivePluginFactory reactivePluginFactory = new ReactivePluginFactory(IReactiveHooks(latestReactiveHook), chainId);
        
        console2.log("Deployed ReactivePluginFactory:", address(reactivePluginFactory));
        
        vm.stopBroadcast();
    }
}