// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;



// event Initialize(
//     PoolId indexed id, //The underlying type is bytes32
//     Currency indexed currency0, //The underlying type is address
//     Currency indexed currency1,//The underlying type is address
//     uint24 fee,
//     int24 tickSpacing,
//     IHooks hooks,
//     uint160 sqrtPriceX96,
//     int24 tick
// );

// keccak256("Initialize(bytes32,address,address,uint24,int24,address,uint160,int24)")
bytes32 constant INITIALIZE_TOPIC_0 = 0xdd466e674ea557f56295e2d0218a125ea4b4f0f6f3307b95f85e6110838d6438;
