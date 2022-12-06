interface ISetAdmin {
  /// @notice Returns the amount of assets accrued to the set owner.
  function accruedFees() external view returns (uint128);
}