// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IReactive ,LogRecordLibrary} from "./LogRecordLibrary.sol";
import {
    PoolId,
    PoolIdLibrary,
    PoolKey
} from "@uniswap/v4-core/src/types/PoolId.sol";

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {SafeCast} from "@uniswap/v4-core/src/libraries/SafeCast.sol";
 
library PoolManagerLogRecordLibrary{
    using SafeCast for uint256;
    using PoolIdLibrary for PoolKey;
    using PoolManagerLogRecordLibrary for IReactive.LogRecord;
    using LogRecordLibrary for IReactive.LogRecord;


    struct InitializeData{
        PoolId poolId;
        Currency currency0;
        Currency currency1;
        uint24 fee;
        int24 tickSpacing;
        IHooks hooks;
        uint160 sqrtPrice;
        int24 tick;
    }

    struct InitializeNonIndexedData{
        uint24 fee;
        int24 tickSpacing;
        IHooks hooks;
        uint160 sqrtPrice;
        int24 tick;
    }


    function poolManager(
        IReactive.LogRecord memory poolManagerLogRecord
    ) internal view returns(IPoolManager){
        // TODO: Checks to make sure is the address of the poolManager
        return IPoolManager(poolManagerLogRecord._contract);
    }

    function initializeData(
        IReactive.LogRecord memory poolManagerLogRecord
    ) internal view returns(InitializeData memory _initializeData){
        PoolId poolId = PoolId.wrap(bytes32(poolManagerLogRecord.topic_1));
        (Currency currency0, Currency currency1) = (
            Currency.wrap(address(uint256(poolManagerLogRecord.topic_2).toUint160())),
            Currency.wrap(address(uint256(poolManagerLogRecord.topic_3).toUint160()))
        );
        InitializeNonIndexedData memory _initializeNonIndexedData = abi.decode(
            poolManagerLogRecord.data,
            (InitializeNonIndexedData)
        );

        _initializeData = InitializeData({
            poolId: poolId,
            currency0: currency0,
            currency1: currency1,
            fee: _initializeNonIndexedData.fee,
            tickSpacing: _initializeNonIndexedData.tickSpacing,
            hooks: _initializeNonIndexedData.hooks,
            sqrtPrice: _initializeNonIndexedData.sqrtPrice,
            tick: _initializeNonIndexedData.tick
        });

    }

    function poolKey(
        IReactive.LogRecord memory poolManagerLogRecord
    ) internal view returns(PoolKey memory _poolKey){
        InitializeData memory _initializeData = poolManagerLogRecord.initializeData();
        _poolKey = PoolKey({
            currency0: _initializeData.currency0,
            currency1: _initializeData.currency1,
            fee: _initializeData.fee,
            tickSpacing: _initializeData.tickSpacing,
            hooks: _initializeData.hooks
        });
    }


// event ModifyLiquidity(
//     PoolId indexed id, 
//     address indexed sender, 
//     int24 tickLower, 
//     int24 tickUpper, 
//     int256 liquidityDelta, 
//     bytes32 salt
// );
    

    




}

// event Swap(
//     PoolId indexed id,
//     address indexed sender,
//     int128 amount0,
//     int128 amount1,
//     uint160 sqrtPriceX96,
//     uint128 liquidity,
//     int24 tick,
//     uint24 fee
// );

// event Donate(
//     PoolId indexed id, 
//     address indexed sender, 
//     uint256 amount0, 
//     uint256 amount1
// );


// struct LogRecord {
//     uint256 chain_id;
//     address _contract;
//     uint256 topic_0;
//     uint256 topic_1;
//     uint256 topic_2;
//     uint256 topic_3;
//     bytes data;
//     uint256 block_number;
//     uint256 op_code;
//     uint256 block_hash;
//     uint256 tx_hash;
//     uint256 log_index;
// }