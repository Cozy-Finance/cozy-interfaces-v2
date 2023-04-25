// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IChainlinkTrigger} from "src/interfaces/IChainlinkTrigger.sol";
import {IManager} from "src/interfaces/IManager.sol";
import {TriggerMetadata} from "src/structs/Triggers.sol";

/**
 * @notice Deploys Chainlink triggers that ensure two oracles stay within the given price
 * tolerance. It also supports creating a fixed price oracle to use as the truth oracle, useful
 * for e.g. ensuring stablecoins maintain their peg.
 */
interface IChainlinkTriggerFactory {
  /// @dev Emitted when the factory deploys a trigger.
  /// @param trigger_ Address at which the trigger was deployed.
  /// @param triggerConfigId_ Unique identifier of the trigger based on its configuration.
  /// @param truthOracle_ The address of the desired truthOracle for the trigger.
  /// @param trackingOracle_ The address of the desired trackingOracle for the trigger.
  /// @param priceTolerance_ The priceTolerance that the deployed trigger will have. See
  /// `ChainlinkTrigger.priceTolerance()` for more information.
  /// @param truthFrequencyTolerance_ The frequencyTolerance that the deployed trigger will have for the truth oracle.
  /// See
  /// `ChainlinkTrigger.truthFrequencyTolerance()` for more information.
  /// @param trackingFrequencyTolerance_ The frequencyTolerance that the deployed trigger will have for the tracking
  /// oracle. See
  /// `ChainlinkTrigger.trackingFrequencyTolerance()` for more information.
  /// @param name_ The name that should be used for markets that use the trigger.
  /// @param category_ The category of the trigger.
  /// @param description_ A human-readable description of the trigger.
  /// @param logoURI_ The URI of a logo image to represent the trigger.
  /// For other attributes, see the docs for the params of `deployTrigger` in
  /// this contract.
  event TriggerDeployed(
    address trigger_,
    bytes32 indexed triggerConfigId_,
    address indexed truthOracle_,
    address indexed trackingOracle_,
    uint256 priceTolerance_,
    uint256 truthFrequencyTolerance_,
    uint256 trackingFrequencyTolerance_,
    string name_,
    string category_,
    string description_,
    string logoURI_
  );

  /// @notice The manager of the Cozy protocol.
  function manager() external view returns (IManager);

  /// @notice Maps the triggerConfigId to the number of triggers created with those configs.
  function triggerCount(bytes32) external view returns (uint256);

  /// @notice Call this function to deploy a ChainlinkTrigger.
  /// @param truthOracle_ The address of the desired truthOracle for the trigger.
  /// @param trackingOracle_ The address of the desired trackingOracle for the trigger.
  /// @param priceTolerance_ The priceTolerance that the deployed trigger will
  /// have. See ChainlinkTrigger.priceTolerance() for more information.
  /// @param truthFrequencyTolerance_ The frequency tolerance that the deployed trigger will
  /// have for the truth oracle. See ChainlinkTrigger.truthFrequencyTolerance() for more information.
  /// @param trackingFrequencyTolerance_ The frequency tolerance that the deployed trigger will
  /// have for the tracking oracle. See ChainlinkTrigger.trackingFrequencyTolerance() for more information.
  /// @param metadata_ See TriggerMetadata for more info.
  function deployTrigger(
    AggregatorV3Interface truthOracle_,
    AggregatorV3Interface trackingOracle_,
    uint256 priceTolerance_,
    uint256 truthFrequencyTolerance_,
    uint256 trackingFrequencyTolerance_,
    TriggerMetadata memory metadata_
  ) external returns (IChainlinkTrigger trigger_);

  /// @notice Call this function to deploy a ChainlinkTrigger with a
  /// FixedPriceAggregator as its truthOracle. This is useful if you were
  /// building a market in which you wanted to track whether or not a stablecoin
  /// asset had become depegged.
  /// @param price_ The fixed price, or peg, with which to compare the trackingOracle price.
  /// @param decimals_ The number of decimals of the fixed price. This should
  /// match the number of decimals used by the desired _trackingOracle.
  /// @param trackingOracle_ The address of the desired trackingOracle for the trigger.
  /// @param priceTolerance_ The priceTolerance that the deployed trigger will
  /// have. See ChainlinkTrigger.priceTolerance() for more information.
  /// @param frequencyTolerance_ The frequency tolerance that the deployed trigger will
  /// have for the tracking oracle. See ChainlinkTrigger.trackingFrequencyTolerance() for more information.
  function deployTrigger(
    int256 price_,
    uint8 decimals_,
    AggregatorV3Interface trackingOracle_,
    uint256 priceTolerance_,
    uint256 frequencyTolerance_,
    TriggerMetadata memory metadata_
  ) external returns (IChainlinkTrigger trigger_);

