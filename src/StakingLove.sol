//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error NotGoodPerson();

import {Ownable} from "solady/src/auth/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "ERC721A/IERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "solady/src/utils/SafeTransferLib.sol";
import "./IERC20TokenFactory.sol";
import "./Coin.sol";
import "./CommitReveal.sol";
import "./plonk_vk.sol";

contract StakingLove is Ownable, ERC721Holder, CommitReveal {
    using SafeERC20 for IERC20;

    UltraVerifier public immutable verifier = new UltraVerifier();

    uint256 private DaoValue;
    uint256 private lifeSpan;
    address public safeadd;
    address receiver = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

    mapping(address => mapping(uint256 => address)) public userdata;
    mapping(address => mapping(uint256 => uint256)) public miloscStakingInfosTime;
    mapping(address => mapping(uint256 => bool)) public collected;
    mapping(address => address) public collectiontokentype;

    function stake(uint256 tokenIds, address _nft) external {
        assembly {
            mstore(0x0, _nft)
            mstore(0x20, userdata.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x0, tokenIds)
            let finalLocation := keccak256(0x0, 0x40)

            if sload(finalLocation) {
                mstore(0x00, 0x639c3fa4) // 'collected()' selector
                revert(0x1c, 0x04)
            }

            sstore(finalLocation, caller())

            let currentTime := timestamp()
            mstore(0x0, _nft)
            mstore(0x20, miloscStakingInfosTime.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x00, tokenIds)

            let location := keccak256(0x0, 0x40)

            if sload(location) {
                mstore(0x0, 0x01336cea) //"overflow' selector
                revert(0x1c, 0x04)
            }
            sstore(keccak256(0x0, 0x40), currentTime)

            mstore(0x00, hex"23b872dd")
            mstore(0x04, caller())
            mstore(0x24, address())
            mstore(0x44, tokenIds)

            if iszero(call(gas(), _nft, 0, 0x00, 0x64, 0, 0)) { revert(0, 0) }
        }
    }

    function StakeBunch(uint256[] calldata tokenIds, address _nft) external {
        assembly {
            let length := calldataload(sub(tokenIds.offset, 0x20))
            let dataStart := add(tokenIds.offset, 0x20)
            for { let i := dataStart } lt(i, add(dataStart, mul(length, 0x20))) { i := add(i, 0x20) } {
                let tokenId := calldataload(i)

                mstore(0x0, _nft)
                mstore(0x20, userdata.slot)
                mstore(0x20, keccak256(0x0, 0x40))
                mstore(0x0, tokenId)
                let finalLocation := keccak256(0x0, 0x40)

                if sload(finalLocation) {
                    mstore(0x00, 0x639c3fa4) // 'collected()' selector
                    revert(0x1c, 0x04)
                }
                // Mark the token as staked
                sstore(finalLocation, caller())

                let currentTime := timestamp()
                mstore(0x0, _nft)
                mstore(0x20, miloscStakingInfosTime.slot)
                mstore(0x20, keccak256(0x0, 0x40))
                mstore(0x00, tokenId)

                let location := keccak256(0x0, 0x40)

                if sload(location) {
                    mstore(0x0, 0x01336cea) //"overflow' selector
                    revert(0x1c, 0x04)
                }
                sstore(keccak256(0x0, 0x40), currentTime)

                // Prepare ERC721 token transfer call
                mstore(0x00, hex"23b872dd")
                mstore(0x04, caller())
                mstore(0x24, address())
                mstore(0x44, tokenId)

                // Execute the transfer
                if iszero(call(gas(), _nft, 0, 0x00, 0x64, 0, 0)) { revert(0, 0) }
            }
        }
    }

    function unstake(uint256 tokenIds, address _nft) external {
        address reciever = msg.sender;

        assembly {
            mstore(0x0, _nft)
            mstore(0x20, userdata.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x0, tokenIds)
            let finalLocation := keccak256(0x0, 0x40)

            let storedAddress := sload(finalLocation)
            if iszero(storedAddress) {
                mstore(0x00, 0x01336cea) // 'Unauthorized()' selector
                revert(0x1c, 0x04)
            }
            sstore(finalLocation, 0)

            mstore(0x0, _nft)
            mstore(0x20, miloscStakingInfosTime.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x00, tokenIds)
            let stakeTimestamp := sload(keccak256(0x0, 0x40))

            let currentTime := timestamp()
            let timeElapsed := sub(currentTime, stakeTimestamp)
            // let lifeSpans := mload(lifeSpan.slot) maybe some of projects want to have different time of staking
            if lt(timeElapsed, 120) {
                mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
                revert(0x1c, 0x04)
            }

            sstore(keccak256(0x0, 0x40), 0x0)

            mstore(0x00, hex"23b872dd")
            mstore(0x04, address())
            mstore(0x24, reciever)
            mstore(0x44, tokenIds)

            if iszero(call(gas(), _nft, 0, 0x00, 0x64, 0, 0)) { revert(0, 0) }
        }
    }

    function UnstakeBunch(uint256[] calldata tokenIds, address _nft) external {
        assembly {
            let length := calldataload(sub(tokenIds.offset, 0x20))
            let dataStart := add(tokenIds.offset, 0x20)
            for { let i := dataStart } lt(i, add(dataStart, mul(length, 0x20))) { i := add(i, 0x20) } {
                let tokenId := calldataload(i)

                mstore(0x0, _nft)
                mstore(0x20, userdata.slot)
                mstore(0x20, keccak256(0x0, 0x40))
                mstore(0x0, tokenId)
                let finalLocation := keccak256(0x0, 0x40)

                let storedAddress := sload(finalLocation)
                if iszero(storedAddress) {
                    mstore(0x00, 0x01336cea) // 'Unauthorized()' selector
                    revert(0x1c, 0x04)
                }
                sstore(finalLocation, 0)

                mstore(0x0, _nft)
                mstore(0x20, miloscStakingInfosTime.slot)
                mstore(0x20, keccak256(0x0, 0x40))
                mstore(0x00, tokenId)
                let stakeTimestamp := sload(keccak256(0x0, 0x40))

                let currentTime := timestamp()
                let timeElapsed := sub(currentTime, stakeTimestamp)
                if lt(timeElapsed, 120) {
                    mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
                    revert(0x1c, 0x04)
                }

                sstore(keccak256(0x0, 0x40), 0x0)

                mstore(0x00, hex"23b872dd")
                mstore(0x04, address())
                mstore(0x24, caller())
                mstore(0x44, tokenId)

                if iszero(call(gas(), _nft, 0, 0x00, 0x64, 0, 0)) { revert(0, 0) }
            }
        }
    }
    // collecting rewards for existing token

    function collectRewards(uint256 tokenIds, address _nft) external {
        address tresury = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        address token = collectiontokentype[_nft];

        assembly {
            // Load the location of the staked timestamp

            mstore(0x20, miloscStakingInfosTime.slot)
            mstore(0x00, tokenIds)
            let stakeTimestampLocation := keccak256(0x20, 0x20)
            let stakeTimestamp := sload(stakeTimestampLocation)

            // Check if at least 120 seconds have passed since the stake
            let currentTime := timestamp()
            let timeElapsed := sub(currentTime, stakeTimestamp)
            if lt(timeElapsed, 120) {
                mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
                revert(0x1c, 0x04)
            }

            // Cache 'collected' location for this address.
            mstore(0x0, caller())
            mstore(0x20, collected.slot)
            mstore(0x0, tokenIds)
            let location := keccak256(0x0, 0x40)

            if sload(location) {
                mstore(0x00, 0x639c3fa4) // 'collected()' selector
                revert(0x1c, 0x04)
            }
            // Calculate reward based on 'DaoValue' and days staked
            //let tre := sload(tresury.slot)
            let daoValue := sload(DaoValue.slot)
            let currentTimes := timestamp()
            let daysStaked := div(sub(currentTimes, stakeTimestamp), 86400)
            let reward := mul(daoValue, daysStaked)

            mstore(0x00, hex"23b872dd")
            mstore(0x04, tresury)
            mstore(0x24, caller())
            mstore(0x44, reward)

            if iszero(call(gas(), token, 0, 0x00, 0x64, 0, 0)) { revert(0, 0) }
            // Mark the rewards as collected for this address and token ID
            sstore(location, 0x1)
        }
    }

    function createPool(
        address _nft,
        address _stakingLove,
        string calldata name,
        string calldata sym,
        uint256 totalSupply,
        uint256 teamBps,
        uint256 liquidityLockPeriodInSeconds,
        bytes32 salt,
        bytes calldata proof
    ) external payable returns (Coin meme) {
        try verifier.verify_noinputs(proof) returns (bool) {}
        catch (bytes memory) {
            revert NotGoodPerson();
        }

        require(collectiontokentype[_nft] == address(0), "NFT already used for a pool");

        _validateCommitment(salt, name);

        meme = new Coin{salt: salt, value: msg.value}(
            _stakingLove, name, sym, totalSupply * 1e18, address(this), teamBps, liquidityLockPeriodInSeconds
        );

        if (teamBps < 10000) {
            ///@solidity memory-safe-assembly
            assembly {
                let success := call(gas(), meme, 0, 0, 0, 0, 0)
                if iszero(success) {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }
        }

        collectiontokentype[_nft] = address(meme);
    }

    function mintRewards(uint256 tokenIds, address _nft) external {
        address token = collectiontokentype[_nft];

        assembly {
            // Load the location of the staked timestamp
            mstore(0x0, _nft)
            mstore(0x20, miloscStakingInfosTime.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x00, tokenIds)

            let timestampLoc := keccak256(0x0, 0x40)
            let stakeTimestamp := sload(timestampLoc)

            // Check if at least 120 seconds have passed since the stake
            let currentTime := timestamp()
            let timeElapsed := sub(currentTime, stakeTimestamp)
            if lt(timeElapsed, 120) {
                mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
                revert(0x1c, 0x04)
            }

            // Cache 'collected' location for this address.
            mstore(0x0, caller())
            mstore(0x20, collected.slot)
            mstore(0x0, tokenIds)
            let location := keccak256(0x0, 0x40)

            if sload(location) {
                mstore(0x00, 0x639c3fa4) // 'collected()' selector
                revert(0x1c, 0x04)
            }

            let currentTimes := timestamp()
            let daysStaked := div(sub(currentTimes, stakeTimestamp), 86400)
            let reward := mul(10, daysStaked)

            mstore(0x00, hex"40c10f19")
            mstore(0x04, caller())
            mstore(0x24, reward)

            if iszero(call(gas(), token, 0, 0x00, 0x44, 0, 0)) { revert(0, 0) }
            // Mark the rewards as collected for this address and token ID
            sstore(location, 0x1)
        }
    }

    function setDaoValue(uint256 _DaoValue) external onlyOwner {
        DaoValue = _DaoValue;
    }

    function getDaoValue() external view returns (uint256) {
        return DaoValue;
    }

    function setlifespan(uint256 _lifeSpan) external onlyOwner {
        lifeSpan = _lifeSpan;
    }

    function userStakingmiloscStakingInfosTime(address nftproject, uint256 tokenId) external view returns (uint256) {
        return miloscStakingInfosTime[nftproject][tokenId];
    }

    function updateCollectionToken(address _nft, address _token) external onlyOwner {
        collectiontokentype[_nft] = _token;
    }
    // Function to withdraw both Ethereum and ERC20 tokens from the contract.

    function withdrawTokens(address _token) external payable onlyOwner {
        uint256 _Balance = IERC20(_token).balanceOf(address(this));
        SafeTransferLib.safeTransfer(_token, safeadd, _Balance);
    }
}
