// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {MarketState, SetState} from "src/structs/StateEnums.sol";
import {ICostModel} from "src/interfaces/ICostModel.sol";
import {IDripDecayModel} from "src/interfaces/IDripDecayModel.sol";
import {IPToken} from "src/interfaces/IPToken.sol";
import {ITrigger} from "src/interfaces/ITrigger.sol";

/**
 * @notice All protection markets live within a set.
 */
interface ISet {
  /// @dev Emitted when a user deposits assets or mints shares. This is a set-level event.
  event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

  /// @dev Emitted when fees are accrued.
  event FeesAccrued(uint128 reserveFees, uint128 backstopFees, uint128 setOwnerFees);

  /// @notice Emitted when a Market changes state.
  event MarketStateUpdated(uint16 indexed marketIdx, ITrigger indexed trigger, MarketState indexed updatedTo_);

  /// @dev Emitted when the first step of the two step ownership transfer is executed.
  event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

  /// @dev Emitted when the owner address is updated.
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @dev Emitted when the pauser address is updated.
  event PauserUpdated(address indexed newPauser);

  /// @dev Emitted when a user purchases protection from a market. This is a market-level event.
  event Purchase(
    address indexed caller,
    address indexed receiver,
    uint256 protection,
    uint256 ptokens,
    IPToken indexed ptoken,
    uint256 cost
  );

  /// @dev Emitted when a user redeems shares. This is a set-level event.
  event Redeem(
    address caller,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares,
    uint256 indexed redemptionId
  );

  /// @dev Emitted when a user queues a redemption or redeem to be completed later. This is a set-level event.
  event RedemptionPending(
    address caller,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares,
    uint256 indexed redemptionId
  );

  /// @dev Emitted when a user sells protection. This is a market-level event.
  event Sell(
    address caller,
    address indexed receiver,
    address indexed owner,
    uint256 protection,
    uint256 ptokens,
    IPToken indexed ptoken,
    uint256 refund
  );

  /// @notice Emitted when the Set changes state.
  event SetStateUpdated(SetState indexed updatedTo_);

  struct AssetStorage {
    uint128 assetBalance;
    uint128 accruedSetOwnerFees;
    uint128 accruedCozyReserveFees;
    uint128 accruedCozyBackstopFees;
    uint128 totalPurchasesFees;
    uint128 totalSalesFees;
    uint128 assetsPendingRedemption;
  }

  struct DepositFeesAssets {
    uint128 assets;
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 setOwnerFeeAssets;
  }

  struct MarketConfig {
    ITrigger trigger;
    ICostModel costModel;
    IDripDecayModel dripDecayModel;
    uint16 weight;
    uint16 purchaseFee;
    uint16 saleFee;
  }

  struct MarketConfigStorage {
    ICostModel costModel;
    IDripDecayModel dripDecayModel;
    uint16 weight;
    uint16 purchaseFee;
    uint16 saleFee;
  }

  struct MintData {
    uint176 amount;
    uint40 time;
    uint40 delay;
  }

  struct PurchaseFeesAssets {
    uint128 cost;
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 setOwnerFeeAssets;
  }

  struct RedemptionPreview {
    uint40 delayRemaining;
    uint176 shares;
    uint128 assets;
    address owner;
    address receiver;
  }

  struct SaleFeesAssets {
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 supplierFeeAssets;
  }

  struct SetConfig {
    uint32 leverageFactor;
    uint16 depositFee;
  }

  /// @notice Callable by the pending owner to transfer ownership to them.
  function acceptOwnership() external;

  /// @notice Retrieve set-level internal accounting balances.
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

  /// @notice The underlying asset of the set.
  function asset() external view returns (address);

  /// @notice Cozy protocol Backstop.
  function backstop() external view returns (address);

  /// @notice Claims protection payout after the market is triggered. Burns the specified number of
  /// `ptokens_` held by `owner_` and sends the payout to `receiver_`.
  function claim(uint16 marketId_, uint256 ptokens_, address receiver_, address owner_) external returns (uint256);

  /// @notice Transfers accrued reserve and backstop fees to the `owner_` address and `backstop_` address, respectively.
  function claimCozyFees(
    address owner_,
    address backstop_
  ) external returns (uint128 reserveAmount_, uint128 backstopAmount_);

  /// @notice Transfers accrued Set Owner fees to the `receiver_` address.
  function claimSetFees(address receiver_) external returns (uint128 setOwnerFees_);

  /// @notice Completes the redemption request for the specified redemption ID.
  function completeRedeem(uint64 redemptionId_) external returns (uint256 assetsRedeemed_);

  /// @notice The amount of assets that the set would exchange for the amount of `shares_` provided, in an ideal
  /// scenario where all the conditions are met.
  function convertToAssets(uint256 shares_) external view returns (uint256);

  /// @notice The amount of PTokens that the set would exchange for the amount of protection, in an ideal scenario
  /// where all the conditions are met.
  function convertToPTokens(uint16 marketId_, uint256 protection_) external view returns (uint256);

  /// @notice The amount of protection that the set would exchange for the amount of PTokens, in an ideal scenario
  /// where all the conditions are met.
  function convertToProtection(uint16 marketId_, uint256 ptokens_) external view returns (uint256);

