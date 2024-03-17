// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/StakingLove.sol";
import "../src/NFTStaker.sol";

contract DeployStakingLove is Script {
    NFTStaker internal staker = NFTStaker(0x069E38f93d2F8d14f7C4c266eC26276CDc8d6576);
    IERC721Metadata internal dencunmemecoin = IERC721Metadata(0x7C4d65D624483C03fDC8B95FEc48B8f85A2C2585);

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // create the pool
        staker.createStakingPool(dencunmemecoin, 17697);
    }
}
