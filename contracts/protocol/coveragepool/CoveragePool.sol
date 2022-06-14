// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {ICoveragePool} from '../../interfaces/ICoveragePool.sol';
import {ILendingPoolAddressesProvider} from '../../interfaces/ILendingPoolAddressesProvider.sol';
import {VersionedInitializable} from '../libraries/aave-upgradeability/VersionedInitializable.sol';
import {Errors} from '../libraries/helpers/Errors.sol';

contract CoveragePool is VersionedInitializable, ICoveragePool {
  uint256 public constant COVERAGEPOOL_REVISION = 0x1;

  modifier onlyPoolAdmin() {
    require(_addressesProvider.getPoolAdmin() == msg.sender, Errors.CALLER_NOT_POOL_ADMIN);
    _;
  }

  ILendingPoolAddressesProvider internal _addressesProvider;

  function getRevision() internal pure override returns (uint256) {
    return COVERAGEPOOL_REVISION;
  }

  /**
   * @dev Function is invoked by the proxy contract when the LendingPool contract is added to the
   * LendingPoolAddressesProvider of the market.
   * - Caching the address of the LendingPoolAddressesProvider in order to reduce gas consumption
   *   on subsequent operations
   * @param provider The address of the LendingPoolAddressesProvider
   **/
  function initialize(ILendingPoolAddressesProvider provider) public initializer {
    _addressesProvider = provider;
  }

  /**
   *  @notice deposit principle token and recieve back payout token
   *  @param _principleTokenAddress address
   *  @param _amountPrincipleToken uint256
   *  @param _amountOrmiToken uint256
   */
  function deposit(
    address _principleTokenAddress,
    uint256 _amountPrincipleToken,
    uint256 _amountOrmiToken
  ) external override {
    // TODO: stubbed function
  }

  /**
   *   @notice returns payout token valuation of priciple
   *   @param _principleTokenAddress address
   *   @param _amount uint256
   *   @return value_ uint256
   */
  function valueOfToken(address _principleTokenAddress, uint256 _amount)
    external
    view
    override
    returns (uint256 value_)
  {
    // TODO: stubbed function.
    return uint256(0);
  }
}
