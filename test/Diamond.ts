import {DiamondOptions} from 'hardhat-deploy/types';
import {HardhatRuntimeEnvironment} from 'hardhat/types';
import hre from "hardhat";
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import { expect } from 'chai';

const setupTest = hre.deployments.createFixture(
  async ({deployments, getNamedAccounts, ethers}, options) => {
    await deployments.fixture(); // ensure you start from a fresh deployments

    const {deployer, diamondAdmin} = await hre.getNamedAccounts();

    // The tests assume that things get mined right away
    // TODO: This means the tests are wildly fragile and probably need to be rewritten
    await hre.network.provider.send('evm_setAutomine', [false]);
    await hre.network.provider.send('evm_setIntervalMining', [100]);

    const bigNumberLibrary = await hre.ethers.deployContract("BigNumbers");
    const bigNumberLibraryAddress = await bigNumberLibrary.getAddress();
    const merkleTreeVerifier = await hre.ethers.deployContract("MerkleTreeVerifier");
    const merkleTreeVerifierAddress = await merkleTreeVerifier.getAddress();
    const pietrzakVerifier = await hre.ethers.deployContract("PietrzakVerifier");
    const pietrzakVerifierAddress = await pietrzakVerifier.getAddress();
    const libBqETH = await hre.ethers.deployContract("LibBqETH");
    const libBqETHAddress = await libBqETH.getAddress();
    
    await bigNumberLibrary.waitForDeployment();
    console.log(`BigNumbers deployed to: ${bigNumberLibraryAddress}`);
    await merkleTreeVerifier.waitForDeployment();
    console.log(`MerkleTreeVerifier deployed to: ${merkleTreeVerifierAddress}`);
    await pietrzakVerifier.waitForDeployment();
    console.log(`PietrzakVerifier deployed to: ${pietrzakVerifierAddress}`);
    await libBqETH.waitForDeployment();
    console.log(`LibBqETH deployed to: ${libBqETHAddress}`);

    const diamondOptions: DiamondOptions = {
      from: deployer,
      owner: diamondAdmin,
      autoMine: true,
      log: true,
      libraries: {
        // Library Names must match what the compiler expects
        BigNumbers: bigNumberLibraryAddress,
        PietrzakVerifier: pietrzakVerifierAddress,
        LibBqETH: libBqETHAddress,
        MerkleTreeVerifier: merkleTreeVerifierAddress
      },
      facets: [
        'IERC20MetaDataStub',
        'BqETH',
        'BqETHPublish',
        'BqETHSolve',
        'BqETHDecrypt'
      ],
      defaultOwnershipFacet: true,
      defaultCutFacet: true,
      waitConfirmations: 1
    };
  
    const dr = await hre.deployments.diamond.deploy('BqETHTestDiamond', diamondOptions);

    // Now we're going to call the BqETH facet via the diamond Proxy to set the secPer32Exp value
    const {owner} = await getNamedAccounts();
    const BqETHDiamond = await ethers.getContract('BqETHDiamond_DiamondProxy', owner);
    const diamondProxyAddress = await BqETHDiamond.getAddress();
    const BqETHFacet = await ethers.getContractAt('BqETH', diamondProxyAddress);
    // This call is executed once and then `createFixture` will ensure it is snapshotted
    await BqETHFacet.setSecondsPer32Exp(145300).then((tx) => tx.wait()); 

    return {
      diamondAdmin: {
        address: owner,
        BqETHDiamond,
      },
    };
  }
);

describe("BqETH contract", function () {

  // beforeEach(async function() {
  //   console.log("Setup before each test, e.g. clearing data."); // yarn hardhat deploy --reset
  // });
  
  it("Deployment should create a diamond", async function () {
    const {diamondAdmin} = await setupTest();

    const deps = await hre.deployments.all();
    console.log("Deployments: ", Object.keys(deps));

    const BqETHFacet = await hre.ethers.getContractAt('BqETH', diamondAdmin.address);
    // This call is executed once and then `createFixture` will ensure it is snapshotted
    const secPer32Exp = await BqETHFacet.getSecondsPer32Exp(); 

    // const BqETHPublish = await hre.deployments.get('BqETHPublish');
    // console.log(BqETHPublish);

    expect(await BqETHFacet.version()).to.equal(3.0);
    expect(secPer32Exp).to.equal(145300);
  });

  // afterEach(async function() {
  //   console.log("Setup after test, e.g. clearing data."); 
  //   await hre.run("deploy", { reset: true }); // yarn hardhat deploy --reset
  // })
});
