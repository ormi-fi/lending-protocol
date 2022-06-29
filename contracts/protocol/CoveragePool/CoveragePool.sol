// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {SafeMath} from '../../dependencies/openzeppelin/contracts//SafeMath.sol';
import {IERC20} from '../../dependencies/openzeppelin/contracts//IERC20.sol';
import {IERC20Detailed} from '../../dependencies/openzeppelin/contracts//IERC20Detailed.sol';
import {Address} from '../../dependencies/openzeppelin/contracts/Address.sol';
import {SafeERC20} from '../../dependencies/openzeppelin/contracts/SafeERC20.sol';
import {ILendingPool} from '../../interfaces/ILendingPool.sol';
import {ILendingPoolAddressesProvider} from '../../interfaces/ILendingPoolAddressesProvider.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';
import {Errors} from '../libraries/helpers/Errors.sol';

//Needs To
// Allow the Lending Pool Collat manager to call for a certain amount that is unsecured
//Transfer the amount required to the Atoken pool for the collateral
// calc when to update the terms for the bonding contract based on current amount of unsecured loans

contract CoveragePool {

    /* ======== DEPENDENCIES ======== */

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ======== Modifiers ======== */

    modifier onlyPoolAdmin {
      require(addressesProvider.getPoolAdmin() == msg.sender, Errors.CALLER_NOT_POOL_ADMIN);
      _;
    }

      /* ======== STATE VARIABLS ======== */

    IERC20 immutable ormiToken; // token paid for principal

    ILendingPoolAddressesProvider public immutable addressesProvider;

    mapping(address => bool) public bondContract;

    /* ======== EVENTS ======== */

    event BondInitialized(address bondContract, address principalToken);
    event BondContractToggled(address bondContract, bool approved);
    event Withdraw(address token, address destination, uint256 amount);
    event TokensDonated(IERC20 token, uint256 amount);

    /* ======== CONSTRUCTOR ======== */

    constructor(
      address _ormiToken,
      address _addressesProvider
    ) public {
        require( _ormiToken != address(0) );
        ormiToken = IERC20(_ormiToken);

        addressesProvider = ILendingPoolAddressesProvider(_addressesProvider);
    }

    /// @notice To be called to initialize a new bonding contract
    /// @param _bonder The address of the bonding contract
    /// @param _principleToken The token that will be bonded to recieve Ormi Tokensg
    function initializeBond(address _bonder, address _principleToken) external onlyPoolAdmin {
      require(_bonder != address(0));
      bondContract[_bonder] = true;
      IERC20(_principleToken).safeApprove(addressesProvider.getLendingPool(), type(uint256).max);

      emit BondInitialized(_bonder, _principleToken);
    }

    /* ======== BOND CONTRACT FUNCTION ======== */

    /**
     *  @notice deposit principle token and recieve back payout token
     *  @param _principleTokenAddress address
     *  @param _amountPrincipleToken uint256
     *  @param _amountOrmiToken uint256
     */
    function deposit(address _principleTokenAddress, uint256 _amountPrincipleToken, uint256 _amountOrmiToken) external {
        require(bondContract[msg.sender], "msg.sender is not a bond contract");
        IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(this), _amountPrincipleToken);
        ormiToken.safeTransfer(msg.sender, _amountOrmiToken);
    }

    /* ======== VIEW FUNCTION ======== */

    /**
    *   @notice returns payout token valuation of priciple
    *   @param _principleTokenAddress address
    *   @param _amount uint256
    *   @return value_ uint256
     */
    function valueOfToken( address _principleTokenAddress, uint256 _amount ) public view returns ( uint256 value_ ) {
        // convert amount to match payout token decimals
        value_ = _amount.mul( 10 ** uint256(IERC20Detailed(address(ormiToken)).decimals()) ).div( 10 ** uint256(IERC20Detailed( _principleTokenAddress ).decimals()) );
    }

    /* ======== POLICY FUNCTIONS ======== */

    /**
        @notice toggle bond contract
        @param _bondContract address
     */
    function toggleBondContract(address _bondContract) external onlyPoolAdmin {
        bondContract[_bondContract] = !bondContract[_bondContract];
        emit BondContractToggled(_bondContract, bondContract[_bondContract]);
    }

    //What else do we want the assets to do;
/*
    /// @notice To be called to manually donate an amount into the liquidity pool if needed
    /// @param token The underlying token to deposit
    /// @param _amount The amount to deposit into the pool
    function donateToPool(IERC20 token, uint256 _amount) external onlyPoolAdmin{
      require(token.balanceOf(address(this)) >= _amount, "Not enough underlying balance for transfer");
      address aToken = ILendingPool(addressesProvider.getLendingPool()).getReserveData(address(token)).aTokenAddress;  <- Causes compiler error
      //Donating tokens to the pool. Will not update the rates until the next deposit/withdraw call
      token.safeTransfer(aToken, _amount);

      emit TokensDonated(token, _amount);
    }
    */

}
