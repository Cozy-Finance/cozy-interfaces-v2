  // SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {ITrigger} from "src/interfaces/ITrigger.sol";
import {ICostModel} from "src/interfaces/ICostModel.sol";
import {IDripDecayModel} from "src/interfaces/IDripDecayModel.sol";

interface ICozyStructs {
  struct SetConfig {
    uint32 leverageFactor; // The set's leverage factor.
    uint16 depositFee; // Fee applied on each deposit and mint.
  }

  struct PurchaseFeesAssets {
    uint128 cost;
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 setOwnerFeeAssets;
  }

  struct SaleFeesAssets {
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 supplierFeeAssets;
  }

  /// @notice Market-level configuration.
  struct MarketConfig {
    ITrigger trigger; // Address of the trigger contract for this market.
    ICostModel costModel; // Contract defining the cost model for this market.
    IDripDecayModel dripDecayModel; // The model used for decay rate of PTokens and the rate at which funds are dripped to
      // suppliers for their yield.
    uint16 weight; // Weight of this market. Sum of weights across all markets must sum to 100% (1e4, 1 zoc).
    uint16 purchaseFee; // Fee applied on each purchase.
    uint16 saleFee; // Penalty applied on ptoken sales.
  }

  struct DepositFeesAssets {
    uint128 assets;
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 setOwnerFeeAssets;
  }

  struct RedemptionPreview {
    uint40 delayRemaining; // Protocol redemption delay remaining.
    uint176 shares; // Shares burned to queue the redemption.
    uint128 assets; // Amount of assets that will be paid out upon completion of the redemption.
    address owner; // Owner of the shares.
    address receiver; // Receiver of withdrawn assets.
  }
}
