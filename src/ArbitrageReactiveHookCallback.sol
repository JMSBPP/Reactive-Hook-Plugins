// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {IArbitrageReactiveHookCallback} from "./interfaces/IArbitrageReactiveHookCallback.sol";
import {
    BaseHook,
    IHooks,
    Hooks
} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";

import {
    PoolId,
    PoolIdLibrary
} from "@uniswap/v4-core/src/types/PoolId.sol";

import {AbstractCallback} from "@reactive-network/abstract-base/AbstractCallback.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import "@uniswap/v4-core/src/test/PoolSwapTest.sol";

// NOTE: tHE BEAUTY OF THIS
abstract contract ArbitrageReactiveHookCallback is IArbitrageReactiveHookCallback, BaseHook, AbstractCallback, PoolSwapTest{
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;
    


    error PoolAlreadyInitiated();

    PoolKey hookPoolKey;
    bool private initialized;

    constructor(
        IPoolManager _poolManager
    ) BaseHook(_poolManager){}


    function getHookPermissions() public pure virtual override returns (Hooks.Permissions memory){
        return Hooks.Permissions({
                beforeInitialize:true, //NOTE: Enforces the pool is only for the wanted currencies
                afterInitialize: false,
                beforeAddLiquidity: false,
                afterAddLiquidity: false, 
                beforeRemoveLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: false,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta:false,
                afterSwapReturnDelta:false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta:false
        });
    }
    //NOTE: THis before initialize can be used to do uni-chain arbitrage protection
    // using the price
    function _beforeInitialize(
        address,
        PoolKey calldata poolKey,
        uint160
    ) internal virtual override returns (bytes4) {
        if (!initialized){
            hookPoolKey = poolKey;
            hookPoolKey.hooks = IHooks(address(this));
            initialized = true;
        } else {
            revert PoolAlreadyInitiated();
        }
    }


    function arbitrageSwap(uint160 otherPoolsqrtPriceX96) external{
        (uint160  sqrtPriceX96, int24 tick, uint24 protocolFee, uint24 lpFee) = poolManager.getSlot0(hookPoolKey.toId());
    }

}