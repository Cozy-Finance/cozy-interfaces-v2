// SPDX-License-Identifier: Business Source License 1.1
interface IBackstop {

  struct Backstop {
    uint128 fees;
    address owner;
  }

  /// @notice Returns the amount of assets for the Cozy backstop.
  function accruedFees() external view returns (uint128);   

  /// @notice Transfers accrued reserve and backstop fees to the `_owner` address and `_backstop` address, respectively.
  function claimFees(address _owner, address _backstop) external; 
}
