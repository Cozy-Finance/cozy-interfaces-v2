// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {MarketConfig, SetConfig} from "src/structs/Configs.sol";
import {MarketState, SetState} from "src/structs/StateEnums.sol";

interface ISet {
  /// @dev Emitted when the allowance of a `spender_` for an `owner_` is updated, where `amount_` is the new allowance.
  event Approval(address indexed owner_, address indexed spender_, uint256 amount_);
  /// @dev Emitted when a user claims protection from a triggered market.
  event Claim(
    address caller_,
    address indexed receiver_,
    address indexed owner_,
    uint256 protection_,
    uint256 ptokens_,
    address indexed ptoken_
  );
  /// @dev Emitted when a Set owner's queued set and market configuration updates are applied.
  event ConfigUpdatesFinalized(SetConfig setConfig_, MarketConfig[] marketConfigs_);
  /// @dev Emitted when a Set owner queues new set and/or market configurations.
  event ConfigUpdatesQueued(
    SetConfig setConfig_, MarketConfig[] marketConfigs_, uint256 updateTime_, uint256 updateDeadline_
  );
  /// @dev Emitted when decay is accrued.
  event DecayAccrued(address indexed ptoken_, uint256 newActiveProtection_);
  /// @dev Emitted when a user deposits assets or mints shares. This is a set-level event.
  event Deposit(address indexed caller_, address indexed owner_, uint256 assets_, uint256 shares_);
  /// @dev Emitted when fees are accrued.
  event FeesAccrued(uint128 reserveFees_, uint128 backstopFees_, uint128 setOwnerFees_);
  /// @dev Emitted when fees are dripped to suppliers.
  event FeesDripped(uint128 newTotalPurchasesFees_, uint128 newTotalSalesFees_);
  /// @notice Emitted when a market is created.
  event MarketCreated(uint16 indexed marketId_, address ptokenAddress_);
  /// @notice Emitted when a Market changes state.
  event MarketStateUpdated(uint16 indexed marketId_, address indexed trigger_, MarketState indexed updatedTo_);
  /// @dev Emitted when the first step of the two step ownership transfer is executed.
  event OwnershipTransferStarted(address indexed previousOwner_, address indexed newOwner_);
  /// @dev Emitted when the owner address is updated.
  event OwnershipTransferred(address indexed previousOwner_, address indexed newOwner_);
  /// @dev Emitted when the pauser address is updated.
  event PauserUpdated(address indexed newPauser_);
  /// @dev Emitted when a user purchases protection from a market. This is a market-level event.
  event Purchase(
    address indexed caller_,
    address indexed receiver_,
    uint256 protection_,
    uint256 ptokens_,
    address indexed ptoken_,
    uint256 cost_
  );
  /// @dev Emitted when a user redeems shares. This is a set-level event.
  event Redeem(
    address caller_,
    address indexed receiver_,
    address indexed owner_,
    uint256 assets_,
    uint256 shares_,
    uint256 indexed redemptionId_
  );
  /// @dev Emitted when a user queues a redemption or redeem to be completed later. This is a set-level event.
  event RedemptionPending(
    address caller_,
    address indexed receiver_,
    address indexed owner_,
    uint256 assets_,
    uint256 shares_,
    uint256 indexed redemptionId_
  );
  /// @dev Emitted when a user sells protection. This is a market-level event.
  event Sell(
    address caller_,
    address indexed receiver_,
    address indexed owner_,
    uint256 protection_,
    uint256 ptokens_,
    address indexed ptoken_,
    uint256 refund_
  );
  /// @notice Emitted when the Set changes state.
  event SetStateUpdated(SetState indexed updatedTo_);
  /// @dev Emitted when `amount_` tokens are moved from `from_` to `to_`.
  event Transfer(address indexed from_, address indexed to_, uint256 amount_);

  struct DepositFeesAssets {
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 setOwnerFeeAssets;
  }

  struct MarketConfigStorage {
    address costModel;
    address dripDecayModel;
    uint16 weight;
    uint16 purchaseFee;
    uint16 saleFee;
  }

  struct MintData {
    uint216 amount;
    uint40 time;
  }

  struct PurchaseFeesAssets {
    uint128 totalCost;
    uint128 cost;
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 setOwnerFeeAssets;
  }

  struct RedemptionPreview {
    uint40 delayRemaining;
    uint216 shares;
    uint128 assets;
    address owner;
    address receiver;
  }

  struct SaleFeesAssets {
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 supplierFeeAssets;
  }

