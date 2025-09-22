// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    IReactivePlugin,
    IReactive
} from "./IReactivePlugin.sol";


// TODO: This is the PK of the Log-record
// struct OriginEndpoint{
//     uint256 chain_id;
//     address contract;

// }

// struct LogRecord {
//     uint256 chain_id;
//     address _contract;
//     uint256 topic_0;
//     uint256 topic_1;
//     uint256 topic_2;
//     uint256 topic_3;
//     bytes data;
//     uint256 block_number;
//     uint256 op_code;
//     uint256 block_hash;
//     uint256 tx_hash;
//     uint256 log_index;
// }



// encoded function call is: contract | call | args, this means that the reactive hook needs to decode the function call and call the function with the args
// and how is the storage for the contract to call? (transient, permanent)
// At a first glance it seens like if the call is causal is transient, but if it requires statet changes or informational, it can be time for a persistant storage on
// the hook side

interface IReactivePluginFactory {

      
    function createReactivePlugin(
        bytes memory data
    )external returns(IReactivePlugin);    
    
    // TODO: This removes the plugin from the hook; thus this reactive component no longer governs any of the hook data, or behavior
    
    function removePlugin(IReactivePlugin plugin) external;
}