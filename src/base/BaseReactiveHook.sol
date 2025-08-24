// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {CustomRevert} from "@uniswap/v4-core/src/libraries/CustomRevert.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";


import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

abstract contract BaseReactiveHook is BaseHook{
    using CustomRevert for bytes4;

    constructor(IPoolManager _manager) BaseHook(_manager){}



    // NOTE: Once the pool is initialized is where we are deploying 
    // the plugins of the hooks this is why the afterInitialize
    // flag is mandatory for this hook

    function validateHookAddress(BaseHook _this) internal pure override{
        Hooks.Permissions memory permissions = getHookPermissions();
        {
            Hooks.validateHookPermissions(_this, permissions);
            if (!permissions.afterInitialize){
                Hooks.HookAddressNotValid.selector.revertWith(address(_this));
            }
        }
        
    }



    
}