  function acceptOwnership() external;
  function accounting()
    external
    view
    returns (
      uint128 assetBalance,
      uint128 accruedSetOwnerFees,
      uint128 accruedCozyReserveFees,
      uint128 accruedCozyBackstopFees,
      uint128 totalPurchasesFees,
      uint128 totalSalesFees,
      uint128 assetsPendingRedemption
    );
  function allowance(address, address) external view returns (uint256);
  function approve(address spender_, uint256 amount_) external returns (bool);
  function asset() external view returns (address);
  function backstop() external view returns (address);
  function balanceOf(address) external view returns (uint256);
  function balanceOfMatured(address user_) external view returns (uint256);
  function claim(uint16 marketId_, uint256 ptokens_, address receiver_, address owner_)
    external
    returns (uint128 protection_);
  function claimCozyFees(address owner_) external returns (uint128 reserveAmount_, uint128 backstopAmount_);
  function claimSetFees(address caller_, address receiver_) external returns (uint128 setOwnerFees_);
  function completeRedeem(uint64 redemptionId_) external returns (uint256 assetsRedeemed_);
  function convertToAssets(uint256 shares_) external view returns (uint256);
  function convertToPTokens(uint16 marketId_, uint256 protection_) external view returns (uint256);
  function convertToProtection(uint16 marketId_, uint256 ptokens_) external view returns (uint256);
  function convertToShares(uint256 assets_) external view returns (uint256);
  function cumulativeMinted(address, uint256) external view returns (uint256);
  function decimals() external view returns (uint8);
  function deposit(uint256 assets_, address receiver_)
    external
    returns (uint256 shares_, DepositFeesAssets memory depositFeesAssets_);
  function dripSupplierFees() external;
  function effectiveActiveProtection(uint16 marketId_) external view returns (uint256);
  function finalizeUpdateConfigs(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_) external;
  function getMints(address user_) external view returns (MintData[] memory);
  function isValidUpdate(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_)
    external
    view
    returns (bool);
  function lastConfigUpdate()
    external
    view
    returns (bytes32 queuedConfigUpdateHash, uint64 configUpdateTime, uint64 configUpdateDeadline);
  function manager() external view returns (address);
  function markets(uint256)
    external
    view
    returns (
      address ptoken,
      address trigger,
      MarketConfigStorage memory config,
      MarketState state,
      uint256 activeProtection,
      uint256 lastDecayRate,
      uint256 lastDripRate,
      uint128 purchasesFeePool,
      uint128 salesFeePool,
      uint64 lastDecayTime
    );
  function maxDeposit() external view returns (uint256 maxDeposit_);
  function maxRedemptionRequest(address owner_) external view returns (uint256 redeemableShares_);
  function mints(address, uint256) external view returns (uint216 amount, uint40 time);
  function name() external view returns (string memory);
  function owner() external view returns (address);
  function pause() external;
  function pauser() external view returns (address);
  function pendingOwner() external view returns (address);
  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    external;
  function previewClaim(uint16 marketId_, uint256 ptokens_) external view returns (uint128);
  function previewDeposit(uint256 assets_)
    external
    view
    returns (uint256 shares_, DepositFeesAssets memory depositFeesAssets_);
  function previewPurchase(uint16 marketId_, uint256 protection_)
    external
    view
    returns (uint256 assetsNeeded_, uint256 ptokens_, PurchaseFeesAssets memory purchaseFeesAssets_);
  function previewRedemption(uint64 redemptionId_) external view returns (RedemptionPreview memory redemptionPreview_);
  function previewSale(uint64 marketId_, uint256 ptokens_)
    external
    view
    returns (uint256 refund_, uint256 protection_, SaleFeesAssets memory saleFeesAssets_);
  function ptokenFactory() external view returns (address);
  function purchase(uint16 marketId_, uint256 protection_, address receiver_)
    external
    returns (uint256 ptokens_, PurchaseFeesAssets memory purchaseFeesAssets_);
  function redeem(uint256 shares_, address receiver_, address owner_)
    external
    returns (uint64 redemptionId_, uint256 assets_);
  function redemptions(uint256)
    external
    view
    returns (
      uint40 queueTime,
      uint216 shares,
      uint128 assets,
      address owner,
      address receiver,
      uint40 delay,
      uint32 queuedAccISFsLength,
      uint256 queuedAccISF
    );
  function remainingProtection(uint16 marketId_) external view returns (uint256);
  function sell(uint16 marketId_, uint256 ptokens_, address receiver_, address owner_)
    external
    returns (uint128 refund_, uint256 protection_);
  function setConfig() external view returns (uint32 leverageFactor, uint16 depositFee, bool rebalanceWeightsOnTrigger);
  function setState() external view returns (SetState);
  function symbol() external view returns (string memory);
  function totalCollateralAvailable() external view returns (uint256);
  function totalSupply() external view returns (uint256);
  function transfer(address to_, uint256 amount_) external returns (bool);
  function transferFrom(address from_, address to_, uint256 amount_) external returns (bool);
  function transferOwnership(address newOwner_) external;
  function triggerLookups(address) external view returns (bool marketExists, uint16 marketId);
  function unpause() external;
  function updateConfigs(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_) external;
  function updateMarketState(MarketState newMarketState_) external;
  function updatePauser(address _newPauser) external;
  function utilization(uint16 marketId_) external view returns (uint256);
}
