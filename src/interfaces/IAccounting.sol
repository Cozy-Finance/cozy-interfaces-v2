pragma solidity ^0.8.0;

import "./IMarket.sol";

interface IAccounting {
  
  struct Accounting {
    uint128 assets;
    uint256 leverage;
    mapping(address => uint16) marketWeights;
  }

  // A constructor that initializes the leverage and markets
  constructor(uint256 _leverage, IMarket[] memory _markets) public;

  // A function that updates the weight for a given IMarket
  function updateMarketWeight(address _market, uint16 _weight) public;

  /// @notice Returns the internal asset balance - equivalent to `asset.balanceOf(address(set))` if no one transfers tokens directly to the contract.
  function assetBalance() external view returns (uint128);
}
