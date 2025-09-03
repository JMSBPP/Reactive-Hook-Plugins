// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IReactive ,LogRecordLibrary} from "./LogRecordLibrary.sol";



library PoolManagerLogRecordLibrary{
    using PoolManagerLogRecordLibrary for IReactive.LogRecord;
    using LogRecordLibrary for IReactive.LogRecord;


    struct InitializeData{
        uint24 fee;
        int24 tickSpacing;
        IHooks hooks;
        uint160 sqrtPrice;
        int24 tick;
    }

    struct InitializeFlatData{
        uint24 fee;
        int24 tickSpacing;
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
        _initializeData = abi.decode(
            poolManagerLogRecord.data,
            (InitializeData)
        );
    }

    function hook(
        IReactive.LogRecord memory poolManagerLogRecord
    ) internal view returns (IHooks _hook){
        _hook = poolManagerLogRecord.initializeData().hooks;
    }

    function initializeFlatData(
        IReactive.LogRecord memory poolManagerLogRecord
    ) internal view returns(InitializeFlatData memory _initializeFlatData){
        InitializeData memory _initializeData = poolManagerLogRecord.initializeData();
        _initializeFlatData = InitializeFlatData({
            fee: _initializeData.fee,
            tickSpacing: _initializeData.tickSpacing,
            sqrtPrice: _initializeData.sqrtPrice,
            tick: _initializeData.tick
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