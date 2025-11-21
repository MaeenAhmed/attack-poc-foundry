# Security Analysis & PoC: Reentrancy Vulnerability in a DeFi Vault

This repository contains a complete security analysis and Proof of Concept (PoC) for a critical reentrancy vulnerability discovered in a sample DeFi vault contract. The project was developed using the Foundry framework.

The primary goal of this project is to demonstrate a real-world attack vector, from discovery and exploitation to mitigation and verification, simulating the full lifecycle of a bug bounty submission.

---

## 📂 Project Structure

- **/src**: Contains the smart contracts, including:
  - `VulnerableBatchVault.sol`: The original, vulnerable contract.
  - `SecureBatchVault.sol`: The patched, secure version using `ReentrancyGuard`.
  - `Attacker.sol` & `MaliciousToken.sol`: Contracts used to execute the attack.
- **/test**: Contains the Foundry tests:
  - `BatchReentrancyExploit.t.sol`: The test that **proves the exploit is successful** against the vulnerable contract.
  - `SecureBatchVault.t.sol`: The test that **proves the attack fails** against the secure contract.
- **Security_Analysis_Memo.txt**: A professional, prose-style security report detailing the findings, impact, and remediation.

---

## 🔬 Running the Tests

This project uses the Foundry framework. To run the tests and verify the findings, follow these steps:

1.  **Install Foundry:** If you don't have it, follow the instructions [here](https://book.getfoundry.sh/getting-started/installation ).
2.  **Clone the repository:**
    ```bash
    git clone https://github.com/MaeenAhmed/attack-poc-foundry.git
    cd attack-poc-foundry
    ```
3.  **Install dependencies:**
    ```bash
    forge install
    ```
4.  **Run the tests:**
    ```bash
    forge test -vvv
    ```

You will see two tests pass: one confirming the successful exploit and the other confirming the successful defense.

---

## 📄 Security Report

For a detailed, non-technical explanation of the vulnerability, its financial impact, and the mitigation strategy, please read the full security memorandum:

**[➡️ Read the Full Security Analysis Memo](./Security_Analysis_Memo.txt )**