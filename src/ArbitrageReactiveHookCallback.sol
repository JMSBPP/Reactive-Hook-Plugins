// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {IArbitrageReactiveHookCallback} from "./interfaces/IArbitrageReactiveHookCallback.sol";
import {
    BaseHook,
    IHooks,
    Hooks
} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {AbstractCallback} from "@reactive-network/abstract-base/AbstractCallback.sol";



// NOTE: tHE BEAUTY OF THIS
abstract contract ArbitrageReactiveHookCallback is IArbitrageReactiveHookCallback,BaseHook, AbstractCallback{}