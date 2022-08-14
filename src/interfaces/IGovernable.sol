pragma solidity ^0.8.10;

import "src/interfaces/IOwnable.sol";

/**
 * @dev Contract module providing owner and pauser functionality.
 */
interface IGovernable is IOwnable {
  /// @dev Emitted when the pauser address is updated.
  event PauserUpdated(address indexed newPauser);

  /// @notice Contract pauser.
  function pauser() view external returns (address);

  /// @notice Update pauser to `_newPauser`.
  /// @param _newPauser The new pauser.
  function updatePauser(address _newPauser) external;
}
