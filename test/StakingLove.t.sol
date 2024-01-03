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
address user1;
    function setUp() public {
        nft = new MockERC721();
        
        user1 = address(1);

        // Initialize StakingLove contract without arguments
        stakinglove = new StakingLove();
        stakinglove.setLoveStaking(0x2e234DAe75C793f67A35089C9d99245E1C58470b);
    }

    function test_stake() public {
        uint256 tokenId = 1;

        // Approve the StakingLove contract to transfer the NFT on behalf of this contract
        nft.approve(address(stakinglove), tokenId);

        // Stake the NFT
        stakinglove.stake(tokenId, address(nft));
    
        // Verify that the userdata mapping is updated correctly
       // address staker = stakinglove.userdata(address(nft), tokenId);
        assertEq(nft.ownerOf(1), address(stakinglove));
    }

   function testStake() public {
    // Setup user environment
 
    nft.approve(address(stakinglove), 1);

    // Test staking
    stakinglove.stake(1, address(nft));

    // Assertions
    assertEq(nft.ownerOf(1), address(stakinglove));

   }}

