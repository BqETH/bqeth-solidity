import { Contract } from 'ethers';
// deploy/01_deploy_checkpointbroker.ts

import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction, DiamondOptions, ExtendedArtifact, FacetCutAction, FacetOptions} from 'hardhat-deploy/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

// This works with  yarn hardhat deploy --network localhost --tags BqETHDiamond [--reset]
// yarn hardhat clean
// yarn hardhat node --no-deploy
const deployBrokerFunc: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {getNamedAccounts, deployments, getChainId, getUnnamedAccounts} = hre;
    const {diamond} = deployments;
    const {deployer, diamondAdmin} = await getNamedAccounts();
    console.log(deployer);

    const checkpointBroker = await deployments.deploy("CheckpointBroker", {
      from: deployer,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
    });
  
    console.log("Checkpoint Broker deployed at: ", checkpointBroker.address);
    console.log("Deployment Finished.")
  };
  
// 'all' here is to indicate that's all of the contracts, for tests that wait for 
// fixture 'all' to be deployed
deployBrokerFunc.tags = ['all', 'CheckpointBroker']; 

// Similar
export default deployBrokerFunc;
module.exports = deployBrokerFunc;
