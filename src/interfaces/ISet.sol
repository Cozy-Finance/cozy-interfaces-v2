// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IConfig.sol";
import "./ICState.sol";
import "./ILFT.sol";

/**
 * @notice All protection markets live within a set.
 */
interface ISet is ILFT {

  /// @notice Set-level configuration.
  struct Set {
    IAccounting accounting;
    uint256 depositFee; // Fee applied on each deposit and mint.
  }

  /// @dev Emitted when a user deposits assets or mints shares. This is a
  /// set-level event.
  event Deposit(
    address indexed caller, 
    address indexed owner, 
    uint256 assets, 
    uint256 shares
    );

  /// @dev Emitted when a user withdraws assets or redeems shares. This is a
  /// set-level event.
  event Withdraw(
    address caller,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares,
    uint256 indexed withdrawalId
  );

  /// @dev Emitted when a user queues a withdrawal or redeem to be completed
  /// later. This is a set-level event.
  event WithdrawalPending(
    address caller,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares,
    uint256 indexed withdrawalId
  );

  struct PendingWithdrawal {
    uint128 shares; // Shares burned to queue the withdrawal.
    uint128 assets; // Amount of assets that will be paid out upon completion of the withdrawal.
    address owner; // Owner of the shares.
    uint64 queueTime; // Timestamp at which the withdrawal was requested.
    address receiver; // Address the assets will be sent to.
    uint64 delay; // Protocol withdrawal delay at the time of request.
  }

  /// @notice Returns the underlying asset used by this set.
  function asset() external view returns (address);

  /// @notice Returns the internal asset balance - equivalent to `asset.balanceOf(address(set))` if no one transfers tokens directly to the contract.
  function assetBalance() external view returns (uint128);

  /// @notice Returns the amount of assets pending withdrawal. These assets are unavailable for new protection purchases but
  /// are available to payout protection in the event of a market becoming triggered.
  function assetsPendingWithdrawal() external view returns (uint128);

  /// @notice Returns the balance of matured tokens held by `_user`.
  function balanceOfMatured(address _user) external view returns (uint256 _balance);

  /// @notice Transfers accrued set owner fees to `_receiver`.
  function claimSetFees(address _receiver) external;

  /// @notice Completes the withdraw request for the specified ID, sending the assets to the stored `_receiver` address.
  function completeRedeem(uint256 _redemptionId) external;

  /// @notice Completes the withdraw request for the specified ID, and sends assets to the new `_receiver` instead of
  /// the stored receiver.
  function completeRedeem(uint256 _redemptionId, address _receiver) external;

  /// @notice Completes the withdraw request for the specified ID, sending the assets to the stored `_receiver` address.
  function completeWithdraw(uint256 _withdrawalId) external;

  /// @notice Completes the withdraw request for the specified ID, and sends assets to the new `_receiver` instead of
  /// the stored receiver.
  function completeWithdraw(uint256 _withdrawalId, address _receiver) external;

  /// @notice The amount of `_assets` that the Set would exchange for the amount of `_shares` provided, in an ideal
  /// scenario where all the conditions are met.
  function convertToAssets(uint256 shares) external view returns (uint256);

  /// @notice The amount of PTokens that the Vault would exchange for the amount of protection, in an ideal scenario
  /// where all the conditions are met.
  function convertToPTokens(address _trigger, uint256 _protection) external view returns (uint256);

  /// @notice The amount of protection that the Vault would exchange for the amount of PTokens, in an ideal scenario
  /// where all the conditions are met.
  function convertToProtection(address _trigger, uint256 _ptokens) external view returns (uint256);

  /// @notice The amount of `_shares` that the Set would exchange for the amount of `_assets` provided, in an ideal
  /// scenario where all the conditions are met.
  function convertToShares(uint256 assets) external view returns (uint256);

  /// @notice Returns the cost factor when purchasing the specified amount of `_protection` in the given market.
  function costFactor(address _trigger, uint256 _protection) external view returns (uint256 _costFactor);

  /// @notice Returns the current drip rate for the set.
  function currentDripRate() external view returns (uint256);

  /// @notice Returns the active protection, decay rate, and last decay time. The response is encoded into a word.
  function dataApd(address) external view returns (bytes32);

  /// @notice Returns the state and PToken address for a market, and the state for the set. The response is encoded into a word.
  function dataSp(address) external view returns (bytes32);

