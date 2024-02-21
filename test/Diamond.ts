import {DiamondOptions} from 'hardhat-deploy/types';
import hre from "hardhat";

// const setupTest = hre.deployments.createFixture(
//   async ({deployments, getNamedAccounts, ethers}, options) => {
//     await deployments.fixture(); // ensure you start from a fresh deployments
//     const {tokenOwner} = await getNamedAccounts();
//     const TokenContract = await ethers.getContract('Token', tokenOwner);
//     await TokenContract.mint(10).then((tx) => tx.wait()); //this mint is executed once and then `createFixture` will ensure it is snapshotted
//     return {
//       tokenOwner: {
//         address: tokenOwner,
//         TokenContract,
//       },
//     };
//   }
// );

describe("BqETH contract", function () {

  beforeEach(async function() {
    console.log("Running deployment once."); // yarn hardhat deploy --reset
  });
  
  it("Deployment should create a diamond", async function () {
    const [owner] = await hre.ethers.getSigners();
    const ownerAddress = await owner.getAddress();
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

    // const bqETHPublish = await hre.ethers.deployContract("BqETHPublish", {
    //   libraries: {
    //     LibBqETH: libBqETHAddress,
    //   }
    // });
    // const bqETHPublishAddress = await bqETHPublish.getAddress();
    // await bqETHPublish.waitForDeployment();
    // console.log(`bqETHPublish deployed to: ${bqETHPublishAddress}`);

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
    const deps = await hre.deployments.all();
    console.log("Deployments: ", Object.keys(deps));

    // await hre.deployments.fixture(["BqETHDecrypt"]);
    // const BqETHDecrypt = await hre.deployments.get('BqETHDecrypt');
    // console.log(BqETHDecrypt.address);
    const BqETHPublish = await hre.deployments.get('BqETHPublish');
    console.log(BqETHPublish);

    // const ownerBalance = await bqeth.balanceOf(owner.address);
    // expect(await bqeth.version()).to.equal(ownerBalance);
  });

  afterEach(async function() {
    console.log("Running deployment once."); // yarn hardhat deploy --reset
  })
});
