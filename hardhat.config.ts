import * as dotenv from 'dotenv';
import { HardhatUserConfig, task } from 'hardhat/config';
import "hardhat-deploy";
import 'hardhat-gas-reporter';
import '@nomiclabs/hardhat-etherscan';
import './tasks/tasks.ts';

dotenv.config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
const config: HardhatUserConfig = {
  solidity: '0.8.10',
  paths: {
    artifacts: './artifacts'
  },
  namedAccounts: {
    deployer: 0,
    diamondAdmin: 0,
  },
  networks: {
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: false,
      live: false,
      saveDeployments: true,
      tags: ["test", "local"],
      deploy: [ 'deploy/' ],
      mining: {
        auto: false,
        interval: [1000, 5000]
      }
    },
    localhost: {
      chainId: 1337,
      allowUnlimitedContractSize: true,
      saveDeployments: true,
      live: false,
      tags: ["test", "local"],
      deploy: [ 'deploy/' ],
      mining: {
        auto: false,
        interval: [1000,5000]
      }
    },
    goerli: {
      chainId: 5,
      live: true,
      saveDeployments: true,
      deploy: [ 'deploy/' ],
      url: `https://goerli.infura.io/v3/${process.env.INFURA_ID}` || '',
      accounts:
        process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY !== undefined
          ? [process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY]
          : []
    },
    sepolia: {
      chainId: 11155111,
      live: true,
      saveDeployments: true,
      deploy: [ 'deploy/' ],
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_ID}` || '',
      accounts:
        process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY !== undefined
          ? [process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY]
          : []
    },
    mumbai: {
      chainId: 80001,
      live: true,
      saveDeployments: true,
      deploy: [ 'deploy/' ],
      url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_ID}` || '',
      accounts:
        process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY !== undefined
          ? [process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY]
          : []
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: 'USD'
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};


export default config;