  /// @notice The amount of shares that the Set would exchange for the amount of assets provided, in an ideal
  /// scenario where all the conditions are met.
  function convertToShares(uint256 assets_) external view returns (uint256);

  /// @notice Supply protection by minting `shares_` shares to `receiver_` by depositing exactly `assets_` amount of
  /// underlying tokens.
  function deposit(
    uint256 assets_,
    address receiver_
  ) external returns (uint256 shares_, DepositFeesAssets memory depositFeesAssets_);

  /// @notice Execute queued updates to set config and market configs.
  function finalizeUpdateConfigs(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_) external;

  /// @notice Returns metadata about the most recently queued set/market configuration update.
  function lastConfigUpdate()
    external
    view
    returns (bytes32 queuedConfigUpdateHash, uint64 configUpdateTime, uint64 configUpdateDeadline);

  /// @notice The Cozy protocol manager contract.
  function manager() external view returns (address);

  /// @notice Array of market data for each market in the set.
  function markets(uint256)
    external
    view
    returns (
      IPToken ptoken,
      ITrigger trigger,
      MarketConfigStorage memory config,
      MarketState state,
      uint256 activeProtection,
      uint256 lastDecayRate,
      uint256 lastDripRate,
      uint128 purchasesFeePool,
      uint128 salesFeePool,
      uint64 lastDecayTime
    );

  /// @notice Maximum amount of the underlying asset that can be deposited to supply protection.
  function maxDeposit() external view returns (uint256 maxDeposit_);

  /// @notice Maximum amount of set shares that can be redeemed from the `owner_` balance in the Set,
  /// through a redeem call.
  function maxRedemptionRequest(address owner_) external view returns (uint256 redeemableShares_);

  /// @notice The owner of the set.
  function owner() external view returns (address);

  /// @notice Pauses the set.
  function pause() external;

  /// @notice The pauser of the set.
  function pauser() external view returns (address);

  /// @notice The pending new owner of the set.
  function pendingOwner() external view returns (address);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their claim (i.e. view the quantity of
  /// PTokens burned) at the current block, given current on-chain conditions.
  function previewClaim(address, uint256) external view returns (uint256);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their redemption (i.e. view the number
  /// of assets received) at the current block, given current on-chain conditions.
  function previewRedemption(uint64 redemptionId_) external view returns (RedemptionPreview memory redemptionPreview_);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their sale (i.e. view the refund amount,
  /// protection sold, and fees accrued by the protocol) at the current block, given current on-chain conditions.
  function previewSale(
    uint64 marketId_,
    uint256 ptokens_
  ) external view returns (uint256 refund_, uint256 protection_, SaleFeesAssets memory saleFeesAssets_);

  /// @notice The Cozy protocol PTokenFactory.
  function ptokenFactory() external view returns (address);

  /// @notice Purchase `_protection` amount of protection for the specified market, and send the PTokens to `_receiver`.
  function purchase(
    uint16 marketId_,
    uint256 protection_,
    address receiver_
  ) external returns (uint256 totalCost_, uint256 ptokens_, PurchaseFeesAssets memory purchaseFeesAssets_);

  //// @notice Burns exactly `shares_` from `owner_` and queues `assets_` amount of underlying tokens to be sent to
  /// `receiver_` after the `IManager.redemptionDelay()` has elapsed.
  function redeem(
    uint256 shares_,
    address receiver_,
    address owner_
  ) external returns (uint64 redemptionId_, uint256 assets_);

  /// @notice Retrieve metadata about queued redemptions.
  function redemptions(uint256 id_)
    external
    view
    returns (
      uint40 queueTime,
      uint40 delay,
      uint176 shares,
      uint128 assets,
      address owner,
      address receiver,
      uint32 queuedAccISFsLength,
      uint256 queuedAccISF
    );

  /// @notice Sell `ptokens_` amount of ptokens for the specified market, and send the refund amount to `receiver_`.
  function sell(
    uint16 marketId_,
    uint256 ptokens_,
    address receiver_,
    address owner_
  ) external returns (uint128 refund_, uint256 protection_);

  /// @notice Retrieve set-level configuration.
  function setConfig() external view returns (uint32 leverageFactor, uint16 depositFee);

  /// @notice The state of the set.
  function setState() external view returns (SetState);

  /// @notice Calculates the total amount of underlying assets that are available to collateralize new protection
  /// and existing purchases in a Set, minus assets set aside for triggered markets.
  function totalCollateralAvailable() external view returns (uint256);

  /// @notice Starts the ownership transfer of the contract to a new account.
  function transferOwnership(address newOwner_) external;

  /// @notice A mapping of trigger to struct TriggerLookup for fast access to markets given a trigger.
  function triggerLookups(ITrigger) external view returns (bool marketExists, uint16 marketIdx);

  /// @notice Unpause the set.
  function unpause() external;

  /// @notice Signal an update to the set config and market configs. Existing queued updates are overwritten.
  function updateConfigs(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_) external;

  /// @notice Called by a trigger when it's state changes to `newMarketState_` to execute the state
  /// change in the corresponding market.
  function updateMarketState(MarketState newMarketState_) external;

  // @notice Update the pauser.
  function updatePauser(address _newPauser) external;
}
