// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    IDonator,
    PoolKey,
    BalanceDelta,
    BalanceDeltaLibrary
} from "./interfaces/IDonator.sol";

import {
    CurrencySettler,
    Currency
} from "@uniswap/v4-core/test/utils/CurrencySettler.sol";

import {TransientStateLibrary} from "@uniswap/v4-core/src/libraries/TransientStateLibrary.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {SafeCallback} from "@uniswap/v4-periphery/src/base/SafeCallback.sol";


// =====Reactive dependencies===
import {AbstractCallback} from "@reactive-network/abstract-base/AbstractCallback.sol";


contract DonatorCallback is IDonator ,SafeCallback, AbstractCallback{
    using CurrencySettler for Currency;
    using TransientStateLibrary for IPoolManager;

    struct DonatorData{
        address donator;
        PoolKey poolKey;
        uint256 amount0;
        uint256 amount1;
        bytes hookData;
    }


    constructor(
        IPoolManager _manager,
        address callbackSender
    ) SafeCallback(_manager) AbstractCallback(callbackSender){}

    function donate(
        address callbackSender,
        PoolKey memory poolKey,
        uint256 amount0,
        uint256 amount1,
        bytes memory hookData
    ) external authorizedSenderOnly rvmIdOnly(callbackSender) returns (BalanceDelta delta){
        delta = abi.decode(
                abi.encode(
                    DonatorData({
                        donator: msg.sender,
                        poolKey: poolKey,
                        amount0: amount0,
                        amount1: amount1,
                        hookData:hookData
                    })
            ),
            (BalanceDelta)
        );
    }

    function _unlockCallback(
        bytes calldata data
    ) internal virtual override returns (bytes memory)
    {
        DonatorData memory donatorData = abi.decode(
            data,
            (DonatorData)
        );
        (,, int256 deltaBefore0) = _fetchBalances(donatorData.poolKey.currency0, donatorData.donator, address(this));
        (,, int256 deltaBefore1) = _fetchBalances(donatorData.poolKey.currency1, donatorData.donator, address(this));

        require(deltaBefore0 == 0, "deltaBefore0 is not 0");
        require(deltaBefore1 == 0, "deltaBefore1 is not 0");

        BalanceDelta delta = poolManager.donate(donatorData.poolKey, donatorData.amount0, donatorData.amount1, donatorData.hookData);

        (,, int256 deltaAfter0) = _fetchBalances(donatorData.poolKey.currency0, donatorData.donator, address(this));
        (,, int256 deltaAfter1) = _fetchBalances(donatorData.poolKey.currency1, donatorData.donator, address(this));

        require(deltaAfter0 == -int256(donatorData.amount0), "deltaAfter0 is not equal to -int256(data.amount0)");
        require(deltaAfter1 == -int256(donatorData.amount1), "deltaAfter1 is not equal to -int256(data.amount1)");

        if (deltaAfter0 < 0) donatorData.poolKey.currency0.settle(poolManager, donatorData.donator, uint256(-deltaAfter0), false);
        if (deltaAfter1 < 0) donatorData.poolKey.currency1.settle(poolManager, donatorData.donator, uint256(-deltaAfter1), false);
        if (deltaAfter0 > 0) donatorData.poolKey.currency0.take(poolManager, donatorData.donator, uint256(deltaAfter0), false);
        if (deltaAfter1 > 0) donatorData.poolKey.currency1.take(poolManager, donatorData.donator, uint256(deltaAfter1), false);

        return abi.encode(delta);

    }

    function _fetchBalances(
        Currency currency,
        address donator,
        address deltaHolder
    ) internal view returns (uint256 donatorBalance, uint256 poolBalance, int256 delta)
    {
        donatorBalance = currency.balanceOf(donator);
        poolBalance = currency.balanceOf(address(poolManager));
        delta = poolManager.currencyDelta(deltaHolder, currency);
    }




}