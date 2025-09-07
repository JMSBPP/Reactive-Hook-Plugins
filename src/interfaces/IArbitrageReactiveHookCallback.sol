// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {BeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";

interface IArbitrageReactiveHookCallback{
    function arbitrageSwap(uint160) external returns(BeforeSwapDelta);
}