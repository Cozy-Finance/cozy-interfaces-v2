// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {ISet} from "src/interfaces/ISet.sol";

interface ICozyRouter {
  struct SaleFeesAssets {
    uint128 reserveFeeAssets;
    uint128 backstopFeeAssets;
    uint128 supplierFeeAssets;
  }

  function aggregate(bytes[] memory calls_) external payable returns (bytes[] memory returnData_);
  function cancel(ISet set_, uint16 marketId_, uint256 protection_, address receiver_, uint256 minRefund_)
    external
    payable
    returns (uint256 refund_, uint256 ptokens_);
  function claim(ISet set_, uint16 marketId_, uint256 ptokens_, address receiver_)
    external
    payable
    returns (uint256 protection_);
  function completeRedeem(ISet set_, uint64 id_) external payable;
  function completeWithdraw(ISet set_, uint64 id_) external payable;
  function deposit(ISet set_, uint256 assets_, address receiver_, uint256 minSharesReceived_)
    external
    payable
    returns (uint256 shares_);
  function depositWithoutTransfer(ISet set_, uint256 assets_, address receiver_, uint256 minSharesReceived_)
    external
    payable
    returns (uint256 shares_);
  function manager() external view returns (address);
  function maxWithdrawalRequest(ISet set_, address owner_)
    external
    view
    returns (uint256 withdrawableAssets_, uint256 redeemableShares_);
  function payout(ISet set_, uint16 marketId_, uint256 protection_, address receiver_)
    external
    payable
    returns (uint256 ptokens_, uint256 protectionClaimed_);
  function permitRouter(address token_, uint256 value_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_)
    external
    payable;
  function previewCancellation(ISet set_, uint16 marketId_, uint256 protection_)
    external
    view
    returns (uint256 refund_, uint256 ptokens_, SaleFeesAssets memory saleFeesAssets_);
  function pullToken(address token_, address recipient_, uint256 amount_) external payable;
  function purchase(ISet set_, uint16 marketId_, uint256 protection_, address receiver_, uint256 maxCost_)
    external
    payable
    returns (uint256 assetsNeeded_, uint256 ptokens_);
  function purchaseWithoutTransfer(ISet set_, uint16 marketId_, uint256 protection_, address receiver_)
    external
    payable
    returns (uint256 ptokens_);
  function redeem(ISet set_, uint256 shares_, address receiver_, uint256 minAssetsReceived_)
    external
    payable
    returns (uint64 redemptionId_, uint256 assets_);
  function sell(ISet set_, uint16 marketId_, uint256 ptokens_, address receiver_, uint256 minRefund_)
    external
    payable
    returns (uint256 refund_, uint256 protection_);
  function stEth() external view returns (address);
  function sweepToken(address token_, address recipient_, uint256 amountMin_)
    external
    payable
    returns (uint256 amount_);
  function transferTokens(address token_, address recipient_, uint256 amount_) external payable;
  function unwrapStEth(address recipient_) external;
  function unwrapWeth(address recipient_, uint256 amount_) external payable;
  function unwrapWeth(address recipient_) external payable;
  function unwrapWrappedAssetViaConnector(address connector_, uint256 assets_, address receiver_) external payable;
  function unwrapWrappedAssetViaConnectorForWithdraw(address connector_, address receiver_) external payable;
  function weth() external view returns (address);
  function withdraw(ISet set_, uint256 assets_, address receiver_, uint256 maxSharesBurned_)
    external
    payable
    returns (uint64 redemptionId_, uint256 shares_);
  function wrapBaseAssetViaConnectorAndDeposit(
    address connector_,
    ISet set_,
    uint256 assets_,
    address receiver_,
    uint256 minSharesReceived_
  ) external payable returns (uint256 shares_);
  function wrapBaseAssetViaConnectorAndPurchase(
    address connector_,
    ISet set_,
    uint16 marketId_,
    uint256 protection_,
    address receiver_,
    uint256 maxCost_
  ) external payable returns (uint256 ptokens_);
  function wrapStEth(ISet set_) external;
  function wrapStEth(ISet set_, uint256 amount_) external;
  function wrapStEthForPurchase(ISet set_, uint16 marketId_, uint256 protection_, uint256 maxCost_) external payable;
  function wrapWeth(ISet set_, uint256 amount_) external payable;
  function wrapWeth(ISet set_) external payable;
  function wrapWethForPurchase(ISet set_, uint16 marketId_, uint256 protection_, uint256 maxCost_) external payable;
  function wstEth() external view returns (address);
}