  /// @notice Returns the address of the set's decay model. The decay model governs how fast outstanding protection loses it's value.
  function decayModel() external view returns (address);

  /// @notice Supply protection by minting `_shares` shares to `_receiver` by depositing exactly `_assets` amount of
  /// underlying tokens.
  function deposit(uint256 _assets, address _receiver) external returns (uint256 _shares);

  /// @notice Returns the fee charged by the Set owner on deposits.
  function depositFee() external view returns (uint256);

  /// @notice Returns the market's reserve fee, backstop fee, and set owner fee applied on deposit.
  function depositFees() external view returns (uint256 _reserveFee, uint256 _backstopFee, uint256 _setOwnerFee);

  /// @notice Drip accrued fees to suppliers.
  function drip() external;

  /// @notice Returns the address of the set's drip model. The drip model governs the interest rate earned by depositors.
  function dripModel() external view returns (address);

  /// @notice Returns the array of metadata for all tokens minted to `_user`.
  function getMints(address _user) external view returns (MintMetadata[] memory);

  /// @notice Returns true if `_who` is a valid market in the `_set`, false otherwise.
  function isMarket(address _who) external view returns (bool);

  /// @notice Returns the drip rate used during the most recent `drip()`.
  function lastDripRate() external view returns (uint96);

  /// @notice Returns the timestamp of the most recent `drip()`.
  function lastDripTime() external view returns (uint32);

  /// @notice Returns the exchange rate of shares:assets when the most recent trigger occurred, or 0 if no market is triggered.
  /// This exchange rate is used for any pending withdrawals that were queued before the trigger occurred to calculate
  /// the new amount of assets to be received when the withdrawal is completed.
  function lastTriggeredExchangeRate() external view returns (uint192);

  /// @notice Returns the pending withdrawal count when the most recently triggered market became triggered, or 0 if none.
  /// Any pending withdrawals with IDs less than this need to have their amount of assets updated to reflect the exchange
  /// rate at the time when the most recently triggered market became triggered.
  function lastTriggeredPendingWithdrawalCount() external view returns (uint64);

  /// @notice Returns the leverage factor of the set, as a zoc.
  function leverageFactor() external view returns (uint256);

  /// @notice Returns the address of the Cozy protocol Manager.
  function manager() external view returns (address);

  /// @notice Returns the encoded market configuration, i.e. it's cost model, weight, and purchase fee for a market.
  function marketConfig(address) external view returns (bytes32);

  /// @notice Returns the maximum amount of the underlying asset that can be deposited to supply protection.
  function maxDeposit(address) external view returns (uint256);

  /// @notice Maximum amount of shares that can be minted to supply protection.
  function maxMint(address) external view returns (uint256);

  /// @notice Returns the maximum amount of protection that can be sold for the specified market.
  function maxProtection(address _trigger) external view returns (uint256);

  /// @notice Maximum amount of protection that can be purchased from the specified market.
  function maxPurchaseAmount(address _trigger) external view returns (uint256 _protection);

  /// @notice Maximum amount of Set shares that can be redeemed from the `_owner` balance in the Set,
  /// through a redeem call.
  function maxRedemptionRequest(address _owner) external view returns (uint256);

  /// @notice Maximum amount of the underlying asset that can be withdrawn from the `_owner` balance in the Set,
  /// through a withdraw call.
  function maxWithdrawalRequest(address _owner) external view returns (uint256);

  /// @notice Supply protection by minting exactly `_shares` shares to `_receiver` by depositing `_assets` amount
  /// of underlying tokens.
  function mint(uint256 _shares, address _receiver) external returns (uint256 _assets);

  /// @notice Mapping from user address to all of their mints.
  function mints(address, uint256) external view returns (uint128 amount, uint64 time, uint64 delay);

  /// @notice Returns the amount of decay that will accrue next time `accrueDecay()` is called for the market.
  function nextDecayAmount(address _trigger) external view returns (uint256 _accruedDecay);

  /// @notice Returns the amount to be dripped on the next `drip()` call.
  function nextDripAmount() external view returns (uint256);

  /// @notice Returns the number of frozen markets in the set.
  function numFrozenMarkets() external view returns (uint256);

  /// @notice Returns the number of markets in this Set, including triggered markets.
  function numMarkets() external view returns (uint256);

