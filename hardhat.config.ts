import * as dotenv from 'dotenv';
import { HardhatUserConfig, HttpNetworkUserConfig } from "hardhat/types";
import "hardhat-deploy";
import 'hardhat-gas-reporter';
import '@nomiclabs/hardhat-etherscan';
import './tasks/tasks.ts';
import '@typechain/hardhat'
import '@nomicfoundation/hardhat-ethers';
import '@nomicfoundation/hardhat-chai-matchers';
import { Wallet } from "@ethersproject/wallet";
import { setupSafeDeployer } from "hardhat-safe-deployer";

dotenv.config();
const { INFURA_KEY } = process.env;

import yargs from "yargs";
const argv = yargs
    .option("network", {
      type: "string",
      default: "hardhat",
    })
    .help(false)
    .version(false).argv;
if (["mainnet", "rinkeby", "kovan", "goerli", "polygon-mainnet", "sepolia"].includes(argv.network) && INFURA_KEY === undefined) {
  throw new Error(
    `Could not find Infura key in env, unable to connect to network ${argv.network}`,
  );
}

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
const config: HardhatUserConfig = {
  solidity: '0.8.20',
  paths: {
    artifacts: './artifacts',
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  namedAccounts: {
    deployer: 0,  // Needed for Amoy
    diamondAdmin: 0
  },
  networks: {
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: false,
      live: false,
      saveDeployments: false,
      tags: ["test", "local"],
      deploy: [ 'deploy/' ],
      mining: {
        auto: false,
        interval: [1000, 2000]
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
    amoy: {
      chainId: 80002,
      live: true,
      saveDeployments: true,
      deploy: [ 'deploy/' ],
      url: `https://polygon-amoy.infura.io/v3/${process.env.INFURA_ID}` || '',
      accounts:
        process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY !== undefined
          ? [process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY]
          : []
    },
    "polygon-mainnet": {
      chainId: 137,
      live: true,
      saveDeployments: true,
      deploy: [ 'deploy/' ],
      url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_ID}` || '',
      accounts:
        process.env.ETH_ACCOUNT_PRIVATE_KEY !== undefined
          ? [process.env.ETH_ACCOUNT_PRIVATE_KEY]
          : []
    },
  },
  typechain: {
    outDir: 'types',
    target: 'ethers-v6',
    alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    externalArtifacts: ['externalArtifacts/*.json'], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
    dontOverrideCompile: false // defaults to false
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: 'USD'
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  verify: {
    etherscan: {
      apiKey: process.env.ETHERSCAN_API_KEY,
    },
  },
};


export default config;
