// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IDecayModel.sol";
import "src/interfaces/IDripModel.sol";

/**
 * @notice Helper contract for reading data from the Cozy protocol.
 */
interface ICozyLens {
  /// @notice  Set-level configuration.
  struct SetConfig {
    uint256 leverageFactor; // The set's leverage factor.
    uint256 depositFee; // Fee applied on each deposit and mint.
    IDecayModel decayModel; // Contract defining the decay rate for PTokens in this set.
    IDripModel dripModel; // Contract defining the rate at which funds are dripped to suppliers for their yield.
  }

  /// @notice Market-level configuration.
  struct MarketInfo {
    address trigger; // Address of the trigger contract for this market.
    address costModel; // Contract defining the cost model for this market.
    uint16 weight; // Weight of this market. Sum of weights across all markets must sum to 100% (1e4, 1 zoc).
    uint16 purchaseFee; // Fee applied on each purchase.
  }

  /// @notice Address of the Cozy protocol manager.
  function manager() external view returns (address);

  /// @notice Address of the Cozy protocol SetFactory.
  function setFactory() external view returns (address);

  /// @notice Address of the Cozy protocol SetBeacon.
  function setBeacon() external view returns (address);

  /// @notice Address of the Cozy protocol PTokenFactory.
  function ptokenFactory() external view returns (address);

  /// @notice Address of the Cozy protocol PTokenBeacon.
  function ptokenBeacon() external view returns (address);

  // ---------------------------------
  // -------- Manager Methods --------
  // ---------------------------------

  /// @notice Returns true if the provided `_set` is part of the Cozy protocol.
  function isSet(address _set) external view returns (bool _exists);

  /// @notice Returns true if the provided `_set` is approved to pull funds from the Backstop.
  function isSetApprovedForBackstop(address _set) external view returns (bool _approved);

  /// @notice Returns the set configUpdateTime
  function getConfigUpdateTime(address _set) external view returns (uint256 _configUpdateTime);

  /// @notice Returns the sets configUpdateDeadline
  function getConfigUpdateDeadline(address _set) external view returns (uint256 _configUpdateDeadline);

  // -----------------------------
  // -------- Set Methods --------
  // -----------------------------

  /// @notice Returns the state of the market, identified by its `_set` and `_trigger` address.
  function getMarketState(address _set, address _trigger) external view returns (uint8 _state);

  /// @notice Returns the state of the `_set`.
  function getSetState(address _set) external view returns (uint8 _state);

  /// @notice Returns the PToken address of the market, identified by its `_set` and `_trigger` address.
  function getPToken(address _set, address _trigger) external view returns (address _ptoken);

  /// @notice Returns the amount of active protection remaining in the market, identified by its `_set` and `_trigger`
  /// address, denominated in units of the set's `asset`.
  function getActiveProtection(address _set, address _trigger) external view returns (uint256 _amount);

  /// @notice Returns the last decay time of the market, identified by its `_set` and `_trigger` address.
  function getLastDecayTime(address _set, address _trigger) external view returns (uint256 _timestamp);

  /// @notice Returns the current decay rate of the market, identified by its `_set` and `_trigger` address, as a wad.
  function getDecayRate(address _set, address _trigger) external view returns (uint256 _decayRate);

  /// @notice Returns the purchase fee of the market, identified by its `_set` and `_trigger` address, as a zoc.
  function getMarketPurchaseFee(address _set, address _trigger) external view returns (uint256 _purchaseFee);

  /// @notice Returns the weight of the market, identified by its `_set` and `_trigger` address, as a zoc.
  function getMarketWeight(address _set, address _trigger) external view returns (uint256 _weight);

  /// @notice Returns the address of the market's cost model, identified by its `_set` and `_trigger` address.
  function getMarketCostModel(address _set, address _trigger) external view returns (address _costModel);

  /// @notice Returns the cost, excluding fees, to purchase `_protection` amount of protection in the market,
  /// identified by its `_set` and `_trigger` address. The cost is in units of the set's `asset`.
  function getPreviewPurchaseDataCost(
    address _set,
    address _trigger,
    uint256 _protection
  ) external view returns (uint256 _cost);

  /// @notice Returns the time remaining until the pending withdrawal with ID `_withdrawalId` in `_set` can be
  /// completed. The returned time is only equal to the amount of elapsed wall-clock time when the set is active, since
  /// time does not accrue during inactive states.
  function remainingWithdrawalDelay(address _set, uint256 _withdrawalId) external view returns (uint256 _delay);

  /// @notice Returns the `SetConfig` for the `_set`.
  function getSetConfig(address _set) external view returns (SetConfig memory);

  /// @notice Returns the `MarketInfo` for the market, identified by its `_set` and `_trigger` address.
  function getMarketInfo(address _set, address _trigger) external view returns (MarketInfo memory);

  /// @notice Returns an array of all trigger addresses in the `_set`.
  function allTriggers(address _set) external view returns (address[] memory _triggers);

  // -------------------------------------
  // -------- Address Computation --------
  // -------------------------------------

  /// @notice Given the `_salt`, `_asset`, `_setConfig`, and `_marketInfos` that will be used to create a set,
  /// compute and return the address that set will be deployed to.
  /// @dev The `_salt` is the user-provided salt, not the final salt after hashing with the chain ID.
  function computeSetAddress(
    bytes32 _salt,
    address _asset,
    SetConfig memory _setConfig,
    SetConfig[] memory _marketInfos
  ) external view returns (address);

  /// @notice Given a `_set` and its `_trigger` address, compute and return the address of its PToken.
  function computePTokenAddress(address _set, address _trigger) external view returns (address);
}
