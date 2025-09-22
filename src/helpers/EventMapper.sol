// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import {IReactive} from "@reactive-network/interfaces/IReactive.sol";
import {PredicateHelper} from "./PredicateHelper.sol";
import {EventKey, EventKeyLibrary} from "../types/EventKey.sol";
import {IReactivePlugin} from "../interfaces/IReactivePlugin.sol";

abstract contract EventMapper is PredicateHelper{
    using EventKeyLibrary for EventKey;

    // This needs to be a enumerable mapping
    mapping(EventKey => bytes) public eventCalls;
    mapping(EventKey => IReactivePlugin) public eventPlugins;

    // TODO: This function defines the offsets based on custom criteria between the event and the function
    // call args

    function _setEventCall(
        EventKey eventKey,
        bytes memory callData
    ) internal {
        eventCalls[eventKey] = callData;
    }

    function _getEventCall(
        EventKey eventKey
    ) internal view returns(bytes memory) {
        return eventCalls[eventKey];
    }
    

}