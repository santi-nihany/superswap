pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SwapCrossChain} from "../src/SwapCrossChain.sol";
import {LiquidityPool} from "../src/LiquidityPool.sol";
import {Inter} from "../src/Inter.sol";

contract ProvideLiquidity is Script {
    address public constant TOKEN0 = 0x4200000000000000000000000000000000000024; // Example Token 0
    address public constant TOKEN1 = 0x4200000000000000000000000000000000000034; // Example Token 1
    address public constant SWAP_CROSSCHAIN_ADDRESS = 0x4200000000000000000000000000000000000034;
    address public constant INTER_ADDRESS = 0x4200000000000000000000000000000000000034;
    address public constant LIQUIDITY_POOL_ADDRESS = 0x4200000000000000000000000000000000000034;

    uint256 public constant CHAIN_ID_1 = 1; // Chain 1 ID
    uint256 public constant CHAIN_ID_2 = 2; // Chain 2 ID

    function provideLiquidity() external {
        vm.startBroadcast();

        SwapCrossChain swapCrossChain = SwapCrossChain(SWAP_CROSSCHAIN_ADDRESS);

        // Example amounts
        uint256 amount0 = 100 ether;
        uint256 amount1 = 100 ether;

        // Call swapCrossChain to initiate cross-chain liquidity provision
        swapCrossChain.swapCrossChain(
            LIQUIDITY_POOL_ADDRESS, TOKEN0, TOKEN1, amount0, amount1, INTER_ADDRESS, CHAIN_ID_2
        );

        console.log("Liquidity provision initiated.");

        vm.stopBroadcast();
    }

    function run() external {
        provideLiquidity();
    }
}
