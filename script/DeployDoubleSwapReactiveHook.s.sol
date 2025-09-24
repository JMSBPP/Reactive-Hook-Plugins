// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {Script} from "forge-std/Script.sol";
import {MockDoubleSwapReactiveHook} from "../test/mocks/MockDoubleSwapReactiveHook.sol";
import {HookMiner} from "../src/utils/HookMiner.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

contract DeployDoubleSwapReactiveHook is Script {

    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
    IPoolManager constant POOLMANAGER = IPoolManager(address(0xE03A1074c86CFeDd5C142C4F04F1a1536e203543));
    

    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address callbackSender = vm.envAddress("CALLBACK_SENDER");

        uint160 flags = uint160(
            Hooks.AFTER_INITIALIZE_FLAG
        );

        bytes memory constructorArgs = abi.encode(callbackSender, POOLMANAGER);

        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, type(MockDoubleSwapReactiveHook).creationCode, constructorArgs);


        vm.startBroadcast(privateKey);
        MockDoubleSwapReactiveHook hook = new MockDoubleSwapReactiveHook{salt: salt}(callbackSender, poolManager, v4Router);
        console2.log("Hook deployed:", address(hook));

        vm.stopBroadcast();
    }
}