// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IReactive} from "@reactive-network/interfaces/IReactive.sol";


library LogRecordLibrary{

//===============OPCODES REFERENCE==========
// LOG0 (0xA0): Creates a log record with zero topics.
// LOG1 (0xA1): Creates a log record with one topic.
// LOG2 (0xA2): Creates a log record with two topics.
// LOG3 (0xA3): Creates a log record with three topics.
// LOG4 (0xA4): Creates a log record with four topics.

    function numberOfTopics(
        IReactive.LogRecord memory logRecord
    ) internal pure returns (uint256 _numberOftopics) {
        uint256 opCode = logRecord.op_code;
        assembly ('memory-safe') {
            switch opCode
            case 0xA0 {
                _numberOftopics := 0
            }
            case 0xA1 {
                _numberOftopics := 1
            }
            case 0xA2 {
                _numberOftopics := 2
            }
            case 0xA3 {
                _numberOftopics := 3
            }
            case 0xA4 {
                _numberOftopics := 4
            }
            default {
                // Revert if the opcode is not a valid LOG opcode
                revert(0, 0)
            }
        }
    }

}