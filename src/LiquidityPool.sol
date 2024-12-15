// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@solady/tokens/ERC20.sol";
import "@optimism/contracts-bedrock/src/libraries/Predeploys.sol";
import "@optimism/contracts-bedrock/src/libraries/errors/CommonErrors.sol";
import "@optimism/contracts-bedrock/src/L2/SuperchainERC20.sol";

contract SimpleLiquidityPool is SuperchainERC20 {
    address public token0;
    address public token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out);
    event Sync(uint256 reserve0, uint256 reserve1);

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    // Add liquidity
    function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256 liquidity) {
        ERC20(token0).transferFrom(msg.sender, address(this), amount0);
        ERC20(token1).transferFrom(msg.sender, address(this), amount1);

        if (totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1);
        } else {
            liquidity = Math.min((amount0 * totalSupply) / reserve0, (amount1 * totalSupply) / reserve1);
        }

        require(liquidity > 0, "Insufficient liquidity minted");
        balanceOf[msg.sender] += liquidity;
        totalSupply += liquidity;

        reserve0 += amount0;
        reserve1 += amount1;

        emit Mint(msg.sender, amount0, amount1);
        emit Sync(reserve0, reserve1);
    }

    // Remove liquidity
    function removeLiquidity(uint256 liquidity) external returns (uint256 amount0, uint256 amount1) {
        require(balanceOf[msg.sender] >= liquidity, "Insufficient balance");

        amount0 = (liquidity * reserve0) / totalSupply;
        amount1 = (liquidity * reserve1) / totalSupply;

        require(amount0 > 0 && amount1 > 0, "Insufficient liquidity burned");

        balanceOf[msg.sender] -= liquidity;
        totalSupply -= liquidity;

        reserve0 -= amount0;
        reserve1 -= amount1;

        ERC20(token0).transfer(msg.sender, amount0);
        ERC20(token1).transfer(msg.sender, amount1);

        emit Burn(msg.sender, amount0, amount1, msg.sender);
        emit Sync(reserve0, reserve1);
    }

    // Swap tokens
    function swap(uint256 amount0Out, uint256 amount1Out) external {
        require(amount0Out > 0 || amount1Out > 0, "Insufficient output amount");
        require(amount0Out < reserve0 && amount1Out < reserve1, "Insufficient liquidity");

        uint256 balance0 = ERC20(token0).balanceOf(address(this));
        uint256 balance1 = ERC20(token1).balanceOf(address(this));

        if (amount0Out > 0) ERC20(token0).transfer(msg.sender, amount0Out);
        if (amount1Out > 0) ERC20(token1).transfer(msg.sender, amount1Out);

        uint256 amount0In = balance0 > reserve0 - amount0Out ? balance0 - (reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > reserve1 - amount1Out ? balance1 - (reserve1 - amount1Out) : 0;

        require(amount0In > 0 || amount1In > 0, "Insufficient input amount");

        uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
        uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);

        require(balance0Adjusted * balance1Adjusted >= reserve0 * reserve1 * (1000 ** 2), "K invariant");

        reserve0 = balance0;
        reserve1 = balance1;

        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out);
        emit Sync(reserve0, reserve1);
    }
}
