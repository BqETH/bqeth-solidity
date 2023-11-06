import * as dotenv from 'dotenv';

import { HardhatUserConfig, task } from 'hardhat/config';
import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction, DiamondOptions} from 'hardhat-deploy/types';
import "hardhat-deploy";
import 'hardhat-deploy-ethers';
require('@symblox/hardhat-abi-gen');

import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import 'hardhat-gas-reporter';
import 'solidity-coverage';
import "@tovarishfin/hardhat-yul";
import './tasks/tasks.ts';

import { bufferToHex, privateToAddress, toBuffer, toChecksumAddress } from "@nomicfoundation/ethereumjs-util";

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
        interval: [16000, 25000]
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
        interval: [16000, 25000]
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
//   settings: {
//     viaIR: true,
//   },
};


export default config;
