// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {IERC20} from "src/interfaces/IERC20.sol";

/**
 * @dev Interface for LFT tokens.
 */
interface ILFT is IERC20 {
  struct MintData {
    uint176 amount;
    uint40 time;
    uint40 delay;
  }

  /// @notice Mapping from user address to the cumulative amount of tokens minted at the time of each of mint.
  function cumulativeMinted(address, uint256) external view returns (uint256);

  /// @notice Mapping from user address to all of their mints.
  function mints(address, uint256) external view returns (uint176 amount, uint40 time, uint40 delay);

  /// @notice Returns the array of metadata for all tokens minted to `user_`.
  function getMints(address user_) external view returns (MintData[] memory);

  /// @notice Returns the quantity of matured tokens held by the given `user_`.
  /// @dev A user's `balanceOfMatured` is computed by starting with `balanceOf[user_]` then subtracting the sum of
  /// all `amounts` from the  user's `mints` array that are not yet matured. How to determine when a given mint
  /// is matured is left to the implementer. It can be simple such as maturing when `block.timestamp >= time + delay`,
  /// or something more complex.
  function balanceOfMatured(address user_) external view returns (uint256);
}
