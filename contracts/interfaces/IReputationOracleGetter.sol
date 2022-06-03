// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

/**
 * @title IReputationOracleGetter interface
 * @notice Interface for the Ormi's reputation oracle.
 **/

interface IReputationOracleGetter {
  /**
   * @dev returns the reputation associated with a user.
   * @param user the address of the user we are querying.
   * @return the reputation score of the user
   **/
  function getReputationScore(address user) external view returns (uint256);
}
