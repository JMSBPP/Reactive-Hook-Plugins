// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {StdAssertions} from "forge-std/StdAssertions.sol";
import {console2} from "forge-std/Test.sol";

import {CounterHook} from "../../../src/mocks/pocHook/origin/CounterHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

import {SepoliaLasnaConstants} from "./SepoliaLasnaConstants.sol";
contract SepoliaDeployPocHook is Script, StdAssertions, SepoliaLasnaConstants{
    enum ChainType{
        ORIGIN,
        DESTINATION,
        REACTIVE
    }

    struct Endpoint{
        uint256 chainId;
        string rpcUrl;
        ChainType chainType;
        address callbackAddress;
    }


    function originEndpoint() public view returns(Endpoint memory _originEndpoint) {
        _originEndpoint = Endpoint({
            chainId: SEPOLIA_CHAIN_ID,
            rpcUrl: vm.rpcUrl("sepolia"),
            chainType: ChainType.ORIGIN,
            callbackAddress: address(0x00)
        }); 
    }

    function destinationEndpoint() public view returns(Endpoint memory _destinationEndpoint){
        _destinationEndpoint = Endpoint({
            chainId: SEPOLIA_CHAIN_ID,
            rpcUrl: vm.rpcUrl("sepolia"),
            chainType: ChainType.ORIGIN,
            callbackAddress: CALLBACK_PROXY_SEPOLIA
        });
    }


    function reactiveEndPoint() public returns(Endpoint memory _reactiveEndpoint) {
        _reactiveEndpoint = Endpoint({
            chainId: LASNA_CHAIN_ID,
            rpcUrl: vm.rpcUrl("reactive-testnet"),
            chainType: ChainType.REACTIVE,
            callbackAddress: CALLBACK_PROXY_LASNA 
        });
    }



    address private hookAddress; // This is the origin contract

    function run() public {
        
        bytes32 salt;
        
        
        // TODO: There needs to be control over not deploying this twice
        // if (hookAddress == address(0)){
        uint256 reactiveTestnetForkId = vm.createSelectFork("reactive-testnet");
        uint256 sepoliaForkId = vm.createSelectFork("sepolia");
        // NOTE: The vm.addr(1) does not return my imported reactiveHookPlugins
        // account address
        vm.startBroadcast();
    
            //=======ORIGIN DEPLOYMENT: HOOK==========
        uint160 flags = uint160(
            Hooks.AFTER_INITIALIZE_FLAG
        );

        bytes memory constructorArgs = abi.encode(POOL_MANAGER);
            
        (hookAddress,salt) = HookMiner.find(
            CREATE2_DEPLOYER,
            flags,
            type(CounterHook).creationCode,
            constructorArgs
        );

        // TODO: We are missing logic for
        // verifying the contract here instead of doing it on the command line
        // Also how can he use the rpcUrl here to avoid using it as a flag when running forge
        // script
        CounterHook counterHook = new CounterHook{salt: salt}(
            IPoolManager(POOL_MANAGER)
        );
        require(address(counterHook) == hookAddress, "CounterHookScript: Hook address missmatch");
        vm.stopBroadcast();
        console2.log("CounterHook deployed to:", address(counterHook));
        console2.log("Hook address from HookMiner:", hookAddress);
        console2.log("Deployment completed successfully!");

        // if (donatorCallbackAddress == address(0)){
        //     vm.startBroadcast(vm.addr(1));
        //     {

        //         DonatorCallback donatorCallback = new DonatorCallback{salt: salt}(
        //             IPoolManager(POOL_MANAGER),
        //             CALLBACK_PROXY_SEPOLIA
        //         );
        //         donatorCallbackAddress = address(donatorCallback);
  
        //         // require(address(donatorCallback) == donatorCallbackAddress, "DonatorCallbackScript: DonatorCallback address missmatch");
        //     }
        //     vm.stopBroadcast();
        // }

    }

  





}