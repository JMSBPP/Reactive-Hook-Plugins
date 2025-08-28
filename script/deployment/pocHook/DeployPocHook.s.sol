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
    //TODO: These are placeholders for compilation before commiting
    // changes, these are not the addresses of the contracts on 
    // sepolia ...

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
        string rpcUrl;
        uint256 currencyBalance;
        ChainType chainType;
        address callbackAddress;
    }


    function originEndpoint() public view returns(Endpoint memory originEndpoint) {
        originEndpoint = Endpoint({
            rpcUrl: vm.rpcUrl("sepolia"),
            currencyBalance: getETHSepoliaBalance(),
            chainType: ChainType.ORIGIN,
            callbackAddress: address(0x00)
        });
    }

    function destinationEndpoint() public view returns(Endpoint memory destinationEndpoint){
        destinationEndpoint = Endpoint({
            rpcUrl: vm.rpcUrl("sepolia"),
            currencyBalance: getETHSepoliaBalance(),
            chainType: ChainType.ORIGIN,
            callbackAddress: CALLBACK_PROXY_SEPOLIA
        });
    }

    function reactiveEndPoint() public view returns(Endpoint memory reactiveEndpoint) {
        reactiveEndpoint = Endpoint({
            rpcUrl: vm.rpcUrl("reactive-testnet"),
            currencyBalance: getReactiveTestnetBalance(),
            chainType: ChainType.REACTIVE,
            callbackAddress: CALLBACK_PROXY_LASNA 
        });
    }




    //TODO: This is a placeHolder
    function getETHSepoliaBalance() public view returns(uint256){
        return 1;
    }

    //TODO: This is a placeHolder
    function getReactiveTestnetBalance() public view returns(uint256){
        return 2;
        // string[] memory inputs = new string[](3);
        // inputs[0] = "cast";
        // inputs[1] = "send";
        // inputs[2] = "0x9b9BB25f1A81078C544C829c5EB7822d747Cf434";
        // inputs[3] = "-rpc-url";
        // inputs[4] = originEndpoint().rpcUrl;
        // inputs[5] = 
    
        // bytes memory res = vm.ffi(inputs);
        // string memory output = abi.decode(res, (string));
        // assertEq(output, "gm");
        // ffi("cast send 0x9b9BB25f1A81078C544C829c5EB7822d747Cf434 --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY "request(address)" $CONTRACT_ADDR --value 0.1ether")
    }

    mapping(uint256 chaindId => Endpoint) private chainEndpoints;
    mapping(uint256 walletAccessPoint => mapping(uint256 chaindId => Endpoint)) private chainEndpointsAPI;

    
    

    
    DonatorCallback private donatorCallback;

    function run() public {
        address hookAddress;
        bytes32 salt;
        // TODO: There needs to be control over not deploying this twice
        {
            //=======ORIGIN DEPLOYMENT: HOOK==========
            uint160 flags = uint160(
                Hooks.BEFORE_INITIALIZE_FLAG
            );

            bytes memory constructorArgs = abi.encode(POOL_MANAGER);
            
            (hookAddress,salt) = HookMiner.find(
                CREATE2_DEPLOYER,
                flags,
                type(CounterHook).creationCode,
                constructorArgs
            );

            vm.broadcast(); 
        }

        CounterHook counterHook = new CounterHook{salt: salt}(
            IPoolManager(POOL_MANAGER)
        );

        require(address(counterHook) == hookAddress, "CounterHookScript: Hook address missmatch");
        
    }
}