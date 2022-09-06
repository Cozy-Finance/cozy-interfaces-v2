// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ICozyMetadataRegistry {
  /// @notice Required metadata for a given set or trigger.
  struct Metadata {
    string name; // Name of the set or trigger.
    string description; // Description of the set or trigger.
    string logoURI; // Path to a logo for the set or trigger.
  }

  /// @dev Emitted when a set's metadata is updated.
  event SetMetadataUpdated(address indexed set, Metadata metadata);

  /// @dev Emitted when a trigger's metadata is updated.
  event TriggerMetadataUpdated(address indexed trigger, Metadata metadata);

  /// @notice Address of the Cozy protocol manager.
  function manager() external view returns (address);

  /// @notice Update metadata for sets.
  /// @param sets An array of sets to be updated.
  /// @param metadata An array of new metadata, mapping 1:1 with the addresses in the _sets array.
  function updateSetMetadata(address[] memory sets, Metadata[] memory metadata) external;

  /// @notice Update metadata for a set.
  /// @param set The address of the set.
  /// @param metadata The new metadata for the set.
  function updateSetMetadata(address set, Metadata memory metadata) external;

  /// @notice Update metadata for a trigger.
  /// @param trigger The address of the trigger.
  /// @param metadata The new metadata for the trigger.
  function updateTriggerMetadata(address trigger, Metadata memory metadata) external;

  /// @notice Update metadata for triggers.
  /// @param triggers An array of triggers to be updated.
  /// @param metadata An array of new metadata, mapping 1:1 with the addresses in the _triggers array.
  function updateTriggerMetadata(address[] memory triggers, Metadata[] memory metadata) external;
}
