// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/**
 * @notice Users receive protection tokens when purchasing protection. Each protection token contract is associated
 * with a single market, and protection tokens are minted to a user proportional to the amount of protection they
 * purchase. When a market triggers, protection tokens can be redeemed to claim assets.
 */
interface IPToken {
  /// @dev Emitted when the allowance of a `spender_` for an `owner_` is updated, where `amount_` is the new allowance.
  event Approval(address indexed owner_, address indexed spender_, uint256 amount_);
  /// @dev Emitted when `amount_` tokens are moved from `from_` to `to_`.
  event Transfer(address indexed from_, address indexed to_, uint256 amount_);

  struct MintData {
    uint216 amount;
    uint40 time;
  }

  function allowance(address, address) external view returns (uint256);
  function approve(address spender_, uint256 amount_) external returns (bool);
  function balanceOf(address) external view returns (uint256);
  function balanceOfMatured(address user_) external view returns (uint256 balance_);
  function burn(address caller_, address owner_, uint216 amount_) external;
  function cumulativeMinted(address, uint256) external view returns (uint256);
  function decimals() external view returns (uint8);
  function getMints(address user_) external view returns (MintData[] memory);
  function inactivityData() external view returns (uint64 inactiveTransitionTime);
  function manager() external view returns (address);
  function mint(address to_, uint216 amount_) external;
  function mints(address, uint256) external view returns (uint216 amount, uint40 time);
  function name() external view returns (string memory);
  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    external;
  /// @notice The set this token is for.
  function set() external view returns (address);
  function symbol() external view returns (string memory);
  function totalSupply() external view returns (uint256);
  function transfer(address to_, uint256 amount_) external returns (bool);
  function transferFrom(address from_, address to_, uint256 amount_) external returns (bool);
  /// @notice The trigger this token is for. Markets in a set are uniquely identified by their trigger.
  function trigger() external view returns (address);
}
