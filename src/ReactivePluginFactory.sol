// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {IReactivePluginFactory} from "./interfaces/IReactivePluginFactory.sol";
import {IReactiveHooks} from "./interfaces/IReactiveHooks.sol";
import {
    ReactivePlugin,
    IReactivePlugin
} from "./ReactivePlugin.sol";
import {EventKey, EventKeyLibrary} from "./types/EventKey.sol";


import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AbstractReactive} from "@reactive-network/abstract-base/AbstractReactive.sol";


contract ReactivePluginFactory is IReactivePluginFactory {
    using EventKeyLibrary for EventKey;
    using EnumerableMap for EnumerableMap.Bytes32ToAddressMap;



    mapping(EventKey => EnumerableSet.BytesSet Calldata) public eventCalls;
    EnumerableMap.Bytes32ToAddressMap public eventPlugins;


    
    IReactiveHooks public immutable REACTIVE_HOOK;
    
    constructor(
        IReactiveHooks _reactiveHook
    ) {
        REACTIVE_HOOK = _reactiveHook;
    }

    function createReactivePlugin(
        EventKey eventKey,
        EventData memory eventData,
        Calldata memory callData
    ) external {
    
        ReactivePlugin plugin = new ReactivePlugin(REACTIVE_HOOK,eventKey, eventData, callData);
        eventPlugins.set(bytes32(eventKey), address(plugin));
        emit ReactivePluginDeployed(REACTIVE_HOOK, eventKey, eventData, callData);
     }

    function removePlugin(IReactivePlugin plugin) external {}


    function _setEventCall(
        EventKey eventKey,
        bytes memory callData
    ) internal {
        eventCalls[eventKey] = callData;
    }

    function _getEventCall(
        EventKey eventKey
    ) internal view returns(bytes memory) {
        return eventCalls[eventKey];
    }


}