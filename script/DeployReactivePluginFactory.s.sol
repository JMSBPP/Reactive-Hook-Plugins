// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {Script} from "forge-std/Script.sol";
import {ReactivePluginFactory} from "../src/ReactivePluginFactory.sol";

import {console2} from "forge-std/console2.sol";
import {IReactivePluginFactory} from "../src/interfaces/IReactivePluginFactory.sol";
import {IReactiveHooks} from "../src/interfaces/IReactiveHooks.sol";


import {DevOpsTools} from "@Cyfrin/foundry-devops/DevOpsTools.sol";
import {DeployDoubleSwapReactiveHook} from "./DeployDoubleSwapReactiveHook.s.sol";

contract DeployReactivePluginFactory is Script {

    function setUp() public {}

    function run() public returns (IReactivePluginFactory,uint256) {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        
        address reactiveHook = DevOpsTools.get_most_recent_deployment(
            "MockDoubleSwapReactiveHook",
            block.chainid,
            "./broadcast"
        );

        if (reactiveHook == address(0x00)) {
            (IReactiveHooks reactiveHookContract, uint256 deploymentBlock) = DeployDoubleSwapReactiveHook.run();
            reactiveHook = address(reactiveHookContract);
        }


        ReactivePluginFactory reactivePluginFactory = new ReactivePluginFactory(
            IReactiveHooks(address(reactiveHook)), 
            block.chainid
        );


        console2.log("ReactivePluginFactory deployed:", address(reactivePluginFactory));
        vm.stopBroadcast();

        return (IReactivePluginFactory(address(reactivePluginFactory)), block.number);
    }
}