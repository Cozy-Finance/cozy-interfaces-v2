// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {MarketConfig, SetConfig} from "src/structs/Configs.sol";
import {IERC20} from "src/interfaces/IERC20.sol";
import {ISet} from "src/interfaces/ISet.sol";

/**
 * @notice The Manager is in charge of the full Cozy protocol. Configuration parameters are defined here, it serves
 * as the entry point for all privileged operations, and exposes the `createSet` method used to create new sets.
 */
interface IManager {
  /// @notice Emitted when accrued Cozy reserve fees and backstop fees are swept from a Set to the Cozy owner (for
  /// reserves) and backstop.
  event CozyFeesClaimed(ISet indexed set, uint128 reserveAmount, uint128 backstopAmount);

  /// @dev Emitted when the delays affecting user actions are initialized or updated by the Cozy owner.
  event DelaysUpdated(Delays delays);

  /// @dev Emitted when the deposit cap for an asset is updated by the Cozy owner.
  event DepositCapUpdated(IERC20 indexed asset, uint256 depositCap);

  /// @dev Emitted when the Cozy protocol fees are updated by the Cozy owner.
  event FeesUpdated(Fees fees);

  /// @dev Emitted when the first step of the two step ownership transfer is executed.
  event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

  /// @dev Emitted when the owner address is updated.
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @dev Emitted when the pauser address is updated.
  event PauserUpdated(address indexed newPauser);

  struct BackstopApproval {
    ISet set;
    bool status;
  }

  struct Delays {
    uint256 configUpdateDelay;
    uint256 configUpdateGracePeriod;
    uint256 minDepositDuration;
    uint256 redemptionDelay;
    uint256 purchaseDelay;
  }

  struct Fees {
    uint16 depositFeeReserves;
    uint16 depositFeeBackstop;
    uint16 purchaseFeeReserves;
    uint16 purchaseFeeBackstop;
    uint16 saleFeeReserves;
    uint16 saleFeeBackstop;
  }

  struct ProtocolFees {
    uint16 reserveFee;
    uint16 backstopFee;
  }

  /// @notice Max fee for deposit and purchase.
  function MAX_FEE() external view returns (uint256);

  /// @notice Max allowed markets per set.
  function allowedMarketsPerSet() external view returns (uint256);

  /// @notice The Cozy protocol backstop.
  function backstop() external view returns (address);

  // @notice For all specified `sets_`, transfers accrued reserve and backstop fees to the owner address and
  /// backstop address, respectively.
  function claimCozyFees(ISet[] memory sets_) external;

  /// @notice Configuration updates are queued, then can be applied after this delay elapses.
  function configUpdateDelay() external view returns (uint32);

  /// @notice Once `configUpdateDelay` elapses, configuration updates must be applied before the grace period elapses.
  function configUpdateGracePeriod() external view returns (uint32);

  /// @notice Deploys a new set with the provided parameters.
  function createSet(
    address owner_,
    address pauser_,
    IERC20 asset_,
    SetConfig memory setConfig_,
    MarketConfig[] memory marketConfigs_,
    bytes32 salt_
  ) external returns (ISet set_);

  /// @notice Returns the fees applied on deposits that go to Cozy protocol reserves and backstop.
  function depositFees() external view returns (ProtocolFees memory depositFees_);

  /// @notice Protocol fees that can be applied on deposit/mint, purchase, and sell.
  function fees()
    external
    view
    returns (
      uint16 depositFeeReserves,
      uint16 depositFeeBackstop,
      uint16 purchaseFeeReserves,
      uint16 purchaseFeeBackstop,
      uint16 saleFeeReserves,
      uint16 saleFeeBackstop
    );

  /// @notice Returns the maximum amount of assets that can be deposited into a set that uses `asset_`.
  function getDepositCap(IERC20 asset_) external view returns (uint256);

  /// @notice Returns the owner and pauser addresses of the Cozy protocol.
  function getOwnerAndPauser() external view returns (address owner_, address pauser_);

  /// @notice For the specified set, returns whether it's a valid Cozy set.
  function isSet(address) external view returns (bool);

  /// @notice Minimum duration that funds must be supplied for before initiating a withdraw.
  function minDepositDuration() external view returns (uint32);

  /// @notice The Cozy protocol owner.
  function owner() external view returns (address);

  /// @notice The Cozy protocol pauser.
  function pauser() external view returns (address);

  /// @notice The pending new owner of the Cozy protocol.
  function pendingOwner() external view returns (address);

  /// @notice Duration that must elapse before purchased protection becomes active.
  function purchaseDelay() external view returns (uint32);

  /// @notice Returns the fees applied on purchases that go to Cozy protocol reserves and backstop.
  function purchaseFees() external view returns (ProtocolFees memory purchaseFees_);

  /// @notice Duration that must elapse before completing a redemption after initiating it.
  function redemptionDelay() external view returns (uint32);

  /// @notice Returns the fees applied on sales that go to Cozy protocol reserves and backstop.
  function saleFees() external view returns (ProtocolFees memory saleFees_);

  /// @notice The Cozy protocol SetFactory.
  function setFactory() external view returns (address);

  /// @notice Starts the ownership transfer of the Cozy protocol to a new account.
  function transferOwnership(address newOwner_) external;

  /// @notice Sets the approval statuses for each element in the `approvals_` array.
  function updateBackstopApprovals(BackstopApproval[] memory approvals_) external;

  /// @notice Update protocol delays.
  function updateDelays(Delays memory delays_) external;

  /// @notice Updates the deposit cap for `asset_` to `newDepositCap_`.
  function updateDepositCap(IERC20 asset_, uint256 newDepositCap_) external;

  /// @notice Update the protocol fees.
  function updateFees(Fees memory fees_) external;

  /// @notice Update the Cozy protocol pauser.
  function updatePauser(address _newPauser) external;

  /// @notice Returns true if the provided `fees_` are valid, false otherwise.
  function validateFees(Fees memory fees_) external pure returns (bool);
}
