// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    IReactivePlugin,
    IReactive
} from "./IReactivePlugin.sol";
import {EventKey} from "../types/EventKey.sol";
import {IReactiveHooks} from "./IReactiveHooks.sol";

interface IReactivePluginFactory {


    event ReactivePluginDeployed(
        IReactiveHooks indexed reactiveHook,
        EventKey indexed eventKey,
        EventData data,
        Calldata callData
    );
      
    function createReactivePlugin(
        EventKey eventKey,        
        bytes memory data
    )external;    
    
    // TODO: This removes the plugin from the hook; thus this reactive component no longer governs any of the hook data, or behavior
    
    function removePlugin(IReactivePlugin plugin) external;

    function getPlugin(EventKey eventKey) external view returns(IReactivePlugin);
}