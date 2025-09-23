// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IReactive} from "@reactive-network/interfaces/IReactive.sol";

interface IReactivePlugin is IReactive {
    error InvalidCalldataLength(bytes data);

    function setGasLimit(uint64 _gasLimit) external;
    function getGasLimit() external view returns(bytes32);
}