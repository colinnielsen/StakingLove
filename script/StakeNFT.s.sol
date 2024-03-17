// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/StakingLove.sol";
import "../src/NFTStaker.sol";

contract DeployStakingLove is Script {
    NFTStaker internal staker;
    IERC721Metadata internal blobsOnBaseContract = IERC721Metadata(0x28e43Bb3eE202E1dA587c88B0a8398309e8D4c2D);

    function setUp() public {
        staker = new NFTStaker();
    }

    function run() public {
        vm.startBroadcast();
        // approve the staking token
        blobsOnBaseContract.setApprovalForAll(address(staker), true);
        // create the pool
        staker.createStakingPool(blobsOnBaseContract, 19605);
    }
}
