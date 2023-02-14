// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {ICState} from "src/interfaces/ICState.sol";
import {ILFT} from "src/interfaces/ILFT.sol";
import {ITrigger} from "src/interfaces/ITrigger.sol";
import {ICostModel} from "src/interfaces/ICostModel.sol";
import {IDripDecayModel} from "src/interfaces/IDripDecayModel.sol";
import {ICozyStructs} from "src/interfaces/ICozyStructs.sol";

/**
 * @notice All protection markets live within a set.
 */
interface ISet is ILFT, ICState, ICozyStructs {
  function deposit(
    uint256 assets_,
    address receiver_
  ) external returns (uint256 shares_, DepositFeesAssets memory depositFeesAssets_);

  function maxDeposit() external view returns (uint256 maxDeposit_);

  function redeem(
    uint256 shares_,
    address receiver_,
    address owner_
  ) external returns (uint64 redemptionId_, uint256 assets_);

  function completeRedeem(uint64 redemptionId_) external returns (uint256 assetsRedeemed_);

  function maxRedemptionRequest(address owner_) external view returns (uint256 redeemableShares_);

  function previewRedemption(uint64 redemptionId_) external view returns (RedemptionPreview memory redemptionPreview_);

  function updateConfigs(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_) external;

  function finalizeUpdateConfigs(SetConfig calldata setConfig_, MarketConfig[] calldata marketConfigs_) external;

  function purchase(
    uint16 marketId_,
    uint256 protection_,
    address receiver_
  ) external returns (uint256 totalCost_, uint256 ptokens_, PurchaseFeesAssets memory purchaseFeesAssets_);

  function sell(
    uint16 marketId_,
    uint256 ptokens_,
    address receiver_,
    address owner_
  ) external returns (uint128 refund_, uint256 protection_);

  function previewSale(
    uint64 marketId_,
    uint256 ptokens_
  ) external view returns (uint256 refund_, uint256 protection_, SaleFeesAssets memory saleFeesAssets_);

  function pause() external;

  function unpause() external;

  function updateMarketState(MarketState newMarketState_) external;
}
