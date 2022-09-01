// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IConfig.sol";
import "src/interfaces/ICState.sol";
import "src/interfaces/IERC20.sol";
import "src/interfaces/ISet.sol";

/**
 * @notice The Manager is in charge of the full Cozy protocol. Configuration parameters are defined here, it serves
 * as the entry point for all privileged operations, and exposes the `createSet` method used to create new sets.
 */
interface IManager is ICState, IConfig {
  /// @dev Emitted when a new set is given permission to pull funds from the backstop if it has a shortfall after a trigger.
  event BackstopApprovalStatusUpdated(address indexed set, bool status);

  /// @dev Emitted when the Cozy configuration delays are updated, and when a set is created.
  event ConfigParamsUpdated(uint256 configUpdateDelay, uint256 configUpdateGracePeriod);

  /// @dev Emitted when a Set owner's queued set and market configuration updates are applied, and when a set is created.
  event ConfigUpdatesFinalized(address indexed set, SetConfig setConfig, MarketInfo[] marketInfos);

  /// @dev Emitted when a Set owner queues new set and/or market configurations.
  event ConfigUpdatesQueued(address indexed set, SetConfig setConfig, MarketInfo[] marketInfos, uint256 updateTime, uint256 updateDeadline);

  /// @dev Emitted when accrued Cozy reserve fees and backstop fees are swept from a Set to the Cozy owner (for reserves) and backstop.
  event CozyFeesClaimed(address indexed set);

  /// @dev Emitted when the delays affecting user actions are initialized or updated by the Cozy owner.
  event DelaysUpdated(uint256 minDepositDuration, uint256 withdrawDelay, uint256 purchaseDelay);

  /// @dev Emitted when the deposit cap for an asset is updated by the Cozy owner.
  event DepositCapUpdated(IERC20 indexed asset, uint256 depositCap);

  /// @dev Emitted when the Cozy protocol fees are updated by the Cozy owner.
  /// Changes to fees for the Set owner are emitted in ConfigUpdatesQueued and ConfigUpdatesFinalized.
  event FeesUpdated(Fees fees);

  /// @dev Emitted when a market, defined by it's trigger address, changes state.
  event MarketStateUpdated(address indexed set, address indexed trigger, CState indexed state);

  /// @dev Emitted when the owner address is updated.
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @dev Emitted when the pauser address is updated.
  event PauserUpdated(address indexed newPauser);

  /// @dev Emitted when the owner of a set is updated.
  event SetOwnerUpdated(address indexed set, address indexed owner);

  /// @dev Emitted when the Set owner claims their portion of fees.
  event SetFeesClaimed(address indexed set, address _receiver);

  /// @dev Emitted when the Set's pauser is updated.
  event SetPauserUpdated(address indexed set, address indexed pauser);

  /// @dev Emitted when the Set's state is updated.
  event SetStateUpdated(address indexed set, CState indexed state);

  /// @notice Used to update backstop approvals.
  struct BackstopApproval {
    ISet set;
    bool status;
  }

  /// @notice All delays that can be set by the Cozy owner.
  struct Delays {
    uint256 configUpdateDelay; // Duration between when a set/market configuration updates are queued and when they can be executed.
    uint256 configUpdateGracePeriod; // Defines how long the owner has to execute a configuration change, once it can be executed.
    uint256 minDepositDuration; // The minimum duration before a withdrawal can be initiated after a deposit.
    uint256 withdrawDelay; // If not paused, suppliers must queue a withdrawal and wait this long before completing the withdrawal.
    uint256 purchaseDelay; // Protection does not mature (i.e. it cannot claim funds from a trigger) until this delay elapses after purchase.
  }

  /// @notice All fees that can be set by the Cozy owner.
  struct Fees {
    uint16 depositFeeReserves;  // Fee charged on deposit and min, allocated to the protocol reserves, denoted in zoc.
    uint16 depositFeeBackstop; // Fee charged on deposit and min, allocated to the protocol backstop, denoted in zoc.
    uint16 purchaseFeeReserves; // Fee charged on purchase, allocated to the protocol reserves, denoted in zoc.
    uint16 purchaseFeeBackstop; // Fee charged on purchase, allocated to the protocol backstop, denoted in zoc.
    uint16 cancellationFeeReserves; // Fee charged on cancellation, allocated to the protocol reserves, denoted in zoc.
    uint16 cancellationFeeBackstop; // Fee charged on cancellation, allocated to the protocol backstop, denoted in zoc.
  }

