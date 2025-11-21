// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VulnerableBatchVault {
    mapping(address => uint256) public balances;

    // This is a helper function ONLY for setting up the test environment.
    // It directly sets the internal balance, which is not typical but useful for tests.
    function seedBalanceForTesting(ERC20 token, uint256 amount) external {
        balances[address(token)] = amount;
    }

    function deposit(ERC20 token, uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        balances[address(token)] += amount;
    }

    function batchSwap(
        ERC20 tokenIn,
        ERC20 tokenOut,
        uint256 amountIn,
        uint256 amountOut
    ) external {
        // 1) Transfer tokenIn from caller into vault
        tokenIn.transferFrom(msg.sender, address(this), amountIn);

        // 2) INTENTIONALLY vulnerable: external transfer to msg.sender BEFORE internal accounting update
        //    if tokenOut.transfer triggers external code (malicious token), re-entry can occur here.
        tokenOut.transfer(msg.sender, amountOut);

        // 3) then update internal bookkeeping (wrong ordering — vulnerable)
        balances[address(tokenIn)] += amountIn;
        balances[address(tokenOut)] -= amountOut;
    }
}