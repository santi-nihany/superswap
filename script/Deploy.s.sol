// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LiquidityPool} from "../src/LiquidityPool.sol";
import {SwapCrossChain} from "../src/SwapCrossChain.sol";
import {Inter} from "../src/Inter.sol";

contract DeployContracts is Script {
    address public constant TOKEN0 = 0x4200000000000000000000000000000000000024; // Example Token 0
    address public constant TOKEN1 = 0x4200000000000000000000000000000000000034; // Example Token 1

    function run() external {
        vm.startBroadcast({chainId: 1});

        // Deploy on Chain 2
        LiquidityPool liquidityPool = new LiquidityPool(TOKEN0, TOKEN1);
        Inter interContract = new Inter();

        vm.startBroadcast({chainId: 2});
        // Deploy on Chain 1
        SwapCrossChain swapCrossChain = new SwapCrossChain();

        console.log("LiquidityPool deployed at:", address(liquidityPool));
        console.log("Inter deployed at:", address(interContract));
        console.log("SwapCrossChain deployed at:", address(swapCrossChain));

        vm.stopBroadcast();
    }
}
