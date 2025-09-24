// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {EventKey} from "../types/EventKey.sol";
import {EventData} from "../types/EventId.sol";
import {Calldata} from "../types/Calldata.sol";


interface IReactiveHooks is IHooks{


    // The topic0 for this event is the keccak256 hash of the event signature:
    // "RequestReactivePlugin(address,(uint256,address,uint256),(bytes32,bytes32,bytes32,bytes32),(address,bytes))"
    // The canonical event signature is:
    // "RequestReactivePlugin(address,(uint256,address,uint256),(bytes32,bytes32,bytes32,bytes32),(address,bytes))"
    // topic0 = keccak256("RequestReactivePlugin(address,(uint256,address,uint256),(bytes32,bytes32,bytes32,bytes32),(address,bytes))")
    // topic0 = 0x6e2e2c2b1e1b324f4ba83e6e8d3d11e516be037bb7ee2343d0853788c768f5ad
    event RequestReactivePlugin(
        uint256 indexed chainId,           // From EventKey
        address indexed originContract,    // From EventKey  
        uint256 indexed topic0,           // From EventKey
        uint256  topic1,           // From EventData
        uint256  topic2,           // From EventData
        uint256  topic3,           // From EventData
        bytes data,                       // From EventData (non-indexed)
        Calldata callData                 // Non-indexed
    );
    
    error ExtensionNotRegistered(address executor);


    function deployReactivePlugin(
        uint256 chainId,
        address executor,
        address originContract,
        uint256 topic0,
        EventData memory eventData
    ) external;


}