// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;


import {IReactive} from "@reactive-network/interfaces/IReactive.sol";
import {ISystemContract} from "@reactive-network/interfaces/ISystemContract.sol";
import {AbstractReactive} from "@reactive-network/abstract-base/AbstractReactive.sol";
import "../../../../script/deployment/pocHook/SepoliaLasnaConstants.sol";
contract PocHookReactiveDonatorCallback is IReactive, AbstractReactive{

    uint256 private constant COUNTED_TOPIC0 = uint256(0x68f3d2d757bff3ec05cb1c943e923a4d32907383121a361b91db56d6e3918b6d);
    address private donatorCallbackAddress;
    uint64 private constant GAS_LIMIT = 1000000;
    uint256 private constant DEFAULT_DONATION_VALUE = 1e13;
    constructor(
        address _pocHookAddress, // Origin
        address _donatorCallbackAddress //Destination
    ){
        service = ISystemContract(payable(CALLBACK_PROXY_LASNA));
        donatorCallbackAddress = _donatorCallbackAddress;

        if (!vm){
            service.subscribe(
                SEPOLIA_CHAIN_ID,
                _pocHookAddress,
                COUNTED_TOPIC0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }

    function react(LogRecord calldata log) external vmOnly{

    }

}