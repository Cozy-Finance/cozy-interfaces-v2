// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IERC20.sol";

/**
 * @dev Interface for LFT tokens.
 */
interface ILFT is IERC20 {
  /// @notice Data saved off on each mint.
  struct MintMetadata {
    uint128 amount; // Amount of tokens minted.
    uint64 time; // Timestamp of the mint.
    uint64 delay; // Delay until these tokens mature and become fungible.
  }

  /// @notice Mapping from user address to all of their mints.
  function mints(address, uint256) view external returns (uint128 amount, uint64 time, uint64 delay);

  /// @notice Returns the array of metadata for all tokens minted to `_user`.
  function getMints(address _user) view external returns (MintMetadata[] memory);

  /// @notice Returns the quantity of matured tokens held by the given `_user`.
  /// @dev A user's `balanceOfMatured` is computed by starting with `balanceOf[_user]` then subtracting the sum of
  /// all `amounts` from the  user's `mints` array that are not yet matured. How to determine when a given mint
  /// is matured is left to the implementer. It can be simple such as maturing when `block.timestamp >= time + delay`,
  /// or something more complex.
  function balanceOfMatured(address _user) view external returns (uint256);

  /// @notice Moves `_amount` tokens from the caller's account to `_to`. Tokens must be matured to transfer them.
  function transfer(address _to, uint256 _amount) external returns (bool);

  /// @notice Moves `_amount` tokens from `_from` to `_to`. Tokens must be matured to transfer them.
  function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}
