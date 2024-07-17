// deploy/00_deploy_my_contract.ts

import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction, DiamondOptions, ExtendedArtifact, FacetCutAction, FacetOptions} from 'hardhat-deploy/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';


// This works with  yarn hardhat deploy --network localhost --tags BqETHDiamond [--reset]
// yarn hardhat clean
// yarn hardhat node --no-deploy
const deployDiamondFunc: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {getNamedAccounts, deployments, getChainId, getUnnamedAccounts} = hre;
    const {diamond} = deployments;
    const {deployer, diamondAdmin} = await getNamedAccounts();

    const bigNumberLibrary = await deployments.deploy("BigNumbers", {
      from: deployer,
      autoMine: true,
      log: true,
    });
    const merkleTreeVerifier = await deployments.deploy("MerkleTreeVerifier", {
      from: deployer,
      autoMine: true,
      log: true,
    });
    const pietrzakVerifier = await deployments.deploy("PietrzakVerifier", {
      from: deployer,
      autoMine: true,
      log: true,
    });

    const bqethStorageLibrary = await deployments.deploy("LibBqETH", {
      from: deployer,
      autoMine: true,
      log: true,
    });
  
    const diamondOptions: DiamondOptions = {
      from: deployer,
      owner: diamondAdmin,
      autoMine: true,
      log: true,
      libraries: {
        // Library Names must match what the compiler expects
        BigNumbers: bigNumberLibrary.address,
        PietrzakVerifier: pietrzakVerifier.address,
        LibBqETH: bqethStorageLibrary.address,
        MerkleTreeVerifier: merkleTreeVerifier.address
      },
      facets: [
        'IERC20MetaDataStub',
        'BqETH',
        'BqETHPublish',
        'BqETHSolve',
        'BqETHDecrypt',
        'BqETHManagement'
      ],
      defaultOwnershipFacet: true,
      defaultCutFacet: true,
    };
  
    await diamond.deploy('BqETHDiamond', diamondOptions)
  };
  
// 'all' here is to indicate that's all of the contracts, for tests that wait for 
// fixture 'all' to be deployed
deployDiamondFunc.tags = ['all', 'BqETHDiamond']; 

// Similar
export default deployDiamondFunc;
module.exports = deployDiamondFunc;
