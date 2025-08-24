// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {CustomRevert} from "@uniswap/v4-core/src/libraries/CustomRevert.sol";
import {ImmutableState} from "@uniswap/v4-periphery/src/base/ImmutableState.sol";


import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";



abstract contract BaseHookSubscriptionManager is Context, ImmutableState, UpgradeableBeacon{
    using Address for address;
    using Hooks for IHooks;
    using CustomRevert for bytes4;
    using StateLibrary for IPoolManager;
    using PoolIdLibrary for PoolKey;


    constructor(
        IPoolManager _manager,
        PoolKey memory poolKey
    ) 
    
    UpgradeableBeacon(address(poolKey.hooks), _msgSender())
    ImmutableState(_manager)
    
    {
        if (!poolKey.hooks.isValidHookAddress(poolKey.fee)) Hooks.HookAddressNotValid.selector.revertWith(address(poolKey.hooks));
    }
    
}
