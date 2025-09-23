// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EventKey} from "./EventKey.sol";

struct EventData{
    uint256 topic1;
    uint256 topic2;
    uint256 topic3;
    bytes data;
}

type EventId is uint256;

library EventIdLibrary {
    function toEventId(
        EventKey eventKey,
        EventData memory eventData
    ) internal pure returns (EventId) {
        return EventId.wrap(
            uint256(keccak256(abi.encode(eventKey, eventData)))
        );
    }
}


