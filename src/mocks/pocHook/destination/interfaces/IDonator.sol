// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

interface IDonator{

    function donate(
        address callbackSender,
        PoolKey memory poolKey,
        uint256 amount0,
        uint256 amount1,
        bytes memory hookData
    ) external returns (BalanceDelta delta);
}