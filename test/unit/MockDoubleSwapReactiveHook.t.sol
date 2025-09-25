// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {MockDoubleSwapReactiveHook} from "../mocks/MockDoubleSwapReactiveHook.sol";
import {Deployers} from "@uniswap/v4-periphery/test/utils/Deployers.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";

import {DeployUniversalRouter} from "@uniswap/universal-router/script/DeployUniversalRouter.s.sol";
import {UniversalRouter} from "@uniswap/universal-router/contracts/UniversalRouter.sol";

import {IUniversalRouter} from "@uniswap/universal-router/interfaces/IUniversalRouter.sol";

contract MockDoubleSwapReactiveHookTest is Test, Deployers {
    MockDoubleSwapReactiveHook public hook;





    function setUp() public {

        deployFreshManagerAndRouters();
        DeployUniversalRouter deployUniversalRouter = new DeployUniversalRouter();
        UniversalRouter universalRouter = deployUniversalRouter.run();
        
        hook = MockDoubleSwapReactiveHook(
            payable(
                address(
                    uint160(
                        type(uint160).max & clearAllHookPermissionsMask | Hooks.AFTER_INITIALIZE_FLAG
                    )
                )
            )
        );

        deployCodeTo("MockDoubleSwapReactiveHook", abi.encode(
            address(0x00),
            manager,
            IUniversalRouter(address(universalRouter))
            ), 
            address(hook)
        );
        

        

        (currency0, currency1) = deployMintAndApprove2Currencies();
        (key,) = initPoolAndAddLiquidity(currency0, currency1, IHooks(address(hook)), 3000, SQRT_PRICE_1_1);
        (nativeKey,) = initPoolAndAddLiquidityETH(CurrencyLibrary.ADDRESS_ZERO, currency1, IHooks(address(0)), 3000, SQRT_PRICE_1_1, 1 ether);
     
    }
}