  /// @notice Returns the number of triggered markets in the set.
  function numTriggeredMarkets() external view returns (uint256);

  /// @notice Pauses the set.
  function pause() external;

  /// @notice Claims protection payout after the market for `_trigger` is triggered. Burns the specified number of
  /// `ptokens` held by `_owner` and sends the payout to `_receiver`.
  function payout(
    address _trigger,
    uint256 _ptokens,
    address _receiver,
    address _owner
  ) external returns (uint256 _protection);

  /// @notice Returns the total number of withdrawals that have been queued, including pending withdrawals that have been completed.
  function pendingWithdrawalCount() external view returns (uint64);

  /// @notice Returns all withdrawal data for the specified withdrawal ID.
  function pendingWithdrawalData(uint256 _withdrawalId)
    external
    view
    returns (uint256 _remainingWithdrawalDelay, PendingWithdrawal memory _pendingWithdrawal);

  /// @notice Maps a withdrawal ID to information about the pending withdrawal.
  function pendingWithdrawals(uint256)
    external
    view
    returns (uint128 shares, uint128 assets, address owner, uint64 queueTime, address receiver, uint64 delay);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their cancellation (i.e. view the refund
  /// amount, number of PTokens burned, and associated fees collected by the protocol) at the current block, given
  /// current on-chain conditions.
  function previewCancellation(
    address _trigger,
    uint256 _protection
  ) external view returns (uint256 _refund, uint256 _ptokens, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets);

  /// @notice Returns the utilization ratio of the specified market after canceling `_assets` of protection.
  function previewCancellationUtilization(address _trigger, uint256 _assets) external view returns (uint256);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their claim (i.e. view the quantity of
  /// PTokens burned) at the current block, given current on-chain conditions.
  function previewClaim(address _trigger, uint256 _protection) external view returns (uint256 _ptokens);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit (i.e. view the number of
  /// shares received) at the current block, given current on-chain conditions.
  function previewDeposit(uint256 _assets) external view returns (uint256 _shares);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit (i.e. view the number of
  /// shares received along with associated fees) at the current block, given current on-chain conditions.
  function previewDepositData(uint256 _assets)
    external
    view
    returns (uint256 _userShares, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets, uint256 _setOwnerFeeAssets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint (i.e. view the number of
  /// assets transferred) at the current block, given current on-chain conditions.
  function previewMint(uint256 _shares) external view returns (uint256 _assets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint (i.e. view the number of
  /// assets transferred along with associated fees) at the current block, given current on-chain conditions.
  function previewMintData(uint256 _shares)
    external
    view
    returns (uint256 _assets, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets, uint256 _setOwnerFeeAssets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their payout (i.e. view the amount of
  /// assets that would be received for an amount of PTokens) at the current block, given current on-chain conditions.
  function previewPayout(address _trigger, uint256 _ptokens) external view returns (uint256 _protection);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their purchase (i.e. view the total cost,
  /// inclusive of fees, and the number of PTokens received) at the current block, given current on-chain conditions.
  function previewPurchase(
    address _trigger,
    uint256 _protection
  ) external view returns (uint256 _totalCost, uint256 _ptokens);

  /// @notice Allows an on-chain or off-chain user to comprehensively simulate the effects of their purchase at the
  /// current block, given current on-chain conditions. This is similar to `previewPurchase` but additionally returns
  /// the cost before fees, as well as the fee breakdown.
  function previewPurchaseData(
    address _trigger,
    uint256 _protection
  )
    external
    view
    returns (
      uint256 _totalCost,
      uint256 _ptokens,
      uint256 _cost,
      uint256 _reserveFeeAssets,
      uint256 _backstopFeeAssets,
      uint256 _setOwnerFeeAssets
    );

  /// @notice Returns the utilization ratio of the specified market after purchasing `_assets` of protection.
  function previewPurchaseUtilization(address _trigger, uint256 _assets) external view returns (uint256);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their redemption (i.e. view the number
  /// of assets received) at the current block, given current on-chain conditions.
  function previewRedeem(uint256 shares) external view returns (uint256);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their sale (i.e. view the refund amount,
  /// protection sold, and fees accrued by the protocol) at the current block, given current on-chain conditions.
  function previewSale(
    address _trigger,
    uint256 _ptokens
  ) external view returns (uint256 _refund, uint256 _protection, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their withdrawal (i.e. view the number of
  /// shares burned) at the current block, given current on-chain conditions.
  function previewWithdraw(uint256 assets) external view returns (uint256);

  /// @notice Return the PToken address for the given market.
  function ptoken(address _who) external view returns (address _ptoken);

  /// @notice Returns the address of the Cozy protocol PTokenFactory.
  function ptokenFactory() external view returns (address);

  /// @notice Purchase `_protection` amount of protection for the specified market, and send the PTokens to `_receiver`.
  function purchase(
    address _trigger,
    uint256 _protection,
    address _receiver
  ) external returns (uint256 _totalCost, uint256 _ptokens);

  /// @notice Returns the market's reserve fee, backstop fee, and set owner fee applied on purchase.
  function purchaseFees(address _trigger)
    external
    view
    returns (uint256 _reserveFee, uint256 _backstopFee, uint256 _setOwnerFee);

  /// @notice Burns exactly `_shares` from owner and queues `_assets` amount of underlying tokens to be sent to
  /// `_receiver` after the `manager.withdrawDelay()` has elapsed.
  function redeem(uint256 _shares, address _receiver, address _owner) external returns (uint256 _assets);

  /// @notice Returns the refund factor when canceling the specified amount of `_protection` in the given market.
  function refundFactor(address _trigger, uint256 _protection) external view returns (uint256 _refundFactor);

  /// @notice Returns the amount of protection currently available to purchase for the specified market.
  function remainingProtection(address _trigger) external view returns (uint256);

  /// @notice Sell `_ptokens` amount of ptokens for the specified market, and send the refund amount to `_receiver`.
  function sell(
    address _trigger,
    uint256 _ptokens,
    address _receiver,
    address _owner
  ) external returns (uint256 _refund, uint256 _protection);

  /// @notice Returns the shortfall (i.e. the amount of unbacked active protection) in a market, or zero if the market
  /// is fully backed.
  function shortfall(address _trigger) external view returns (uint256);

  /// @notice Returns the state of the market or set. Pass a market address to read that market's state, or the set's
  /// address to read the set's state.
  function state(address _who) external view returns (ICState.CState _state);

  /// @notice Returns the set's total amount of fees available to drip to suppliers, and each market's contribution to that total amount.
  /// When protection is purchased, the supplier fee pools for the set and the market that protection is purchased from
  /// gets incremented by the protection cost (after fees). They get decremented when fees are dripped to suppliers.
  function supplierFeePool(address) external view returns (uint256);

  /// @notice Syncs the internal accounting balance with the true balance.
  function sync() external;

  /// @notice Returns the total amount of assets that is available to back protection.
  function totalAssets() external view returns (uint256 _protectableAssets);

  /// @notice Array of trigger addresses used for markets in the set.
  function triggers(uint256) external view returns (address);

  /// @notice Unpauses the set and transitions to the provided `_state`.
  function unpause(ICState.CState _state) external;

  /// @notice Execute queued updates to setConfig and marketConfig. This should only be called by the Manager.
  function updateConfigs(
    uint256 _leverageFactor,
    uint256 _depositFee,
    address _decayModel,
    address _dripModel,
    MarketInfo[] memory _marketInfos
  ) external;

  /// @notice Updates the state of the a market in the set.
  function updateMarketState(address _trigger, uint8 _newState) external;

  /// @notice Updates the set's state to `_state.
  function updateSetState(ICState.CState _state) external;

  /// @notice Returns the current utilization ratio of the specified market, as a wad.
  function utilization(address _trigger) external view returns (uint256);

  /// @notice Returns the current utilization ratio of the set, as a wad.
  function utilization() external view returns (uint256);

  /// @notice Burns `_shares` from owner and queues exactly `_assets` amount of underlying tokens to be sent to
  /// `_receiver` after the `manager.withdrawDelay()` has elapsed.
  function withdraw(uint256 _assets, address _receiver, address _owner) external returns (uint256 _shares);

  /// Additional functions from the ABI.
  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function VERSION() external view returns (uint256);
  function allowance(address, address) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address) external view returns (uint256);
  function decimals() external view returns (uint8);
  function name() external view returns (string memory);
  function nonces(address) external view returns (uint256);
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
  function symbol() external view returns (string memory);
  function totalSupply() external view returns (uint256);
  function transfer(address _to, uint256 _amount) external returns (bool);
  function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}
