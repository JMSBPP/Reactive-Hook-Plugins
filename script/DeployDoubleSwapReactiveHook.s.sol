// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {Script} from "forge-std/Script.sol";
import {MockDoubleSwapReactiveHook} from "../test/mocks/MockDoubleSwapReactiveHook.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

import {IUniversalRouter} from "@uniswap/universal-router/interfaces/IUniversalRouter.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ISystemContract} from "@reactive-network/interfaces/ISystemContract.sol";
import {console2} from "forge-std/console2.sol";

import {IReactiveHooks} from "../src/interfaces/IReactiveHooks.sol";

contract DeployDoubleSwapReactiveHook is Script {

    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    function setUp() public {}

    function run() public returns (IReactiveHooks, uint256){
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        
        // Get addresses from environment variables
        address poolManager = vm.envAddress("SEPOLIA_POOL_MANAGER");
        address swapRouter = vm.envAddress("SEPOLIA_UNIVERSAL_ROUTER");
        address systemContract = vm.envAddress("SEPOLIA_CALLBACK_PROXY_ADDR");

        uint160 flags = uint160(
            Hooks.AFTER_INITIALIZE_FLAG
        );

        bytes memory constructorArgs = abi.encode(
            systemContract,
            IPoolManager(poolManager),
            IUniversalRouter(swapRouter)
        );

        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, type(MockDoubleSwapReactiveHook).creationCode, constructorArgs);


        vm.startBroadcast(privateKey);

        MockDoubleSwapReactiveHook hook = new MockDoubleSwapReactiveHook{salt: salt}(
            systemContract,
            IPoolManager(poolManager),
            IUniversalRouter(swapRouter)
        );
        console2.log("Hook deployed:", address(hook));

        vm.stopBroadcast();

        return (IReactiveHooks(address(hook)), block.number);
    }
}