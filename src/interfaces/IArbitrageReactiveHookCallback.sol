// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;


interface IArbitrageReactiveHookCallback{
    function arbitrageSwap(uint160) external;
}