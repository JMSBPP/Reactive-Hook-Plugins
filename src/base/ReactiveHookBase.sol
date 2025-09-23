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
// This is a Beacon becuase is one implementation that deploys and manages multiple ReactivePlugins
// which aime to be minimal and upgradable

abstract contract ReactiveHookBase is IReactiveHooks, AbstractCallback, BaseHook, UpgradeableBeacon {
    using EnumerableSet for EnumerableSet.AddressSet;


    EnumerableSet.AddressSet private _extensions;

    struct Extension{
        address executor;
        EventKey eventKey;
        EventData eventData;
    }


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
        EventData memory eventData
    ) external {
        EventKey eventKey = EventKeyLibrary.toEventKey(chainId, originContract, uint256(eventSelector));
        Extension memory extension = Extension(executor, eventKey, eventData);

        Calldata memory callData = _setExtension(extension);
        _extensions.add(executor);
        emit RequestReactivePlugin(this, eventKey, eventData, callData);
    }


    function _setExtension(
        Extension memory extension
    ) internal virtual returns(Calldata memory) {
    
    }
    
    

    
    fallback() external payable {
        // TODO: This is the entry point for all 
        // Reactive plugin calls, as it uses the fallbackl extention patter to delegate the 
        // call to the entity that needs to handle the call 
        // TODO: This needs to be protected so is only callable by ReactivePlugin's related workflows
        Calldata memory callData = abi.decode(msg.data, (Calldata));
        address executor = _extensions.contains(callData.executor);
        if (executor == address(0x00)) {
            revert ExtensionNotRegistered(callData.executor);
        }
        executor.functionCall(callData.callData);
    }
}

