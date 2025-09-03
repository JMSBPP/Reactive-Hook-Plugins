// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;


import {
    IReactive,
    AbstractPausableReactive
} from "@reactive-network/abstract-base/AbstractPausableReactive.sol";

import {PoolKey,PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {
    EnumerableMap,
    EnumerableSet
} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

// Taken from:
// -> https://dev.reactive.network/subscriptions#dynamic-subscriptions

// NOTE: Subscriptions in the Reactive Network are 
// managed through the system contract, 
// which is accessible only from the network

// NOTE: Events are sent to the ReactVM's contract copy,
// which has no direct access to the system contract. 
// Therefore, dynamic subscriptions and unsubscriptions
// based on incoming events must be handled via callbacks.



//  * - `bytes32 -> address` (`Bytes32ToAddressMap`) since v5.1.0

abstract contract ArbitrageReactiveHookSubscriptionManager is AbstractPausableReactive{
    using EnumerableMap for EnumerableMap.Bytes32ToAddressMap;

    // NOTE: The keys are the poolId's and the values are
    // the IHooks addresses
    EnumerableMap.Bytes32ToAddressMap private hookRegistry;


    // One P
}






