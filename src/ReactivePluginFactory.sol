// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {IReactivePluginFactory} from "./interfaces/IReactivePluginFactory.sol";
import {IReactiveHooks} from "./interfaces/IReactiveHooks.sol";
import {
    ReactivePlugin,
    IReactivePlugin
} from "./ReactivePlugin.sol";

contract ReactivePluginFactory is IReactivePluginFactory {
    
    IReactiveHooks public immutable REACTIVE_HOOK;
    
    constructor(IReactiveHooks _reactiveHook) {
        REACTIVE_HOOK = _reactiveHook;
    }

    function createReactivePlugin(
        bytes memory data
    ) external returns(IReactivePlugin) {
        ReactivePlugin plugin = new ReactivePlugin(REACTIVE_HOOK, data);
        return IReactivePlugin(address(plugin));
    }

    function removePlugin(IReactivePlugin plugin) external {}

}