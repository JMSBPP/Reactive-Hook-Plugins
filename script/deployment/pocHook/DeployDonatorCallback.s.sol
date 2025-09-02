// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {StdAssertions} from "forge-std/StdAssertions.sol";
import {console2} from "forge-std/Test.sol";
import "./SepoliaLasnaConstants.sol";
import {DonatorCallback} from "../../../src/mocks/pocHook/destination/DonatorCallback.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

contract SepoliaDeployDonatorCallback is Script, StdAssertions{
    address private donatorCallbackAddress;

    function run() public {
        uint256 reactiveTestnetForkId = vm.createSelectFork("reactive-testnet");
        //NOTE: Pass as flag --account <DEPLOYER_ACCOUNT_NAME> or --private-key <PRIVATE_KEY>
        vm.startBroadcast();
        DonatorCallback donatorCallback = new DonatorCallback(
            IPoolManager(POOL_MANAGER),
            CALLBACK_PROXY_SEPOLIA
        );

        vm.stopBroadcast();

    }
}