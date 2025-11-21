// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 1. Import the ReentrancyGuard
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 2. Inherit from ReentrancyGuard
contract SecureBatchVault is ReentrancyGuard {
    mapping(address => uint256) public balances;

    // ... (seedBalanceForTesting and deposit functions remain the same)
    function seedBalanceForTesting(ERC20 token, uint256 amount) external {
        balances[address(token)] = amount;
    }

    function deposit(ERC20 token, uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        balances[address(token)] += amount;
    }


    // THE FULLY SECURED FUNCTION
    // 3. Add the 'nonReentrant' modifier
    function batchSwap(
        ERC20 tokenIn,
        ERC20 tokenOut,
        uint256 amountIn,
        uint256 amountOut
    ) external nonReentrant { // <-- THIS IS THE MAGIC
        // We can even revert to the original "vulnerable" order now,
        // because the nonReentrant modifier makes it safe.

        tokenIn.transferFrom(msg.sender, address(this), amountIn);

        // Even with this "bad" order, the attack will fail.
        tokenOut.transfer(msg.sender, amountOut);

        balances[address(tokenIn)] += amountIn;
        balances[address(tokenOut)] -= amountOut;
    }
}