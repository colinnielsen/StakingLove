//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "ERC721A/IERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "solady/src/utils/SafeTransferLib.sol";


contract Milosc is Ownable(msg.sender), ERC721Holder {
   
  mapping(address => mapping(uint256 => bool)) private pupa;
  mapping(address => mapping(uint256 => uint256)) private _userStakingTimestamp;
  mapping(address => mapping(uint256 => uint256)) private miloscStakingInfosTime;
  mapping(address => mapping(uint256 =>address)) private userdata;
  mapping(address => address) private collectiontokentype;
   
  using SafeERC20 for IERC20;
    
    address private _LoveStaking;
    uint256 private DaoValue;
    uint256 private lifeSpan;
    address public safeadd;

 
function stake(uint256 tokenIds, address _nft) external {

   assembly{
            mstore(0x0, _nft)
            mstore(0x20, userdata.slot)
            mstore(0x40, tokenIds) // Use 0x40 - no overriding

           
            let locations := keccak256(0x0, 0x60) 
            if sload(locations) {
                mstore(0x0, 0x01336cea) // 'overflow' selector
                  revert(0x1c, 0x04) 
            }

            sstore(locations, _nft)
           
         let currentTime := timestamp()
            mstore(0x0, _nft)
            mstore(0x20, miloscStakingInfosTime.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x00, tokenIds)
            

         let location := keccak256(0x0, 0x40)

          if sload(location) {
               mstore(0x0,  0x01336cea) //"overflow' selector
                revert(0x1c, 0x04)
            }
            sstore(keccak256(0x0, 0x40), currentTime)
           
              
 
 let stakingContract := sload(_LoveStaking.slot)

        mstore(0x00, hex"23b872dd") 
       
        mstore(0x04, caller())
   
        mstore(0x24, stakingContract)
 
        mstore(0x44, tokenIds)

        if iszero(call(gas(), _nft, 0, 0x00, 0x64, 0, 0)) {
            revert(0, 0)
        }
    }
}

  function unstake(uint256 tokenIds,address _nft) external {
            
           address reciever = msg.sender;
       assembly{
            mstore(0x0, _nft)
            mstore(0x20, userdata.slot)
            mstore(0x40, tokenIds)

            
            let location := keccak256(0x0, 0x60)
            let stakedNft := sload(location)
            if iszero(stakedNft) {
           
                mstore(0x0, 0x039f2e18) // 'NotStaked()' selector
                revert(0x1c, 0x04)
            }
             sstore(location, 0x0)
    
        mstore(0x0, _nft)   
        mstore(0x20, miloscStakingInfosTime.slot)
        mstore(0x20, keccak256(0x0, 0x40))
        mstore(0x00, tokenIds)
        let stakeTimestamp := sload(keccak256(0x0, 0x40))
    
    
        let currentTime := timestamp()
        let timeElapsed := sub(currentTime, stakeTimestamp)
        if lt(timeElapsed, 120) {
            mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
            revert(0x1c, 0x04)
        }
 
        sstore(keccak256(0x0, 0x40), 0x0) 

       
            let stakingContract := sload(_LoveStaking.slot)
            
             mstore(0x00, hex"23b872dd")
             mstore(0x04, stakingContract)
             mstore(0x24, reciever)
            mstore(0x44, tokenIds)

       if iszero(call(gas(),_nft, 0, 0x00, 0x64, 0, 0)) {
                    revert(0, 0)
                }
       
        } }


function collectRewards(uint256 tokenIds, address _nft) external {
    address receiver = msg.sender;
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
       // Calculate reward based on 'DaoValue' and days staked
        let daoValue := sload(DaoValue.slot)
        let currentTimes := timestamp()
        let daysStaked := div(sub(currentTimes, stakeTimestamp), 86400)
        let reward := mul(daoValue,daysStaked)
   

            mstore(0x00, hex"23b872dd")
            mstore(0x04, tresury)
            mstore(0x24, receiver)
            mstore(0x44, reward)

            if iszero(call(gas(),token, 0, 0x00, 0x64, 0, 0)) {
                revert(0, 0)
            }
        // Mark the rewards as collected for this address and token ID
       // sstore(collectedLocation, 0x1)
    }}

    function zgarnijNft (uint256 tokenIds) external onlyOwner {
            // Get the timestamp when the token was staked
            bytes4 transferFrom = 0x23b872dd;
            address skarbiec = 0x13d8cc1209A8a189756168AbEd747F2b050D075f;
         
        
        assembly {
         //Cache Free memory pointer
            let ptr := mload(0x40)
          //Cache _userStakingData location for this address.
         mstore(0x0, caller())
            mstore(0x20, pupa.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x0, tokenIds)
            let location := keccak256(0x0, 0x40)

          //If not staked revert NotStaked()
            if iszero(sload(location))  {
               mstore(0x0, 0x039f2e18) //'NotStaked()' selector
                revert(0x1c, 0x04)
            }

        mstore(0x20, _userStakingTimestamp.slot)
        mstore(0x20, keccak256(0x0, 0x40))
        mstore(0x00, tokenIds)
        let stakeTimestamp := sload(keccak256(0x0, 0x40))

        // Check if 500 seconds have passed since staking
        let currentTime := timestamp()
        let timeElapsed := sub(currentTime, stakeTimestamp)
        if lt(timeElapsed, 500) {
            mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
            revert(0x1c, 0x04)
        }
                
            let transferFromData := add(0x20, mload(0x40))
            
            mstore(transferFromData, transferFrom)
            //let skarbiec := studnia
            let stakingContract := sload(_LoveStaking.slot)
            
  
            mstore(0x00, hex"23b872dd")
            mstore(0x04, stakingContract)
            mstore(0x24, skarbiec)
            mstore(0x44, tokenIds)
          
  if iszero(call(gas(),0x20a78762085602705007DCB326e33EA71C8d1f6F, 0, 0x00, 0x64, 0, 0)) {
                revert(0, 0)
            }

          
        }}
     

function updateCollectionToken(address _nft, address _token) external onlyOwner {
    collectiontokentype[_nft] = _token;
}


   function setLoveStaking(address LoveStaking_) external onlyOwner {
        _LoveStaking = LoveStaking_;
   }
    function setDaoValue(uint256 _DaoValue) external onlyOwner {
        DaoValue =  _DaoValue;
   }
   function getDaoValue() external view returns (uint256) {
        return DaoValue;
    }

       function setlifespan(uint256 _lifeSpan) external onlyOwner {
        lifeSpan =  _lifeSpan;
   }
 function userStakingmiloscStakingInfosTime(address staker, uint256 tokenId)
        external
        view
        returns (uint256)
    {
        return miloscStakingInfosTime[staker][tokenId];
    }
     // Function to withdraw both Ethereum and ERC20 tokens from the contract.
    function withdrawTokens(address _token) external payable onlyOwner {
        uint256 _Balance = IERC20(_token).balanceOf(address(this));
        SafeTransferLib.safeTransfer(_token, safeadd, _Balance);
    }

    }