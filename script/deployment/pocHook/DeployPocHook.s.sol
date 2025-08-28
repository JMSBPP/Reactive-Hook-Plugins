// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/Test.sol";

import {CounterHook} from "../../../src/mocks/pocHook/origin/CounterHook.sol";
import {DonatorCallback} from "../../../src/mocks/pocHook/destination/DonatorCallback.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

contract SepoliaDeployPocHook is Script{

    uint256 constant LASNA_CHAIN_ID = uint256(0xaa36a7);
    uint256 constant SEPOLIA_CHAIN_ID = uint256(5318007);
    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
    address constant POOL_MANAGER = address(IPoolManager(0xE03A1074c86CFeDd5C142C4F04F1a1536e203543));
    address constant CALLBACK_PROXY_SEPOLIA = address(0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA);
    address constant CALLBACK_PROXY_LASNA  = address(0x0000000000000000000000000000000000fffFfF);
    address constant SEPOLIA_LASNA_FAUCER = address(0x9b9BB25f1A81078C544C829c5EB7822d747Cf434);

    enum ChainType{
        ORIGIN,
        DESTINATION,
        REACTIVE
    }

    struct Endpoint{
        uint256 chainId;
        string rpcUrl;
        string currencyBalance;
        ChainType chainType;
        address callbackAddress;
    }


    function originEndpoint() public view returns(Endpoint memory _originEndpoint) {
        _originEndpoint = Endpoint({
            chainId: SEPOLIA_CHAIN_ID,
            rpcUrl: vm.rpcUrl("sepolia"),
            currencyBalance: getETHSepoliaBalance(),
            chainType: ChainType.ORIGIN,
            callbackAddress: address(0x00)
        }); 
    }

    function destinationEndpoint() public view returns(Endpoint memory _destinationEndpoint){
        _destinationEndpoint = Endpoint({
            chainId: SEPOLIA_CHAIN_ID,
            rpcUrl: vm.rpcUrl("sepolia"),
            currencyBalance: getETHSepoliaBalance(),
            chainType: ChainType.ORIGIN,
            callbackAddress: CALLBACK_PROXY_SEPOLIA
        });
    }


    function reactiveEndPoint() public returns(Endpoint memory _reactiveEndpoint) {
        _reactiveEndpoint = Endpoint({
            chainId: LASNA_CHAIN_ID,
            rpcUrl: vm.rpcUrl("reactive-testnet"),
            currencyBalance: getReactiveTestnetBalance(),
            chainType: ChainType.REACTIVE,
            callbackAddress: CALLBACK_PROXY_LASNA 
        });
    }



    address private hookAddress; // This is the origin contract
    address private donatorCallbackAddress;

    function run() public {
        
        bytes32 salt;
        // TODO: There needs to be control over not deploying this twice
        if (hookAddress == address(0)){
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
            vm.stopBroadcast();

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

        

        }

        if (donatorCallbackAddress == address(0)){
            vm.startBroadcast();
            {

                DonatorCallback donatorCallback = new DonatorCallback{salt: salt}(
                    IPoolManager(POOL_MANAGER),
                    CALLBACK_PROXY_SEPOLIA
                );

                require(address(donatorCallback) == donatorCallbackAddress, "DonatorCallbackScript: DonatorCallback address missmatch");
            }
            vm.stopBroadcast();
        }

    }

    function getETHSepoliaBalance() public view returns(string memory){
        return vm.toString(address(this).balance);
    }

    function getReactiveTestnetBalance() public  returns(string memory){

        string[] memory inputs = new string[](6);
        inputs[0] = "cast";
        inputs[1] = "balance";
        inputs[2] = "--rpc-url";
        inputs[3] = vm.rpcUrl("reactive-testnet");
        inputs[4] = "--address";
        inputs[5] = vm.toString(vm.addr(1)); 
    
        bytes memory result = vm.ffi(inputs);
        string memory balanceStr = abi.decode(result, (string));
    
        // Convert string balance to uint256 (remove "ether" suffix if present)
        return balanceStr;
    }

    //TODO: We want to make this a call to get faucet tokens on lasna (reactive testnet)
    // based on the instructions set on the reactive-samrt-contracts-demos/src/basic/README.md taht esplains how to do it
    // using cast

    function requestLasnaFaucetDefault() public returns(string memory){
        // Use vm.ffi to execute cast command for faucet request
        // This follows the pattern from reactive-smart-contracts-demos
        string[] memory inputs = new string[](8);
        inputs[0] = "cast";
        inputs[1] = "send";
        inputs[2] = vm.toString(SEPOLIA_LASNA_FAUCER);
        inputs[3] = "--rpc-url";
        inputs[4] = vm.rpcUrl("reactive-testnet");
        inputs[5] = "--private-key";
        inputs[6] = vm.toString(vm.addr(1));
        inputs[7] = "request(address)";
        
        bytes memory result = vm.ffi(inputs);
        console2.log("Faucet request result:", string(result));
        return getReactiveTestnetBalance();
    }





}