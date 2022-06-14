import { task } from 'hardhat/config';
import { deployCoveragePool } from '../../helpers/contracts-deployments';
import { eContractid } from '../../helpers/types';
import { waitForTx } from '../../helpers/misc-utils';
import { getLendingPoolAddressesProvider, getCoveragePool } from '../../helpers/contracts-getters';
import { insertContractAddressInDb } from '../../helpers/contracts-helpers';
import { ConfigNames, loadPoolConfig } from '../../helpers/configuration';

task('dev:deploy-coverage-pool', 'Deploy coverage pool for dev enviroment')
  .addFlag('verify', 'Verify contracts at Etherscan')
  .addParam('pool', `Pool name to retrieve configuration, supported: ${Object.values(ConfigNames)}`)
  .setAction(async ({ verify, pool }, localBRE) => {
    await localBRE.run('set-DRE');
    const addressesProvider = await getLendingPoolAddressesProvider();
    const poolConfig = loadPoolConfig(pool);

    const coveragePoolImpl = await deployCoveragePool(verify);

    // Set lending pool impl to Address Provider
    await waitForTx(await addressesProvider.setCoveragePoolImpl(coveragePoolImpl.address));

    const address = await addressesProvider.getCoveragePool();
    const coveragePoolProxy = await getCoveragePool(address);

    await insertContractAddressInDb(eContractid.CoveragePool, coveragePoolProxy.address);
  });
