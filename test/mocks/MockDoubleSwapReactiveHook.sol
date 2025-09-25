// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {ReactiveHookBase} from "../../src/base/ReactiveHookBase.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {MockV4Router} from "@uniswap/v4-periphery/test/mocks/MockV4Router.sol";
import {Calldata} from "../../src/types/Calldata.sol";

import {Planner, Plan} from "@uniswap/v4-periphery/test/shared/Planner.sol";
import {Actions} from "@uniswap/v4-periphery/src/libraries/Actions.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";

import {IUniversalRouter} from "@uniswap/universal-router/interfaces/IUniversalRouter.sol";

import {IV4Router} from "@uniswap/v4-periphery/src/interfaces/IV4Router.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PathKey} from "@uniswap/v4-periphery/src/libraries/PathKey.sol";

contract MockDoubleSwapReactiveHook is  ReactiveHookBase {
    using Planner for Plan;



    PoolKey public poolKey;

    uint256 DEFAULT_DEADLINE = block.timestamp + 1;

    PoolKey public poolKey;
    IUniversalRouter public swapRouter;
    
    constructor(
        address _callback_sender,
        IPoolManager _manager,
        IUniversalRouter _swapRouter
    ) ReactiveHookBase(_callback_sender, _manager) {
        swapRouter = _swapRouter;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }    

    function _afterInitialize(address, PoolKey calldata _poolKey, uint160, int24) internal virtual override returns (bytes4) {
        poolKey = _poolKey;
        return IHooks.afterInitialize.selector;
    }


    function _setCallData( ) internal virtual override  returns(Calldata memory) {
        Plan memory plan = Planner.init();
       
        IV4Router.ExactInputSingleParams memory swapParams = IV4Router.ExactInputSingleParams({
            poolKey: poolKey,
            zeroForOne: true,
            amountIn: uint128(IERC20(Currency.unwrap(poolKey.currency0)).balanceOf(address(this))),
            amountOutMinimum: uint128(0x00),
            hookData: bytes("")
        });

        plan.add(Actions.SWAP_EXACT_IN, abi.encode(swapParams));
        bytes memory swapData = plan.finalizeSwap(
            poolKey.currency0,
            poolKey.currency1,
            ActionConstants.MSG_SENDER
        );
        
    
        plan.add(
            Actions.SETTLE_ALL,
            abi.encode(
                poolKey.currency0,
                type(uint256).max
                )
            );
        plan.add(
            Actions.TAKE_ALL,
            abi.encode(
                poolKey.currency1,
                uint256(0x00)
            )
        );


        bytes memory swapCallData = abi.encodeCall(
            swapRouter.execute,
            (plan.actions,plan.params,DEFAULT_DEADLINE)
        );

        
        return Calldata({
            executor: address(swapRouter),
            callData: swapCallData
        });
    }

}