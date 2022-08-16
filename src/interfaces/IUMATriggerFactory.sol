// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/**
 * @notice This is a utility contract to make it easy to deploy UMATriggers for
 * the Cozy protocol.
 * @dev Be sure to approve the trigger to spend the rewardAmount before calling
 * `deployTrigger`, otherwise the latter will revert. Funds need to be available
 * to the created trigger within its constructor so that it can submit its query
 * to the UMA oracle.
 */
interface IUMATriggerFactory {
  /// @dev Emitted when the factory deploys a trigger.
  /// The `trigger` is the address at which the trigger was deployed.
  /// For `triggerConfigId`, see the function of the same name in this contract.
  /// For other attributes, see the docs for the params of `deployTrigger` in
  /// this contract.
  event TriggerDeployed(
    address trigger,
    bytes32 indexed triggerConfigId,
    address indexed umaOracleFinder,
    string query,
    address indexed rewardToken,
    uint256 rewardAmount,
    uint256 bondAmount,
    uint256 proposalDisputeWindow
  );

  /// @notice The manager of the Cozy protocol.
  function manager() view external returns (address);

  /// @notice The UMA contract used to lookup the UMA Optimistic Oracle.
  function oracleFinder() view external returns (address);

  /// @notice Maps the triggerConfigId to the number of triggers created with those configs.
  function triggerCount(bytes32) view external returns (uint256);

  /// @notice Call this function to deploy a UMATrigger.
  /// @param _query The query that the trigger will send to the UMA Optimistic
  /// Oracle for evaluation.
  /// @param _rewardToken The token used to pay the reward to users that propose
  /// answers to the query.
  /// @param _rewardAmount The amount of rewardToken that will be paid to users
  /// who propose an answer to the query.
  /// @param _bondAmount The amount of `rewardToken` that must be staked by a
  /// user wanting to propose or dispute an answer to the query. See UMA's price
  /// dispute workflow for more information. It's recommended that the bond
  /// amount be a significant value to deter addresses from proposing malicious,
  /// false, or otherwise self-interested answers to the query.
  /// @param _proposalDisputeWindow The window of time in seconds within which a
  /// proposed answer may be disputed. See UMA's "customLiveness" setting for
  /// more information. It's recommended that the dispute window be fairly long
  /// (12-24 hours), given the difficulty of assessing expected queries (e.g.
  /// "Was protocol ABCD hacked") and the amount of funds potentially at stake.
  function deployTrigger(
    string memory _query,
    address _rewardToken,
    uint256 _rewardAmount,
    uint256 _bondAmount,
    uint256 _proposalDisputeWindow
  ) external returns (address _trigger);

  /// @notice Call this function to determine the address at which a trigger
  /// with the supplied configuration would be deployed. See `deployTrigger` for
  /// more information on parameters and their meaning.
  function computeTriggerAddress(
    string memory _query,
    address _rewardToken,
    uint256 _rewardAmount,
    uint256 _bondAmount,
    uint256 _proposalDisputeWindow,
    uint256 _triggerCount
  ) view external returns (address _address);

  /// @notice Call this function to find triggers with the specified
  /// configurations that can be used for new markets in Sets. See
  /// `deployTrigger` for more information on parameters and their meaning.
  function findAvailableTrigger(
    string memory _query,
    address _rewardToken,
    uint256 _rewardAmount,
    uint256 _bondAmount,
    uint256 _proposalDisputeWindow
  ) view external returns (address);

  /// @notice Call this function to determine the identifier of the supplied
  /// trigger configuration. This identifier is used both to track the number of
  /// triggers deployed with this configuration (see `triggerCount`) and is
  /// emitted at the time triggers with that configuration are deployed.
  function triggerConfigId(
    string memory _query,
    address _rewardToken,
    uint256 _rewardAmount,
    uint256 _bondAmount,
    uint256 _proposalDisputeWindow
  ) view external returns (bytes32);
}
