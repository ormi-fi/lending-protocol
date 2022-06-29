//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

interface ICoveragePool {
  function deposit(
    address _principleTokenAddress,
    uint256 _amountPrincipleToken,
    uint256 _amountPayoutToken
  ) external;

  function valueOfToken(address _principleTokenAddress, uint256 _amount)
    external
    view
    returns (uint256 value_);
}