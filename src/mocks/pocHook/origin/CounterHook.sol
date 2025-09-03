// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    BaseHook,
    IHooks,
    Hooks
} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {
    PoolKey,
    PoolId,
    PoolIdLibrary
} from "@uniswap/v4-core/src/types/PoolId.sol";

contract CounterHook is BaseHook{
    using PoolIdLibrary for PoolKey;
    uint256 counter;

    event Counted(bytes32 poolId ,uint256 indexed counter);

    constructor(IPoolManager _manager) BaseHook(_manager){}

    function getHookPermissions() public pure virtual override returns (Hooks.Permissions memory){
        return Hooks.Permissions({
            beforeInitialize:false,
            afterInitialize:true, // Incremements the counter by 1
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

    function _afterInitialize(
        address,
        PoolKey calldata poolKey,
        uint160, int24
        ) internal virtual override returns (bytes4) {
            counter++;
            // emit Counted(PoolId.unwrap(PoolKey.toId()), counter);
            return IHooks.afterInitialize.selector;
    }
}