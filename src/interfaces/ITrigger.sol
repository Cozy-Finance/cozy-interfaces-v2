// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/**
 * @dev The minimal functions a trigger must implement to work with the Cozy protocol.
 */
interface ITrigger is ITriggerEvents {
  /// @dev Emitted when a new set is added to the trigger's list of sets.
  event SetAdded(ISet set);

  /// @dev Emitted when a trigger's state is updated.
  event TriggerStateUpdated(CState indexed state);

  /// @notice The current trigger state. This should never return PAUSED.
  function state() external returns(CState);

  /// @notice Called by the Manager to add a newly created set to the trigger's list of sets.
  function addSet(ISet set) external;
}
