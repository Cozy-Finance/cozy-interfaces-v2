interface IReserve {
  /// @notice Returns the amount of assets for generic Cozy reserves.
  function accruedFees() external view returns (uint128);
}