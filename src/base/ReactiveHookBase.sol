// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {AbstractCallback} from "@reactive-network/abstract-base/AbstractCallback.sol";
import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {EventKey, EventKeyLibrary} from "../types/EventKey.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {IReactiveHooks} from "../interfaces/IReactiveHooks.sol";
import {ReactivePluginFactory} from "../ReactivePluginFactory.sol";
import {IReactivePlugin} from "../interfaces/IReactivePlugin.sol";
import {EventData} from "../types/EventId.sol";
import {Calldata} from "../types/Calldata.sol";
// TODO: This aims to be:
// - governances reole based
// - It needs to  

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
// This is a Beacon becuase is one implementation that deploys and manages multiple ReactivePlugins
// which aime to be minimal and upgradable

abstract contract ReactiveHookBase is IReactiveHooks, AbstractCallback, BaseHook {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EventKeyLibrary for EventKey;
    using Address for address;






    ReactivePluginFactory public immutable REACTIVE_PLUGIN_FACTORY;
    
    constructor(
        address _callback_sender,
        IPoolManager _manager
    ) AbstractCallback(_callback_sender) BaseHook(_manager) {
    }
    



    function deployReactivePlugin(
        uint256 chainId,
        address executor,
        address originContract,
        uint256 topic0,
        EventData memory eventData
    ) external {
        EventKey eventKey = EventKeyLibrary.toEventKey(chainId, originContract, topic0);

        Calldata memory callData = _setCallData();
        emit RequestReactivePlugin(
            eventKey.chainId(),
            eventKey.contractAddress(),
            eventKey.topic0(),
            eventData.topic1,
            eventData.topic2,
            eventData.topic3,
            eventData.data,
            callData
        );
    }


    function _setCallData( ) internal virtual returns(Calldata memory) {
    
    }
    
    

    
    fallback() external payable {
        // TODO: This is the entry point for all 
        // Reactive plugin calls, as it uses the fallbackl extention patter to delegate the 
        // call to the entity that needs to handle the call 
        // TODO: This needs to be protected so is only callable by ReactivePlugin's related workflows
        Calldata memory _callData = abi.decode(msg.data, (Calldata));
        _callData.executor.functionCall(_callData.callData);
    }
}

