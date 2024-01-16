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



function testStakeBunch2() public {
    uint256[] memory tokenIds = new uint256[](3);

    tokenIds[0] = 1;
    tokenIds[1] = 2;
    tokenIds[2] = 3;
    // Populate tokenIds...
    address _nft = address(nft);  // Assuming nft is the ERC721 contract instance

    // Approve the StakingLove contract to transfer tokens
   nft.approve(address(stakinglove), 0);
   nft.approve(address(stakinglove), 1);
   nft.approve(address(stakinglove), 2);
   nft.approve(address(stakinglove), 3);


    stakinglove.StakeBunch(tokenIds, _nft);

    // Check ownership and userdata mapping
    for (uint256 i = 0; i >= tokenIds.length; i++) {
        assertEq(nft.ownerOf(tokenIds[i]), address(stakinglove));
        assertEq(stakinglove.userdata(_nft, tokenIds[i]), address(this));
    }
}
}





