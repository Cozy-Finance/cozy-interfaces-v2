// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/**
 * @notice Users receive protection tokens when purchasing protection. Each protection token contract is associated
 * with a single market, and protection tokens are minted to a user proportional to the amount of protection they
 * purchase. When a market triggers, protection tokens can be redeemed to claim assets.
 */
interface IPToken {
  /// @notice Address of the Cozy protocol manager.
  function manager() external view returns (address);

  /// @notice The set this token is for.
  function set() external view returns (address);

  /// @notice The trigger this token is for. Markets in a set are uniquely identified by their trigger.
  function trigger() external view returns (address);
}
