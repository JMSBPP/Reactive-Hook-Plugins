// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AbstractReactive} from "@reactive-network/abstract-base/AbstractReactive.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {IReactiveHooks} from "./interfaces/IReactiveHooks.sol";
import {IReactivePlugin} from "./interfaces/IReactivePlugin.sol";

// TODO: This aims to be:
// - minimally customizable hook contract
// - upgradable by governance
// 

// The beacon here is the same callback contract
contract ReactivePlugin is IReactivePlugin, AbstractReactive, BeaconProxy {

    constructor(
        IReactiveHooks reactiveHook,
        bytes memory data
    ) BeaconProxy(address(reactiveHook), data) {}



}
