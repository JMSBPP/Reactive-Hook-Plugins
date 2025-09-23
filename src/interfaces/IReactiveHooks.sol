// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {EventKey} from "../types/EventKey.sol";
import {EventData} from "../types/EventId.sol";
import {Calldata} from "../types/Calldata.sol";

interface IReactiveHooks is IHooks {


    event RequestReactivePlugin(
        IReactiveHooks indexed reactiveHook,
        EventKey eventKey,
        EventData eventData,
        Calldata callData
    );
    
    error ExtensionNotRegistered(address executor);
    function REACTIVE_CALLBACK() external view returns(bytes4);
}