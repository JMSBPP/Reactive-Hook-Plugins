// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;


import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IReactive} from "@reactive-network/interfaces/IReactive.sol";
import {AbstractCallback} from "@reactive-network/abstract-base/AbstractCallback.sol";
import {
    BaseHook,
    IHooks,
    IPoolManager,
    Hooks
} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";

abstract contract ReactiveHook is AbstractCallback, BaseHook {

    //NOTE: Reactive contracts anre upgradable clones
    mapping(PoolKey poolKey => IReactive[]) dataFeeds;

    constructor(IPoolManager _manager) BaseHook(_manager){}

    function getHookPermissions() public pure virtual override returns (Hooks.Permissions memory){
        return Hooks.Permissions({
            beforeInitialize:false, 
            afterInitialize:true, // NOTE: Here it determines to which events it reacts to
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,   
            afterRemoveLiquidity:false,
            beforeSwap:false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });

    }


}