  /// @notice A market or set is considered inactive when it's FROZEN or PAUSED.
  struct InactivityData {
    uint64 inactiveTransitionTime; // The timestamp the set/market transitioned from active to inactive, if currently inactive. 0 otherwise.
    InactivePeriod[] periods; // Array of all inactive periods for a set or market.
  }

  /// @notice Set related data.
  struct SetData {
    // When a set is created, this is updated to true.
    bool exists;
     // If true, this set can use funds from the backstop.
    bool approved;
    // Earliest timestamp at which finalizeUpdateConfigs can be called to apply config updates queued by updateConfigs.
    uint64 configUpdateTime;
    // Maps from set address to the latest timestamp after configUpdateTime at which finalizeUpdateConfigs can be
    // called to apply config updates queued by updateConfigs. After this timestamp, the queued config updates
    // expire and can no longer be applied.
    uint64 configUpdateDeadline;
  }

  /// @notice Max fee for deposit and purchase.
  function MAX_FEE() view external returns (uint256);

  /// @notice Returns the address of the Cozy protocol Backstop.
  function backstop() view external returns (address);

  /// @notice Returns the fees applied on cancellations that go to Cozy protocol reserves and backstop.
  function cancellationFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);

  /// @notice For all specified `_sets`, transfers accrued reserve and backstop fees to the owner address and
  /// backstop address, respectively.
  function claimCozyFees(ISet[] memory _sets) external;

  /// @notice Callable by the owner of `_set` and sends accrued fees to `_receiver`.
  function claimSetFees(ISet _set, address _receiver) external;

  /// @notice Configuration updates are queued, then can be applied after this delay elapses.
  function configUpdateDelay() view external returns (uint32);

  /// @notice Once `configUpdateDelay` elapses, configuration updates must be applied before the grace period elapses.
  function configUpdateGracePeriod() view external returns (uint32);

  /// @notice Deploys a new set with the provided parameters.
  function createSet(address _owner, address _pauser, address _asset, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos, bytes32 _salt) external returns (ISet _set);

  /// @notice Returns the fees applied on deposits that go to Cozy protocol reserves and backstop.
  function depositFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);

  /// @notice Returns protocol fees that can be applied on deposit/mint, purchase, and cancellation.
  function fees() view external returns (uint16 depositFeeReserves, uint16 depositFeeBackstop, uint16 purchaseFeeReserves, uint16 purchaseFeeBackstop, uint16 cancellationFeeReserves, uint16 cancellationFeeBackstop);

  /// @notice Execute queued updates to set config and market configs.
  function finalizeUpdateConfigs(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) external;

  /// @notice Returns the amount of delay time that has accrued since a timestamp.
  function getDelayTimeAccrued(uint256 _startTime, uint256 _currentInactiveDuration, InactivePeriod[] memory _inactivePeriods) view external returns (uint256);

  /// @notice Returns the maximum amount of assets that can be deposited into a set that uses `_asset`.
  function getDepositCap(address _asset) view external returns (uint256);

  /// @notice Returns the stored inactivity data for the specified `_set` and `_trigger`.
  function getMarketInactivityData(ISet _set, address _trigger) view external returns (InactivityData memory);

  /// @notice Returns the amount of time that accrued towards the withdrawal delay for the `_set`, given the
  /// `_startTime` and the `_setState`.
  function getWithdrawDelayTimeAccrued(ISet _set, uint256 _startTime, uint8 _setState) view external returns (uint256 _activeTimeElapsed);

  /// @notice Performs a binary search to return the cumulative inactive duration before a `_timestamp` based on
  /// the given `_inactivePeriods` that occurred.
  function inactiveDurationBeforeTimestampLookup(uint256 _timestamp, InactivePeriod[] memory _inactivePeriods) pure external returns (uint256);

  /// @notice Returns true if there is at least one FROZEN market in the `_set`, false otherwise.
  function isAnyMarketFrozen(ISet _set) view external returns (bool);

  /// @notice Returns true if the specified `_set` is approved for the backstop, false otherwise.
  function isApprovedForBackstop(ISet _set) view external returns (bool);

  /// @notice Returns true if `_who` is the local owner for the specified `_set`, false otherwise.
  function isLocalSetOwner(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is a valid market in the `_set`, false otherwise.
  function isMarket(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is the Cozy owner or the local owner for the specified `_set`, false otherwise.
  function isOwner(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is the Cozy owner/pauser or the local owner/pauser for the specified `_set`,
  /// false otherwise.
  function isOwnerOrPauser(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is the Cozy pauser or the local pauser for the specified `_set`, false otherwise.
  function isPauser(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if the provided `_setConfig` and `_marketInfos` pairing is generically valid, false otherwise.
  function isValidConfiguration(SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) pure external returns (bool);

  /// @notice Check if a state transition is valid for a market in a set.
  function isValidMarketStateTransition(ISet _set, address _who, uint8 _from, uint8 _to) view external returns (bool);

  /// @notice Returns true if the state transition from `_from` to `_to` is valid for the given `_set` when called
  /// by `_who`, false otherwise.
  function isValidSetStateTransition(ISet _set, address _who, uint8 _from, uint8 _to) view external returns (bool);

  /// @notice Returns true if the provided `_setConfig` and `_marketInfos` pairing is valid for the `_set`,
  /// false otherwise.
  function isValidUpdate(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) view external returns (bool);

  /// @notice Maps from set address to trigger address to metadata about previous inactive periods for markets.
  function marketInactivityData(address, address) view external returns (uint64 inactiveTransitionTime);

  /// @notice Minimum duration that funds must be supplied for before initiating a withdraw.
  function minDepositDuration() view external returns (uint32);

  /// @notice Returns the Manager contract owner address.
  function owner() view external returns (address);

  /// @notice Pauses the set.
  function pause(ISet _set) external;

  /// @notice Returns the manager Contract pauser address.
  function pauser() view external returns (address);

  /// @notice Returns the address of the Cozy protocol PTokenFactory.
  function ptokenFactory() view external returns (address);

  /// @notice Duration that must elapse before purchased protection becomes active.
  function purchaseDelay() view external returns (uint32);

  /// @notice Returns the fees applied on purchases that go to Cozy protocol reserves and backstop.
  function purchaseFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);

  /// @notice Maps from set address to a hash representing queued `SetConfig` and `MarketInfo[]` updates. This hash
  /// is used to prove that the `SetConfig` and `MarketInfo[]` params used when applying config updates are identical
  /// to the queued updates.
  function queuedConfigUpdateHash(address) view external returns (bytes32);

  /// @notice Returns the Cozy protocol SetFactory.
  function setFactory() view external returns (address);

  /// @notice Returns metadata about previous inactive periods for sets.
  function setInactivityData(address) view external returns (uint64 inactiveTransitionTime);

  /// @notice Returns the owner address for the given set.
  function setOwner(address) view external returns (address);

  /// @notice Returns the pauser address for the given set.
  function setPauser(address) view external returns (address);

  /// @notice For the specified set, returns whether it's a valid Cozy set, if it's approve to use the backstop,
  /// as well as timestamps for any configuration updates that are queued.
  function sets(ISet) view external returns (bool exists, bool approved, uint64 configUpdateTime, uint64 configUpdateDeadline);

  /// @notice Unpauses the set.
  function unpause(ISet _set) external;

  /// @notice Update params related to config updates.
  function updateConfigParams(uint256 _configUpdateDelay, uint256 _configUpdateGracePeriod) external;

  /// @notice Signal an update to the set config and market configs. Existing queued updates are overwritten.
  function updateConfigs(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) external;

  /// @notice Called by a trigger when it's state changes to `_newMarketState` to execute the corresponding state
  /// change in the market for the given `_set`.
  function updateMarketState(ISet _set, CState _newMarketState) external;

  /// @notice Updates the owner of `_set` to `_owner`.
  function updateSetOwner(ISet _set, address _owner) external;

  /// @notice Updates the pauser of `_set` to `_pauser`.
  function updateSetPauser(ISet _set, address _pauser) external;

  /// @notice Returns true if the provided `_fees` are valid, false otherwise.
  function validateFees(Fees memory _fees) pure external returns (bool);

  /// @notice Duration that must elapse before completing a withdrawal after initiating it.
  function withdrawDelay() view external returns (uint32);

  function VERSION() view external returns (uint256);
  function updateDepositCap(address _asset, uint256 _newDepositCap) external;
  function updateFees(Fees memory _fees) external;
  function updateOwner(address _newOwner) external;
  function updatePauser(address _newPauser) external;
  function updateUserDelays(uint256 _minDepositDuration, uint256 _withdrawDelay, uint256 _purchaseDelay) external;
  function upgradeTo(address newImplementation) external;
  function upgradeToAndCall(address newImplementation, bytes memory data) payable external;
}
