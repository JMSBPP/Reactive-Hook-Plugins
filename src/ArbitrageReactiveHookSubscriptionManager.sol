// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;


import {
    IReactive,
    AbstractPausableReactive,
    ISystemContract
} from "@reactive-network/abstract-base/AbstractPausableReactive.sol";

import {PoolKey,PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";


import {
    EnumerableMap,
    EnumerableSet
} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";



import "./utils/PoolManagerEventsUtils.sol";
import {PoolManagerLogRecordLibrary} from "./libraries/PoolManagerLogRecordLibrary.sol";
import {IArbitrageReactiveHookCallback} from "./interfaces/IArbitrageReactiveHookCallback.sol";

// Taken from:
// -> https://dev.reactive.network/subscriptions#dynamic-subscriptions

// NOTE: Subscriptions in the Reactive Network are 
// managed through the system contract, 
// which is accessible only from the network

// NOTE: Events are sent to the ReactVM's contract copy,
// which has no direct access to the system contract. 
// Therefore, dynamic subscriptions and unsubscriptions
// based on incoming events must be handled via callbacks.



//  * - `bytes32 -> address` (`Bytes32ToAddressMap`) since v5.1.0

contract ArbitrageReactiveHookSubscriptionManager is IReactive, AbstractPausableReactive{
    using EnumerableSet for EnumerableSet.BytesSet;
    using EnumerableMap for EnumerableMap.Bytes32ToAddressMap;
    using PoolIdLibrary for PoolKey;
    using BeforeSwapDeltaLibrary for int128;
    using BeforeSwapDeltaLibrary for BeforeSwapDelta;
    using PoolManagerLogRecordLibrary for IReactive.LogRecord;


    // NOTE: The keys are the poolId's and the values are
    // the IHooks addresses
    struct ReactiveHookData{
        uint256 destination;
        uint256 origin;
        PoolKey poolKey;
        EnumerableSet.BytesSet subscriptions;
    }

    ReactiveHookData reactiveHookData;
    EnumerableMap.Bytes32ToAddressMap private hookRegistry;

    


    error HookRegistrationFailed();


    constructor(
        address _service,
        IPoolManager _poolManager,
        PoolKey memory poolKey,
        uint256 _destinationChainId,
        uint256 _originChainId
    ){
        service = ISystemContract(payable(_service));
        reactiveHookData.poolKey = poolKey;
        reactiveHookData.destination = _destinationChainId;
        reactiveHookData.origin = _originChainId;
        vm = !_subscribeToPoolManager(_poolManager);
    }



    ///@dev This function pre-registers a hook until a Initialize events
    /// heppens ad we get the price information at which point 
    /// there is criteria on price differences to determine wheter
    /// to subscribe permanently or not to the hook


    function whitelistHook(PoolKey memory poolKey, IHooks hook) internal{
        
        /// NOTE: This is the pre-register criteria
        /// TODO: There needs to be criteria to filter out hooks
        /// coming from non valid chain Id's...
        if (
            address(hook)!=address(0x00) && 
            address(reactiveHookData.poolKey.hooks) != address(hook) &&
            reactiveHookData.poolKey.fee == poolKey.fee &&
            reactiveHookData.poolKey.tickSpacing == poolKey.tickSpacing
            )
        {   
            hookRegistry.set(
                PoolId.unwrap(poolKey.toId()),
                address(hook)
            );

            bytes memory encodedSubscription =abi.encode(
                AbstractPausableReactive.Subscription({
                        chain_id: reactiveHookData.origin,
                        _contract: address(hook),
                        topic_0: uint256(INITIALIZE_TOPIC_0),
                        topic_1: uint256(PoolId.unwrap(poolKey.toId())),
                        topic_2: uint256(uint160(Currency.unwrap(poolKey.currency0))),
                        topic_3: uint256(uint160(Currency.unwrap(poolKey.currency1)))
                    }));
            //NOTE: Does this needs to be placed on transient storage ?

            reactiveHookData.subscriptions.add(
                encodedSubscription
            );

        } else {
            revert HookRegistrationFailed();
        }
    }

    function react(LogRecord calldata log) external{
        // NOTE: This is the built-in poolKey that has the 
        // price of the hook
        PoolKey memory hookToSubscribePoolKey = log.poolKey();
        IHooks hookToSubscribe = hookToSubscribePoolKey.hooks;
        
        whitelistHook(
            hookToSubscribePoolKey,
            hookToSubscribe
        );

        uint160 hookToSubscribeSqrtPrice = log.initializeData().sqrtPrice;

            
        //NOTE : Do we need to pass more data ??
        bytes memory reactiveHookCallbackPayload = abi.encodeCall(
            IArbitrageReactiveHookCallback.arbitrageSwap,
            (
                hookToSubscribeSqrtPrice
            )
        );
 

        // emit Callback(
        //     log.chain_id,

        // )

        //NOTE: Get the price of the Hook that is a portential subscription
    }

    function _subscribeToPoolManager(IPoolManager _poolManager) private returns(bool){
        bytes memory subscriptionPayload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            reactiveHookData.origin,
            address(_poolManager),
            INITIALIZE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscriptionResponse, ) = address(service).call(subscriptionPayload);
        return subscriptionResponse;
    }




    
}






