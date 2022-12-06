// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./ICostModel.sol";
import "./IDripDecayModel.sol";

/**
 * @dev Structs used to define parameters in sets and markets.
 * @dev A "zoc" is a unit with 4 decimal places. All numbers in these config structs are in zocs, i.e. a
 * value of 900 translates to 900/10,000 = 0.09, or 9%.
 */
