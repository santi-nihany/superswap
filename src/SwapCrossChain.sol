// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISuperchainTokenBridge} from "@optimism/contracts-bedrock/src/L2/SuperchainTokenBridge.sol";
import {IL2ToL2CrossDomainMessenger} from "@optimism/contracts-bedrock/src/L2/L2ToL2CrossDomainMessenger.sol";

contract SwapCrossChain {
    address public constant SUPERCHAIN_TOKEN_BRIDGE = 0x4200000000000000000000000000000000000028;
    address public constant CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000023;

    function swapCrossChain(
        address liquidityPool,
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        address inter,
        uint256 chainId
    ) public {
        // Send tokens to the same address on Optimism
        ISuperchainTokenBridge(SUPERCHAIN_TOKEN_BRIDGE).sendERC20(token0, address(inter), amount0, chainId);
        ISuperchainTokenBridge(SUPERCHAIN_TOKEN_BRIDGE).sendERC20(token1, address(inter), amount1, chainId);

        // swapCrosschain (chain 1) -> inter (chain 2) -> Liquidity Pool (chain 2)
        IL2ToL2CrossDomainMessenger(CROSS_DOMAIN_MESSENGER).sendMessage(
            chainId,
            address(inter),
            abi.encodeWithSignature(
                "completeSwap(address,address,address,uint256,uint256,address)",
                address(inter),
                address(token0),
                address(token1),
                amount0,
                amount1,
                msg.sender
            )
        );
    }
}
