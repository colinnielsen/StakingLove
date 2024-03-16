// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/StakingLove.sol";

contract DeployStakingLove is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        StakingLove sl = new StakingLove();

        console2.log("stakingLove", address(sl));
    }
}