  /// @notice Call this function to determine the address at which a trigger
  /// with the supplied configuration would be deployed.
  /// @param truthOracle_ The address of the desired truthOracle for the trigger.
  /// @param trackingOracle_ The address of the desired trackingOracle for the trigger.
  /// @param priceTolerance_ The priceTolerance that the deployed trigger would
  /// have. See ChainlinkTrigger.priceTolerance() for more information.
  /// @param truthFrequencyTolerance_ The frequency tolerance that the deployed trigger would
  /// have for the truth oracle. See ChainlinkTrigger.truthFrequencyTolerance() for more information.
  /// @param trackingFrequencyTolerance_ The frequency tolerance that the deployed trigger would
  /// have for the tracking oracle. See ChainlinkTrigger.trackingFrequencyTolerance() for more information.
  /// @param triggerCount_ The zero-indexed ordinal of the trigger with respect to its
  /// configuration, e.g. if this were to be the fifth trigger deployed with
  /// these configs, then triggerCount_ should be 4.
  function computeTriggerAddress(
    AggregatorV3Interface truthOracle_,
    AggregatorV3Interface trackingOracle_,
    uint256 priceTolerance_,
    uint256 truthFrequencyTolerance_,
    uint256 trackingFrequencyTolerance_,
    uint256 triggerCount_
  ) external view returns (address address_);

  /// @notice Call this function to find triggers with the specified
  /// configurations that can be used for new markets in Sets.
  /// @dev If this function returns the zero address, that means that an
  /// available trigger was not found with the supplied configuration. Use
  /// `deployTrigger` to deploy a new one.
  /// @param truthOracle_ The address of the desired truthOracle for the trigger.
  /// @param trackingOracle_ The address of the desired trackingOracle for the trigger.
  /// @param priceTolerance_ The priceTolerance that the deployed trigger will
  /// have. See ChainlinkTrigger.priceTolerance() for more information.
  /// @param truthFrequencyTolerance_ The frequency tolerance that the deployed trigger will
  /// have for the truth oracle. See ChainlinkTrigger.truthFrequencyTolerance() for more information.
  /// @param trackingFrequencyTolerance_ The frequency tolerance that the deployed trigger will
  /// have for the tracking oracle. See ChainlinkTrigger.trackingFrequencyTolerance() for more information.
  function findAvailableTrigger(
    AggregatorV3Interface truthOracle_,
    AggregatorV3Interface trackingOracle_,
    uint256 priceTolerance_,
    uint256 truthFrequencyTolerance_,
    uint256 trackingFrequencyTolerance_
  ) external view returns (address);

  /// @notice Call this function to determine the identifier of the supplied trigger
  /// configuration. This identifier is used both to track the number of
  /// triggers deployed with this configuration (see `triggerCount`) and is
  /// emitted at the time triggers with that configuration are deployed.
  /// @param truthOracle_ The address of the desired truthOracle for the trigger.
  /// @param trackingOracle_ The address of the desired trackingOracle for the trigger.
  /// @param priceTolerance_ The priceTolerance that the deployed trigger will
  /// have. See ChainlinkTrigger.priceTolerance() for more information.
  /// @param truthFrequencyTolerance_ The frequency tolerance that the deployed trigger will
  /// have for the truth oracle. See ChainlinkTrigger.truthFrequencyTolerance() for more information.
  /// @param trackingFrequencyTolerance_ The frequency tolerance that the deployed trigger will
  /// have for the tracking oracle. See ChainlinkTrigger.trackingFrequencyTolerance() for more information.
  function triggerConfigId(
    AggregatorV3Interface truthOracle_,
    AggregatorV3Interface trackingOracle_,
    uint256 priceTolerance_,
    uint256 truthFrequencyTolerance_,
    uint256 trackingFrequencyTolerance_
  ) external view returns (bytes32);

  /// @notice Call this function to deploy a FixedPriceAggregator contract,
  /// which behaves like a Chainlink oracle except that it always returns the
  /// same price.
  /// @dev If the specified contract is already deployed, we return it's address
  /// instead of reverting to avoid duplicate aggregators
  /// @param price_ The fixed price, in the decimals indicated, returned by the deployed oracle.
  /// @param decimals_ The number of decimals of the fixed price.
  function deployFixedPriceAggregator(int256 price_, uint8 decimals_) external returns (AggregatorV3Interface);

  /// @notice Call this function to compute the address that a
  /// FixedPriceAggregator contract would be deployed to with the provided args.
  /// @param price_ The fixed price, in the decimals indicated, returned by the deployed oracle.
  /// @param decimals_ The number of decimals of the fixed price.
  function computeFixedPriceAggregatorAddress(int256 price_, uint8 decimals_) external view returns (address);
}
