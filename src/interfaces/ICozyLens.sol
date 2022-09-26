// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IPToken.sol";
import "src/interfaces/ISet.sol";

/**
 * @notice Helper contract for reading data from the Cozy protocol.
 */
interface ICozyLens {
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
  function isSet(ISet _set) view external returns (bool _exists);

  /// @notice Returns true if the provided `_set` is approved to pull funds from the Backstop.
  function isSetApprovedForBackstop(ISet _set) view external returns (bool _approved);

  /// @notice Returns the set configUpdateTime
  function getConfigUpdateTime(ISet _set) view external returns (uint256 _configUpdateTime);

  /// @notice Returns the sets configUpdateDeadline
  function getConfigUpdateDeadline(ISet _set) view external returns (uint256 _configUpdateDeadline);

  // -----------------------------
  // -------- Set Methods --------
  // -----------------------------

  /// @notice Returns the state of the market, identified by its `_set` and `_trigger` address.
  function getMarketState(ISet _set, address _trigger) view external returns (ICState.CState _state);

  /// @notice Returns the state of the `_set`.
  function getSetState(ISet _set) view external returns (ICState.CState _state);

  /// @notice Returns the PToken address of the market, identified by its `_set` and `_trigger` address.
  function getPToken(ISet _set, address _trigger) view external returns (IPToken _ptoken);

  /// @notice Returns the amount of active protection remaining in the market, identified by its `_set` and `_trigger`
  /// address, denominated in units of the set's `asset`.
  function getActiveProtection(ISet _set, address _trigger) view external returns (uint256 _amount);

  /// @notice Returns the last decay time of the market, identified by its `_set` and `_trigger` address.
  function getLastDecayTime(ISet _set, address _trigger) view external returns (uint256 _timestamp);

  /// @notice Returns the current decay rate of the market, identified by its `_set` and `_trigger` address, as a wad.
  function getDecayRate(ISet _set, address _trigger) view external returns (uint256 _decayRate);

  /// @notice Returns the purchase fee of the market, identified by its `_set` and `_trigger` address, as a zoc.
  function getMarketPurchaseFee(ISet _set, address _trigger) view external returns (uint256 _purchaseFee);

  /// @notice Returns the weight of the market, identified by its `_set` and `_trigger` address, as a zoc.
  function getMarketWeight(ISet _set, address _trigger) view external returns (uint256 _weight);

  /// @notice Returns the address of the market's cost model, identified by its `_set` and `_trigger` address.
  function getMarketCostModel(ISet _set, address _trigger) view external returns (ICostModel _costModel);

  /// @notice Returns the cost, excluding fees, to purchase `_protection` amount of protection in the market,
  /// identified by its `_set` and `_trigger` address. The cost is in units of the set's `asset`.
  function getPreviewPurchaseDataCost(ISet _set, address _trigger, uint256 _protection) view external returns (uint256 _cost);

  /// @notice Returns the time remaining until the pending withdrawal with ID `_withdrawalId` in `_set` can be
  /// completed. The returned time is only equal to the amount of elapsed wall-clock time when the set is active, since
  /// time does not accrue during inactive states.
  function remainingWithdrawalDelay(ISet _set, uint256 _withdrawalId) view external returns (uint256 _delay);

  /// @notice Returns the `SetConfig` for the `_set`.
  function getSetConfig(ISet _set) view external returns (SetConfig memory);

  /// @notice Returns the `MarketInfo` for the market, identified by its `_set` and `_trigger` address.
  function getMarketInfo(ISet _set, address _trigger) view external returns (MarketInfo memory);

  /// @notice Returns an array of all trigger addresses in the `_set`.
  function allTriggers(ISet _set) view external returns (address[] memory _triggers);
}
