// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {IReactivePluginFactory} from "./interfaces/IReactivePluginFactory.sol";
import {IReactiveHooks} from "./interfaces/IReactiveHooks.sol";
import {
    ReactivePlugin,
    IReactivePlugin
} from "./ReactivePlugin.sol";
import {EventKey, EventKeyLibrary} from "./types/EventKey.sol";
import {EventData} from "./types/EventId.sol";
import {Calldata} from "./types/Calldata.sol";


import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AbstractReactive} from "@reactive-network/abstract-base/AbstractReactive.sol";


contract ReactivePluginFactory is IReactivePluginFactory, AbstractReactive {
    using EventKeyLibrary for EventKey;
    using EnumerableMap for EnumerableMap.Bytes32ToAddressMap;

    uint256 public constant REQUEST_REACTIVE_PLUGIN_TOPIC0 = 0x6e2e2c2b1e1b324f4ba83e6e8d3d11e516be037bb7ee2343d0853788c768f5ad;

    mapping(EventKey => EnumerableSet.BytesSet Calldata) internal eventCalls;
    EnumerableMap.Bytes32ToAddressMap internal eventPlugins;

    IReactiveHooks public immutable REACTIVE_HOOK;
    
    constructor(
        IReactiveHooks _reactiveHook,
        uint256 chainId 

    ) {
        REACTIVE_HOOK = _reactiveHook;
        if (!vm) {
            service.subscribe(
                chainId,
                address(_reactiveHook),
                REQUEST_REACTIVE_PLUGIN_TOPIC0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }

    function _createReactivePlugin(
        EventKey eventKey,
        EventData memory eventData,
        Calldata memory callData
    ) internal {
    
        ReactivePlugin plugin = new ReactivePlugin(REACTIVE_HOOK,eventKey, eventData, callData);
        eventPlugins.set(bytes32(uint256(EventKey.unwrap(eventKey))), address(plugin));
        emit ReactivePluginDeployed(REACTIVE_HOOK, eventKey, eventData, callData);
     }

    function _removePlugin(EventKey eventKey) internal {
        eventPlugins.remove(bytes32(uint256(EventKey.unwrap(eventKey))));
    }


    function getPlugin(EventKey eventKey) external view returns(IReactivePlugin) {
        return _getPlugin(eventKey);
    }


    function _getPlugin(EventKey eventKey) internal view returns(IReactivePlugin) {
        bytes32 unwrappedEventKey =bytes32(uint256(EventKey.unwrap(eventKey)));
        return IReactivePlugin(payable(eventPlugins.get(unwrappedEventKey)));
    } 


    function react(LogRecord calldata log) external {
    
        if (
            log.topic_0 == REQUEST_REACTIVE_PLUGIN_TOPIC0 &&
            log._contract == address(REACTIVE_HOOK) 
        ) 
        {
            EventKey eventKey = EventKeyLibrary.toEventKey(log.chain_id, log._contract, log.topic_0);
            EventData memory eventData = EventData(log.topic_1, log.topic_2, log.topic_3, log.data);
            (bytes memory remainingEventData, Calldata memory callData) = abi.decode(log.data, (bytes, Calldata));
            _createReactivePlugin(eventKey, eventData, callData);
        }
    
    }




}