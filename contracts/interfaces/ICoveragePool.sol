//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.12;

interface ICoveragePool {
    function deposit(address _principleTokenAddress, uint _amountPrincipleToken, uint _amountPayoutToken) external;
    function valueOfToken( address _principleTokenAddress, uint _amount ) external view returns ( uint value_ );
}
