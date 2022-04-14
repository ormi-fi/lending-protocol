import { task } from 'hardhat/config';
import {
  loadPoolConfig,
  ConfigNames,
  getEmergencyAdmin,
} from '../../helpers/configuration';
import { waitForTx, DRE, setDRE } from '../../helpers/misc-utils';
import {
  getLendingPoolAddressesProvider,
  getLendingPoolConfiguratorProxy,
} from './../../helpers/contracts-getters';
import { eNetwork } from '../../helpers/types';

// Note: replace below with actual deployed addresses.
const LENDING_POOL_ADDRESS_PROVIDER = {
  main: '',
  kovan: '0x9BF95C16b5698b3EeC6cC0d33728fAB40c691bd1',
};

task(
  'external:enable-lending-pool',
  'Enable or pause lending pool from operation. Note only admin authorizationi.'
)
  .setAction(async (DRE) => {
    try {
      await DRE.run('set-DRE');
      const network = <eNetwork>DRE.network.name;
      const poolConfig = loadPoolConfig(ConfigNames.Aave);

      const addressesProvider = await getLendingPoolAddressesProvider(
        LENDING_POOL_ADDRESS_PROVIDER[network]
      );

      const lendingPoolConfiguratorProxy = await getLendingPoolConfiguratorProxy(
        await addressesProvider.getLendingPoolConfigurator()
      );

      const admin = await DRE.ethers.getSigner(await getEmergencyAdmin(poolConfig));
      // Pause market during deployment
      await waitForTx(await lendingPoolConfiguratorProxy.connect(admin).setPoolPause(false));
    } catch (error) {
      // if (<eNetwork>DRE.network.name.includes('tenderly')) {
      //   const transactionLink = `https://dashboard.tenderly.co/${DRE.config.tenderly.username}/${
      //     DRE.config.tenderly.project
      //   }/fork/${DRE.tenderly.network().getFork()}/simulation/${DRE.tenderly.network().getHead()}`;
      //   console.error('Check tx error:', transactionLink);
      // }
      throw error;
    }
  });
