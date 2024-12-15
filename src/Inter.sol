// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@optimism/contracts-bedrock/src/L2/SuperchainERC20.sol";
import {ILiquidityPool} from "./interfaces/ILiquidityPool.sol";

contract Inter {
    function completeSwap(
        address liquidityPool,
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        address user
    ) public {
        // approve liquidity pool to transferfrom tokens
        SuperchainERC20(token0).approve(liquidityPool, amount0);
        SuperchainERC20(token1).approve(liquidityPool, amount1);

        // add liquidity and mint LP Tokens to user
        ILiquidityPool(liquidityPool).addLiquidity(_amount0, _amount1, user);
    }
}
