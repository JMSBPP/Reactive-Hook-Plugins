// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {AbstractCallback} from "@reactive-network/abstract-base/AbstractCallback.sol";
import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

// TODO: This aims to be:
// - governances reole based
// - It needs to  
abstract contract ReactiveHookBase is AbstractCallback, BaseHook {
    constructor(address _callback_sender, IPoolManager _manager) AbstractCallback(_callback_sender) BaseHook(_manager) {}

    fallback() external payable {
        // TODO: This is the entry point for all 
        // Reactive plugin calls, as it uses the fallbackl extention patter to delegate the 
        // call to the entity that needs to handle the call 
        // TODO: This needs to be protected so is only callable by ReactivePlugin's related workflows
    }
}

