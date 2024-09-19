import { Contract } from 'ethers';
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
    console.log(deployer);

    const bigNumberLibrary = await deployments.deploy("BigNumbers", {
      from: deployer,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
    });
    const merkleTreeVerifier = await deployments.deploy("MerkleTreeVerifier", {
      from: deployer,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
    });
    const pietrzakVerifier = await deployments.deploy("PietrzakVerifier", {
      from: deployer,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
    });

    const bqethStorageLibrary = await deployments.deploy("LibBqETH", {
      from: deployer,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
    });

    const libDiamondEtherscan = await deployments.deploy("LibDiamondEtherscan", {
      from: deployer,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
    });

    const dummyImplementation = await deployments.deploy("DummyDiamondImplementation", {
      from: deployer,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
    });
  
    const diamondOptions: DiamondOptions = {
      from: deployer,
      owner: diamondAdmin,
      autoMine: true,
      waitConfirmations: 6,
      log: true,
      libraries: {
        // Library Names must match what the compiler expects
        BigNumbers: bigNumberLibrary.address,
        PietrzakVerifier: pietrzakVerifier.address,
        LibBqETH: bqethStorageLibrary.address,
        MerkleTreeVerifier: merkleTreeVerifier.address,
        LibDiamondEtherscan: libDiamondEtherscan.address
      },
      facets: [
        'IERC20MetaDataStub',
        'BqETH',
        'BqETHPublish',
        'BqETHSolve',
        'BqETHDecrypt',
        'BqETHManagement',
        'DiamondEtherscanFacet',
      ],
      defaultOwnershipFacet: true,
      defaultCutFacet: true,
    };
  
    const BqETHDiamond = await diamond.deploy('BqETHDiamond', diamondOptions);
    console.log("BqETH Diamond deployed at: ", BqETHDiamond.address);

    const setSecp32ExpTx = await deployments.execute('BqETHDiamond',
        {from: deployer, log: true},
        'setSecondsPer32Exp',"118524"
    );
    const setRewardPerDayTx = await deployments.execute('BqETHDiamond',
      {from: deployer, log: true},
      'setRewardPerDay',"1000000001"
    );

    // We have a dummy implementation contract (not facet)
    // and a DiamondEtherscan facet supporting ERC-1967 to 
    // allow Etherscan to expose out facet methods, but
    // the DiamondEtherscanFacet needs to point to the dummy contract 

    const setImplementationTx = await deployments.execute('BqETHDiamond',
      {from: deployer, log: true},
      'setDummyImplementation',dummyImplementation.address
    );

  };
  
// 'all' here is to indicate that's all of the contracts, for tests that wait for 
// fixture 'all' to be deployed
deployDiamondFunc.tags = ['all', 'BqETHDiamond']; 

// Similar
export default deployDiamondFunc;
module.exports = deployDiamondFunc;
