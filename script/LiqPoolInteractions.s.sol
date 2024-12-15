// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {LiquidityPool} from "../src/LiquidityPool.sol";
import {IL2ToL2CrossDomainMessenger} from "@optimism/contracts-bedrock/src/L2/L2ToL2CrossDomainMessenger.sol";
import {ISuperchainTokenBridge} from "@optimism/contracts-bedrock/src/L2/SuperchainTokenBridge.sol";

contract LiquidityPoolInteractions is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    LiquidityPool private liquidityPool;
    ISuperchainTokenBridge private tokenBridge;
    IL2ToL2CrossDomainMessenger private crossDomainMessenger;

    address public constant TOKEN0 = 0x4200000000000000000000000000000000000024; // Example Superchain Token
    address public constant SUPERCHAIN_TOKEN_BRIDGE = 0x4200000000000000000000000000000000000028;
    address public constant CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000023;

    uint256 public constant DESTINATION_CHAIN_ID = 902; // Optimism chain ID

    function sendTokensToOptimism(uint256 amount) public {
        tokenBridge = ISuperchainTokenBridge(SUPERCHAIN_TOKEN_BRIDGE);

        // Call sendERC20 to bridge tokens to the same address on Optimism
        tokenBridge.sendERC20(TOKEN0, address(this), amount, DESTINATION_CHAIN_ID);
    }

    function approveLiquidityPoolCrosschain(uint256 amount) public {
        crossDomainMessenger = IL2ToL2CrossDomainMessenger(CROSS_DOMAIN_MESSENGER);

        // Encode the approve call for the liquidity pool
        bytes memory approveCall = abi.encodeWithSignature("approve(address,uint256)", address(liquidityPool), amount);

        // Send the crosschain message to approve the liquidity pool
        crossDomainMessenger.sendMessage(DESTINATION_CHAIN_ID, address(liquidityPool), approveCall);
    }

    function swapTokensCrosschain(uint256 amount0Out, uint256 amount1Out) public {
        crossDomainMessenger = IL2ToL2CrossDomainMessenger(CROSS_DOMAIN_MESSENGER);

        // Encode the swap call for the liquidity pool
        bytes memory swapCall = abi.encodeWithSignature("swap(uint256,uint256)", amount0Out, amount1Out);

        // Send the crosschain message to execute the swap
        crossDomainMessenger.sendMessage(DESTINATION_CHAIN_ID, address(liquidityPool), swapCall);
    }

    function run() public {
        vm.startBroadcast(DEFAULT_ANVIL_PRIVATE_KEY);

        // Initialize the deployed liquidity pool address
        liquidityPool = LiquidityPool("");

        uint256 amount = 100 ether; // Example amount

        // Step 1: Send tokens to Optimism
        sendTokensToOptimism(amount);

        // Step 2: Approve liquidity pool on Optimism via crosschain message
        approveLiquidityPoolCrosschain(amount);

        // Step 3: Execute a swap on the liquidity pool via crosschain message
        swapTokensCrosschain(10 ether, 0);

        vm.stopBroadcast();
    }
}
