// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IStakingLove {
    function mintRewards(address caller, uint256 reward) external returns (address recipient);
}
