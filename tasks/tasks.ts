import '@nomiclabs/hardhat-waffle';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import {DeployFunction, DiamondOptions} from 'hardhat-deploy/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

// This is a sample Hardhat task. To learn how to create your own go to https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    const bal = await account.getBalance();
    console.log(account.address + ':' + bal);
    console.log();
  }
});


task("bqeth", "Deploys BqETH , get wallets, and outputs files", async (taskArgs, hre) => {
  // We get the contract to deploy
  const BqETH = await hre.ethers.getContractFactory("BqETH");
  const bqeth = await BqETH.deploy();
  // Await deployment
  await bqeth.deployed();
  // Get address
  const contractAddress = bqeth.address;
  // Write file
  //fs.writeFileSync('./.contract', contractAddress);
  // Get generated signer wallets
  const accounts = await hre.ethers.getSigners();
  // Get the first wallet address
  const walletAddress = accounts[0].address;
  // Write file
  //fs.writeFileSync('./.wallet', walletAddress);
});

// This is obsoleted by use of the hardhat-deploy plug-in, which already declares 
// all of these interfaces and default facets using its own contracts
// Using yarn hardhat deploy --network localhost --tags MyDiamond --watch 

// task("obsolete-diamond-deploy", "Deploys Generic Diamond", async (taskArgs, hre) => {
//     const {deployments, getNamedAccounts} = hre;
//     const {diamond} = deployments;
//     const {deployer, diamondAdmin} = await getNamedAccounts();
  
//     const diamondOptions: DiamondOptions = {
//       from: deployer,
//       owner: diamondAdmin,
//       autoMine: true,
//       log: true,
//       facets: [
//         // 'BigNumbers',
//         // 'PietrzakVerifier',
//         'Test1Facet',
//         'Test2Facet',
//         // 'DiamondCutFacet', 
//         // 'DiamondInit', 
//         // 'DiamondLoupeFacet', 
//         // 'OwnershipFacet' 
//       ],
//       defaultOwnershipFacet: true,
//       defaultCutFacet: true,
//     };
  
//     await diamond.deploy('BqETH', diamondOptions).then(() => process.exit(0))
//         .catch(error => {
//           console.error(error)
//           process.exit(1)
//         })
//     ;
// });

