// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./ICostModel.sol";
import "./IDripDecayModel.sol";

/**
 * @dev Structs used to define parameters in sets and markets.
 * @dev A "zoc" is a unit with 4 decimal places. All numbers in these config structs are in zocs, i.e. a
 * value of 900 translates to 900/10,000 = 0.09, or 9%.
 */

/// @notice PTokens and are not eligible to claim protection until maturity. It takes `purchaseDelay` seconds for a PToken
/// to mature, but time during an InactivePeriod is not counted towards maturity. Similarly, there is a delay
/// between requesting a withdrawal and completing that withdrawal, and inactive periods do not count towards that
/// withdrawal delay.
struct InactivePeriod {
  uint64 startTime; // Timestamp that this inactive period began.
  uint64 cumulativeDuration; // Cumulative inactive duration of all prior inactive periods and this inactive period at the point when this inactive period ended.
}
