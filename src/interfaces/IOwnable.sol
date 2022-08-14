pragma solidity ^0.8.10;

/**
 * @dev Contract module providing owner functionality.
 */
interface IOwnable {
  /// @dev Emitted when the owner address is updated.
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @notice Contract owner.
  function owner() view external returns (address);

  /// @notice Update owner of the contract to `_newOwner`.
  /// @param _newOwner The new owner of the contract.
  function updateOwner(address _newOwner) external;
}
