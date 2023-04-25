// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {MarketConfig, SetConfig} from "src/structs/Configs.sol";

/**
 * @notice The Manager is in charge of protocol-level configuration and exposes the `createSet` method used to create
 * new sets.
 */
interface IManager {
  /// @notice Emitted when accrued Cozy reserve fees and backstop fees are swept from a Set to the Cozy owner (for
  /// reserves) and backstop.
  event CozyFeesClaimed(address indexed set_, uint128 reserveAmount_, uint128 backstopAmount_);
  /// @dev Emitted when the delays affecting user actions are initialized or updated by the Cozy owner.
  event DelaysUpdated(Delays delays_);
  /// @dev Emitted when the deposit cap for an asset is updated by the Cozy owner.
  event DepositCapUpdated(address indexed asset_, uint256 depositCap_);
  /// @dev Emitted when the Cozy protocol fees are updated by the Cozy owner.
  event FeesUpdated(Fees fees_);
  /// @dev Emitted when the first step of the two step ownership transfer is executed.
  event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
  /// @dev Emitted when the owner address is updated.
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /// @dev Emitted when the pauser address is updated.
  event PauserUpdated(address indexed newPauser_);
  /// @dev Emitted when the Set owner claims their portion of fees.
  event SetFeesClaimed(address indexed set_, address receiver_, uint128 amount_);

  struct BackstopApproval {
    address set;
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

  function MAX_FEE() external view returns (uint256);
  function allowedMarketsPerSet() external view returns (uint256);
  function backstop() external view returns (address);
  function claimCozyFees(address[] memory sets_) external;
  function claimSetFees(address[] memory sets_, address receiver_) external;
  function configUpdateDelay() external view returns (uint32);
  function configUpdateGracePeriod() external view returns (uint32);
  function createSet(
    address owner_,
    address pauser_,
    address asset_,
    SetConfig memory setConfig_,
    MarketConfig[] memory marketConfigs_,
    bytes32 salt_
  ) external returns (address set_);
  function depositFees() external view returns (ProtocolFees memory depositFees_);
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
  function getDepositCap(address asset_) external view returns (uint256);
  function isSet(address) external view returns (bool);
  function minDepositDuration() external view returns (uint32);
  function owner() external view returns (address);
  function pauser() external view returns (address);
  function pendingOwner() external view returns (address);
  function purchaseDelay() external view returns (uint32);
  function purchaseFees() external view returns (ProtocolFees memory purchaseFees_);
  function redemptionDelay() external view returns (uint32);
  function saleFees() external view returns (ProtocolFees memory saleFees_);
  function setFactory() external view returns (address);
  function validateFees(Fees memory fees_) external pure returns (bool);
}
