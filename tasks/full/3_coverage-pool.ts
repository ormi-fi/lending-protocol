import { task } from 'hardhat/config';
import { deployCoveragePool } from '../../helpers/contracts-deployments';
import { eContractid } from '../../helpers/types';
import { waitForTx } from '../../helpers/misc-utils';
import { getLendingPoolAddressesProvider, getCoveragePool } from '../../helpers/contracts-getters';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { insertContractAddressInDb } from '../../helpers/contracts-helpers';
import { ConfigNames, loadPoolConfig } from '../../helpers/configuration';

task('full:deploy-coverage-pool', 'Deploy coverage pool for full enviroment')
  .addFlag('verify', 'Verify contracts at Etherscan')
  .setAction(async ({ verify }, DRE: HardhatRuntimeEnvironment) => {
    try {
      await DRE.run('set-DRE');
      const addressesProvider = await getLendingPoolAddressesProvider();

      const coveragePoolImpl = await deployCoveragePool(verify);

      // Set coverage pool impl to Address Provider
      await waitForTx(await addressesProvider.setCoveragePoolImpl(coveragePoolImpl.address));

      const address = await addressesProvider.getCoveragePool();
      const coveragePoolProxy = await getCoveragePool(address);

      await insertContractAddressInDb(eContractid.CoveragePool, coveragePoolProxy.address);
    } catch (error) {
      if (DRE.network.name.includes('tenderly')) {
        const transactionLink = `https://dashboard.tenderly.co/${DRE.config.tenderly.username}/${
          DRE.config.tenderly.project
        }/fork/${DRE.tenderly.network().getFork()}/simulation/${DRE.tenderly.network().getHead()}`;
        console.error('Check tx error:', transactionLink);
      }
      throw error as Error;
    }
  });
