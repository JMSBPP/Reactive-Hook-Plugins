// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// uint32 chainId | uint160 contract | uint16 topic0

type EventKey is uint224;

library EventKeyLibrary {
    
    function toEventKey(uint256 _chainId, address _contractAddress, uint256 _topic0) internal pure returns (EventKey) {
        return EventKey.wrap(uint224(_chainId << 160 | uint160(_contractAddress) << 16 | _topic0));
    }

    function chainId(EventKey eventKey) internal pure returns (uint256) {
        return uint256(EventKey.unwrap(eventKey) >> 160);
    }

    function contractAddress(EventKey eventKey) internal pure returns (address) {
        return address(uint160(EventKey.unwrap(eventKey) >> 16));
    }
    
    function topic0(EventKey eventKey) internal pure returns (uint256) {
        return uint256(EventKey.unwrap(eventKey) & 0xFFFF);
    }


}