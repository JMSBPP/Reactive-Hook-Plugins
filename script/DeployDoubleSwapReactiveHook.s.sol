// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {Script} from "forge-std/Script.sol";
import {MockDoubleSwapReactiveHook} from "../test/mocks/MockDoubleSwapReactiveHook.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IUniversalRouter} from "@uniswap/universal-router/interfaces/IUniversalRouter.sol";

import {console2} from "forge-std/console2.sol";

import {IReactiveHooks} from "../src/interfaces/IReactiveHooks.sol";

contract DeployDoubleSwapReactiveHook is Script {

    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
    IPoolManager constant POOL_MANAGER = IPoolManager(address(0xE03A1074c86CFeDd5C142C4F04F1a1536e203543));
    IUniversalRouter constant SWAP_ROUTER = IUniversalRouter(address(0x3A9D48AB9751398BbFa63ad67599Bb04e4BdF98b));

    function setUp() public {}

    function run() public returns (IReactiveHooks, uint256){
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address callbackSender = vm.envAddress("CALLBACK_SENDER");
        // NOTE: This part of the contract

        uint160 flags = uint160(
            Hooks.AFTER_INITIALIZE_FLAG
        );

        bytes memory constructorArgs = abi.encode(callbackSender, POOL_MANAGER);

        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, type(MockDoubleSwapReactiveHook).creationCode, constructorArgs);


        vm.startBroadcast(privateKey);

        MockDoubleSwapReactiveHook hook = new MockDoubleSwapReactiveHook{salt: salt}(
            callbackSender,
            POOL_MANAGER,
            SWAP_ROUTER
        );

        console2.log("Hook deployed:", address(hook));

        vm.stopBroadcast();

        return (IReactiveHooks(address(hook)), block.number);
    }
}