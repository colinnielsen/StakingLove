// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "solady/src/tokens/ERC20.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import "./interface/IStakingLove.sol";
import "./lib/OneSidedLiquidityHelper.sol";

contract Coin is ERC20, Ownable {
    error LiquidityLocked();
    error NotInitialized();
    error InvalidInitializationParams();

    uint256 private constant ADD_LIQUIDITY_ETH_SELECTOR = 0xf305d719;
    uint256 private constant BALANCE_OF_SELECTOR = 0x70a08231;
    uint256 private constant TRANSFER_SELECTOR = 0xa9059cbb;
    uint256 private constant INVALID_INITIALIZATION_PARAMS_SELECTOR = 0x7676b397;
    uint256 private constant LIQUIDITY_LOCKED_SELECTOR = 0x8f4e75b2;
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    uint256 private constant _BALANCE_SLOT_SEED = 0x87a211a2;

    uint256 immutable TEAM_BPS;
    uint256 public immutable LIQUIDITY_LOCKED_UNTIL;
    address public immutable UNISWAP_POOL;
    uint256 private lpTokenId;

    bytes32 immutable _NAME;
    bytes32 immutable _SYMBOL;

    constructor(
        string memory name_,
        string memory sym,
        uint256 fullTotalSupply,
        uint256 _teamBps,
        uint256 liquidityLockPeriodInSeconds
    ) payable {
        bytes32 _name;
        bytes32 _symbol;
        uint256 liquidityLockedUntil;

        ///@solidity memory-safe-assembly
        assembly {
            let nameLen := mload(name_)
            let symLen := mload(sym)
            // team bps cannot be greater than 10000
            let errBuffer := gt(_teamBps, 10000)
            // name must be shorter than 32 bytes but longer than 0 bytes
            errBuffer := or(errBuffer, or(iszero(nameLen), gt(nameLen, 31)))
            // symbol must be shorter than 32 bytes but longer than 0 bytes
            errBuffer := or(errBuffer, or(iszero(symLen), gt(symLen, 31)))
            // assert error buffer is zero
            if errBuffer {
                mstore(0, INVALID_INITIALIZATION_PARAMS_SELECTOR)
                revert(0x1c, 0x04)
            }
            // load the last byte encoding length of each string plus the next 31 bytes
            _name := mload(add(31, name_))
            _symbol := mload(add(31, sym))
            // add timestamp to liquidity lock period
            liquidityLockedUntil := add(timestamp(), liquidityLockPeriodInSeconds)
            // if addition overflowed, set to max uint256
            liquidityLockedUntil :=
                or(
                    liquidityLockedUntil,
                    // LHS will be 0 if no overflow
                    mul(
                        lt(liquidityLockedUntil, timestamp()),
                        // type(uint256).max
                        not(0)
                    )
                )
        }

        // assign owner
        _initializeOwner(msg.sender);

        // calculate team and pool tokens
        uint256 teamTokens;
        uint256 poolTokens;
        ///@solidity memory-safe-assembly
        assembly {
            teamTokens := div(mul(fullTotalSupply, _teamBps), 10000)
            poolTokens := sub(fullTotalSupply, teamTokens)
        }

        (address weth, INonfungiblePositionManager nonfungiblePositionManager) = OneSidedLiquidityHelper.getAddresses();
        // mint team tokens to deployer
        if (teamTokens > 0) _mint(msg.sender, teamTokens);
        // mint this contract the pool tokens
        if (poolTokens > 0) _mint(address(this), poolTokens);

        // sort the tokens
        (address token0, address token1) = address(this) < weth ? (address(this), weth) : (weth, address(this));

        (, uint160 initialSquareRootPrice) =
            OneSidedLiquidityHelper.getMintParams({token: address(this), weth: weth, lpTokenReceiver: address(this)});

        // create the pool
        address pool = nonfungiblePositionManager.createAndInitializePoolIfNecessary({
            token0: token0,
            token1: token1,
            fee: POOL_FEE,
            sqrtPriceX96: initialSquareRootPrice
        });

        _NAME = _name;
        _SYMBOL = _symbol;
        TEAM_BPS = _teamBps;
        LIQUIDITY_LOCKED_UNTIL = liquidityLockedUntil;
        UNISWAP_POOL = pool;
    }

    function initPool() external returns (uint256) {
        uint256 selfBalance = balanceOf(address(this));

        (address weth, INonfungiblePositionManager nonfungiblePositionManager) = OneSidedLiquidityHelper.getAddresses();

        // approve the nonFungiblePosManager
        _approve(address(this), address(nonfungiblePositionManager), selfBalance);
        (INonfungiblePositionManager.MintParams memory mintParams,) =
            OneSidedLiquidityHelper.getMintParams({token: address(this), weth: weth, lpTokenReceiver: address(this)});

        // mint the position and store the lp topken id
        (uint256 _lpTokenId,,,) = nonfungiblePositionManager.mint({params: mintParams});

        // store the lp token id
        lpTokenId = _lpTokenId;

        return _lpTokenId;
    }

    function newWithdrawLP() public {
        // TODO: needs access control
        if (lpTokenId == 0) revert NotInitialized();
        if (block.timestamp < LIQUIDITY_LOCKED_UNTIL) revert LiquidityLocked();
        (, INonfungiblePositionManager nonfungiblePositionManager) = OneSidedLiquidityHelper.getAddresses();

        nonfungiblePositionManager.transferFrom(address(this), owner(), lpTokenId);
    }

    ///
    ////// ADMIN FUNCTIONS
    ///

    // Mint function that can only be called by stakingLove contract
    function mint(address to, uint256 amount) external onlyOwner {
        // Call mintRewards in the stakingLove contract to determine the recipient
        // address recipient = IStakingLove(stakingLove).mintRewards(to, amount);

        // Mint tokens to the recipient determined by stakingLove
        _mint(to, amount);
    }

    function withdrawLP() external onlyOwner {
        // place immutable onto stack
        uint256 liquidityLockedUntil = LIQUIDITY_LOCKED_UNTIL;
        address pair = UNISWAP_POOL;
        // place owner onto stack
        address owner = owner();
        ///@solidity memory-safe-assembly
        assembly {
            function checkSuccess(status) {
                // check if call was successful and bubble up error if not
                if iszero(status) {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }

            // assert liquidity is unlocked
            if gt(liquidityLockedUntil, timestamp()) {
                mstore(0, LIQUIDITY_LOCKED_SELECTOR)
                revert(0x1c, 0x04)
            }
            // cache free memory ptr
            let freePtr := mload(0x40)

            // get LP token balance
            mstore(0, BALANCE_OF_SELECTOR)
            mstore(0x20, address())
            checkSuccess(call(gas(), pair, 0, 0x1c, 0x24, 0, 0x20))
            let tokenBalance := mload(0)

            // transfer tokens to owner
            mstore(0, TRANSFER_SELECTOR)
            mstore(0x20, owner)
            mstore(0x40, tokenBalance)
            checkSuccess(call(gas(), pair, 0, 0x1c, 0x44, 0, 0))

            // restore free memory ptr since block is declared memory-safe I guess
            mstore(0x40, freePtr)
        }
    }

    ///
    ////// VIEW FUNCTIONS
    ///

    function name() public view override returns (string memory) {
        bytes32 name_ = _NAME;
        ///@solidity memory-safe-assembly
        assembly {
            mstore(0, 0x20)
            mstore(0x3f, name_)

            return(0, 0x60)
        }
    }

    function symbol() public view override returns (string memory) {
        bytes32 symbol_ = _SYMBOL;
        ///@solidity memory-safe-assembly
        assembly {
            mstore(0, 0x20)
            mstore(0x3f, symbol_)

            return(0, 0x60)
        }
    }
}
