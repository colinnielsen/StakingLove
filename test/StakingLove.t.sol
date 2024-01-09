// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "ds-test/test.sol";
import "../src/StakingLove.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockERC721.sol";
import "forge-std/Test.sol";

contract StakingLoveTest is DSTest {
    StakingLove stakinglove;
    MockERC721 nft;

    function setUp() public {
     nft = new MockERC721();
        
       

        stakinglove = new StakingLove();
        stakinglove.setLoveStaking(0x2e234DAe75C793f67A35089C9d99245E1C58470b);
    }

    function test_stake() public {
        uint256 tokenId = 1;
        nft.approve(address(stakinglove), tokenId);
        stakinglove.stake(tokenId, address(nft));
        assertEq(nft.ownerOf(1), address(stakinglove));
        
    }

   function testStake() public {
 
    nft.approve(address(stakinglove), 1);

    stakinglove.stake(1, address(nft));

   
      assertEq(nft.ownerOf(1), address(stakinglove));
      assertEq(stakinglove.userdata(address(nft), 1), address (this));
        
        uint256 stakingTime = stakinglove.userStakingmiloscStakingInfosTime(address(nft), 1);
        assertTrue(stakingTime > 0);

    }
}


