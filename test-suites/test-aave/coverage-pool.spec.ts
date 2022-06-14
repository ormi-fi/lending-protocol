import BigNumber from 'bignumber.js';

import { ZERO_ADDRESS } from '../../helpers/constants';
import { makeSuite } from './helpers/make-suite';
import { ProtocolErrors } from '../../helpers/types';

const chai = require('chai');
const { expect } = chai;

makeSuite('CoveragePool', (testEnv) => {
  const { CALLER_NOT_POOL_ADMIN } = ProtocolErrors;

  it('Check basic coverge pool is deployed and functional', async () => {
    const { deployer, users, coveragePool } = testEnv;

    const valueOfToken = await coveragePool.connect(deployer.signer).valueOfToken(ZERO_ADDRESS, 0);
    expect(new BigNumber(0).toString()).to.be.bignumber.equal(valueOfToken.toString());

    // Deployer is also the pool admin so the following call should pass.
    await expect(coveragePool.connect(deployer.signer).initializeBond(ZERO_ADDRESS, ZERO_ADDRESS));

    // User 1 is not the pool admin, so we should expect the following call reverted.
    await expect(
      coveragePool.connect(users[1].signer).initializeBond(ZERO_ADDRESS, ZERO_ADDRESS)
    ).to.be.revertedWith(CALLER_NOT_POOL_ADMIN);
  });
});
