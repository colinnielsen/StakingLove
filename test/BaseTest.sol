// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

contract BaseTest is Test {
    function setUp() public virtual {
        vm.createSelectFork("base", 11919488);
    }
}
