// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "ds-test/test.sol";
import "../src/StakingLove.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockERC721.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";


contract StakingLoveTest is DSTest {

    StakingLove stakinglove;
    MockERC721 nft;

    function setUp() public {
     nft = new MockERC721();
     stakinglove = new StakingLove();
     stakinglove.setLoveStaking(0x2e234DAe75C793f67A35089C9d99245E1C58470b);
   
    }


   function testStake() public {
 
    nft.approve(address(stakinglove), 1);
    stakinglove.stake(1, address(nft));

    assertEq(nft.ownerOf(1), address(stakinglove));
    assertEq(stakinglove.userdata(address(nft), 1), address (this));
        
   uint256 stakingTime = stakinglove.userStakingmiloscStakingInfosTime(address(nft), 1);
   assertTrue(stakingTime > 0);
        
    }

   function testUnstake() public {
    uint256 tokenId = 2;
   
    nft.approve(address(stakinglove), tokenId);
    stakinglove.stake(tokenId, address(nft));
    

    stakinglove.unstake(tokenId, address(nft));
    assertEq(nft.ownerOf(tokenId), address(this));

    address staker = stakinglove.userdata(address(nft), tokenId);
    assertEq(staker, address(0), "Userdata mapping not reset correctly");

  
    uint256 stakeTime = stakinglove.miloscStakingInfosTime(address(nft), tokenId);
    assertEq(stakeTime, 0, "miloscStakingInfosTime mapping not reset correctly");
    }

}
