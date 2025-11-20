// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// --- العقد الذي سنهاجمه (نسخة مبسطة من Balancer Vault) ---
contract MockVault {
    bool internal locked;

    function flashLoan(address token, uint256 amount, address borrower, bytes calldata data) external {
        require(!locked, "REENTRANCY");
        locked = true;
        
        // إرسال التوكنز الوهمية
        ERC20(token).transfer(borrower, amount);

        // استدعاء المهاجم
        (bool success, ) = borrower.call(data);
        require(success, "CALLBACK_FAILED");

        locked = false;
    }
}

// --- عقد الاختبار والمهاجم ---
contract BalancerAttackTest is Test {
    MockVault internal vault;
    ERC20 internal weth;

    function setUp() public {
        vault = new MockVault();
        weth = new MockWETH();
        // إعطاء الخزنة بعض التوكنز
        weth.transfer(address(vault), 100 ether);
    }

    // الاختبار الذي يثبت أن الهجوم يتم منعه
    function test_Reentrancy_ShouldFail() public {
        // بيانات الاستدعاء التي سيستخدمها المهاجم لإعادة الدخول
        bytes memory attackData = abi.encodeWithSelector(
            this.reentrantCall.selector
        );

        // بيانات الاستدعاء للقرض السريع
        bytes memory loanData = abi.encodeWithSelector(
            this.executeFlashLoan.selector,
            attackData
        );

        // نتوقع أن يفشل الهجوم بسبب قفل إعادة الدخول
        vm.expectRevert("REENTRANCY");
        
        // بدء الهجوم
        vault.flashLoan(address(weth), 10 ether, address(this), loanData);
    }

    // هذه الدالة التي تستدعيها الخزنة
    function executeFlashLoan(bytes memory attackData) external {
        // المهاجم يحاول استدعاء الخزنة مرة أخرى
        (bool success, ) = address(vault).call(attackData);
        // لا يهم إذا نجح أم فشل، المهم هو محاولة إعادة الدخول
    }

    // هذه الدالة التي يحاول المهاجم استدعاءها بشكل غير شرعي
    function reentrantCall() external {
        console.log("Attack successful: Re-entrant call was executed!");
    }
}

// --- عقد توكن وهمي للاختبار ---
contract MockWETH is ERC20 {
    constructor() ERC20("Wrapped Ether", "WETH") {
        _mint(msg.sender, 1000 ether);
    }
}
