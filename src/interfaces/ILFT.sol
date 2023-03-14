// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/**
 * @dev Interface for LFT tokens.
 */
interface ILFT {
  event Approval(address indexed owner, address indexed spender, uint256 amount);
  event Transfer(address indexed from, address indexed to, uint256 amount);

  struct MintData {
    uint216 amount;
    uint40 time;
  }

  function allowance(address, address) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address) external view returns (uint256);
  /// @notice Returns the quantity of matured tokens held by the given `user_`.
  /// @dev A user's `balanceOfMatured` is computed by starting with `balanceOf[user_]` then subtracting the sum of
  /// all `amounts` from the  user's `mints` array that are not yet matured. How to determine when a given mint
  /// is matured is left to the implementer. It can be simple such as maturing when `block.timestamp >= time + delay`,
  /// or something more complex.
  function balanceOfMatured(address user_) external view returns (uint256);
  /// @notice Mapping from user address to the cumulative amount of tokens minted at the time of each of mint.
  function cumulativeMinted(address, uint256) external view returns (uint256);
  function decimals() external view returns (uint8);
  /// @notice Returns the array of metadata for all tokens minted to `user_`.
  function getMints(address user_) external view returns (MintData[] memory);
  /// @notice Mapping from user address to all of their mints.
  function mints(address, uint256) external view returns (uint216 amount, uint40 time);
  function name() external view returns (string memory);
  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    external;
  function symbol() external view returns (string memory);
  function totalSupply() external view returns (uint256);
  function transfer(address to_, uint256 amount_) external returns (bool);
  function transferFrom(address from_, address to_, uint256 amount_) external returns (bool);
}
