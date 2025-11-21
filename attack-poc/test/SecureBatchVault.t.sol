// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SecureBatchVault.sol"; // <-- Using the SECURE vault
import "../src/MaliciousToken.sol";
import "../src/Attacker.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// MockToken is already defined in the other test file, but it's good practice
// to have it here too in case tests are run separately.
contract MockTokenForSecureTest is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}
    function mint(address to, uint256 amount) external { _mint(to, amount); }
}

contract SecureBatchVaultTest is Test {
    SecureBatchVault internal vault; // <-- Using the SECURE vault
    MockTokenForSecureTest internal legitToken;
    MaliciousToken internal maliciousToken;
    Attacker internal attacker;

    address internal user = address(0x1);
    address internal attackerAddress = address(0x2);

    function setUp() public {
        vault = new SecureBatchVault(); // <-- Deploying the SECURE vault
        legitToken = new MockTokenForSecureTest("Legit Token", "LGT");
        maliciousToken = new MaliciousToken();
        
        // We need to redeploy the attacker to link it to the new secure vault
        attacker = new Attacker(
            address(vault),
            address(maliciousToken),
            address(legitToken)
        );

        maliciousToken.setAttacker(payable(address(attacker)));

        // Fund user and vault
        legitToken.mint(user, 100 ether);
        maliciousToken.mint(address(vault), 100 ether);
        vault.seedBalanceForTesting(maliciousToken, 100 ether);
    }

    // This test proves the re-entrancy attack is NO LONGER possible.
    function testAttackFailsOnSecureVault() public {
        // Standard user deposit
        vm.startPrank(user);
        legitToken.approve(address(vault), 10 ether);
        vault.deposit(legitToken, 10 ether);
        vm.stopPrank();

        // --- ATTEMPT THE ATTACK ---
        vm.startPrank(address(attacker));
        legitToken.approve(address(vault), 0);

        // We EXPECT this call to REVERT.
        // Why? The second time the attacker tries to call batchSwap (from within the malicious token),
        // the vault's balance will already be updated, and the subtraction will cause an underflow error.
        vm.expectRevert();
        vault.batchSwap(legitToken, maliciousToken, 0, 1 ether);
        
        vm.stopPrank();

        // --- ASSERT FINAL STATE ---
        // After the failed attack, we verify that nothing was stolen.
        // The attacker should have 0 MTK.
        assertEq(maliciousToken.balanceOf(address(attacker)), 0);
        // The vault's MTK balance should still be 100 ether.
        assertEq(vault.balances(address(maliciousToken)), 100 ether);
    }
}