// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {LiquidityPool} from "../src/LiquidityPool.sol";

contract DeployLiquidityPool is Script {
    address deployer;
    LiquidityPool internal liquidityPool;

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address public constant TOKEN0 = 0x4200000000000000000000000000000000000024; // Example Superchain Token
    address public constant TOKEN1 = 0x4200000000000000000000000000000000000034; // Example Superchain Token

    function run() external returns (LiquidityPool) {
        vm.startBroadcast(DEFAULT_ANVIL_PRIVATE_KEY);

        deployer = vm.addr(DEFAULT_ANVIL_PRIVATE_KEY);

        // Deploy the liquidity pool
        liquidityPool = new LiquidityPool(TOKEN0, TOKEN1);

        vm.stopBroadcast();

        return liquidityPool;
    }
}
