// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AbstractReactive} from "@reactive-network/abstract-base/AbstractReactive.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {IReactiveHooks} from "./interfaces/IReactiveHooks.sol";
import {IReactivePlugin} from "./interfaces/IReactivePlugin.sol";
import {EventData} from "./types/EventId.sol";
import {Calldata} from "./types/Calldata.sol";
import {EventKey, EventKeyLibrary} from "./types/EventKey.sol";
import {PredicateHelper} from "./helpers/PredicateHelper.sol";
// TODO: This aims to be:
// - minimally customizable hook contract
// - upgradable by governance
// 

// The beacon here is the same callback contract



//NOTE: bytes20 + bytes4 is the lower bound of the calldata
// this means a call to a function with 0 args is 24 bytes


contract ReactivePlugin is IReactivePlugin, AbstractReactive, PredicateHelper {
    using EventKeyLibrary for EventKey;

    //keccach("GAS_LIMIT")
    bytes32 constant internal GAS_LIMIT_SLOT = 0x96b0c8ad3e900a7b6d91877104d0239a0a4cf3596bfa1dd265a801c5e293d83e;
    uint64 public immutable CALLBACK_GAS_LIMIT = uint64(0xf4240); // 1000000 gas
    

    IReactiveHooks public immutable REACTIVE_HOOK;
    EventKey public immutable EVENT_KEY;
    EventData public EVENT_DATA;
    Calldata public CALLDATA;
    
    
    
    modifier InvalidCalldata(bytes memory data) {
        if (data.length < uint256(0x18)) {
            revert InvalidCalldataLength(data);
        }
        _;
    }

    constructor(
        IReactiveHooks reactiveHook,
        EventKey eventKey,
        EventData memory eventData,
        Calldata memory _callData
    ) InvalidCalldata(_callData.callData) {
        REACTIVE_HOOK = reactiveHook;
        EVENT_DATA = eventData;
        CALLDATA = _callData;
        EVENT_KEY = eventKey;

        if (!vm) {
            service.subscribe(
                EVENT_KEY.chainId(),
                EVENT_KEY.contractAddress(),
                EVENT_KEY.topic0(),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }


    }

    function react(LogRecord calldata log) external vmOnly {
        if (
            log._contract == EVENT_KEY.contractAddress() &&
            log.topic_0 == EVENT_DATA.topic1 &&
            log.topic_1 == EVENT_DATA.topic2 &&
            log.topic_2 == EVENT_DATA.topic3
        ) 
        {

            bytes memory payload = abi.encode(CALLDATA.executor, CALLDATA.callData);
            uint64 gasLimit = bytes32(0x00) != _getGasLimit() ? uint64(uint256(_getGasLimit())) : CALLBACK_GAS_LIMIT;
            emit Callback(log.chain_id, address(REACTIVE_HOOK), gasLimit, payload);
        }
    }


    function setGasLimit(uint64 _gasLimit) external {
        assembly {
            tstore(GAS_LIMIT_SLOT, _gasLimit)
        }
    }

    function getGasLimit() external view returns(bytes32) {
        return _getGasLimit();
    }

    function _getGasLimit() internal view returns(bytes32) {
        assembly {
            mstore(0x00, tload(GAS_LIMIT_SLOT))
            return(0x00, 0x20)
        }
    }



}
