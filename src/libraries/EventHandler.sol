// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {IReactive} from "@reactive-network/interfaces/IReactive.sol";

struct FunctionCall{
    address callee;
    bytes4 selector;
    bytes args; // TODO: These are not the args values but 
}


//TODO: There needs to be a map from topic_0 to this struct
struct EventData{
    uint256 topic_1;
    uint256 topic_2;
    uint256 topic_3;
    bytes data;
}

library EventHandler{

    // TODO: This function needs to map the event data with specfici values of the fucntion call args ...
    function toFunctionCallArgs(EventData memory eventData, FunctionCall memory functionCall) internal pure returns(bytes memory args){
        // TODO: This needs to be implemented
    }
}

