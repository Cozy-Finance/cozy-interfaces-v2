pragma solidity ^0.8.0;

interface IAccounting {
  // The global leverage factor
  uint256 public leverage;

  // The mapping of IMarket objects to their weights
  mapping(address => uint16) public marketWeights;

  // An array of IMarket objects
  IMarket[] public markets;

  // A constructor that initializes the leverage and markets
  constructor(uint256 _leverage, IMarket[] memory _markets) public;

  // A function that updates the weight for a given IMarket
  function updateMarketWeight(address _market, uint16 _weight) public;
}
