import {DiamondOptions} from 'hardhat-deploy/types';
import {HardhatRuntimeEnvironment} from 'hardhat/types';
import hre from "hardhat";
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import { expect } from 'chai';
import {BqETH} from '../types/contracts/index.ts';
import {MerkleTreeVerifier,PietrzakVerifier,LibBqETH} from '../types/contracts/libraries/index.ts';
import {BqETHDecrypt, BqETHPublish, BqETHSolve, IERC20MetaDataStub} from '../types/contracts/facets/index.ts';

const REWARDPERDAY = 700;
const SECPER32EXP = 145300;

let run = false;
var diamondProxyAddress: string;

beforeEach(async function() {
  if ( run === true ) return;
  // await hre.network.provider.send('evm_setAutomine', [false]);
  // await hre.network.provider.send('evm_setIntervalMining', [100]);
  await hre.deployments.fixture(["BqETHDiamond"]);      
  // console.log(`Diamond Deployment finished`);
  const {owner} = await hre.getNamedAccounts();
  const BqETHDiamond = await hre.ethers.getContract('BqETHDiamond_DiamondProxy', owner);
  diamondProxyAddress = await BqETHDiamond.getAddress();
  // console.log(`Diamond Deployed at: `, diamondProxyAddress);
  run = true;
});

// Testing Diamond Deployment , access to Diamond Storage
describe("BqETH contract", function () {
  
  beforeEach(async () => {
      console.log("Resetting variables.");
      const BqETHFacet = (await hre.ethers.getContractAt('BqETH', diamondProxyAddress)) as unknown as BqETH;
      // console.log(`Found BqETH Facet `, await BqETHFacet.getAddress());
      await BqETHFacet.setRewardPerDay(REWARDPERDAY).then((tx) => tx.wait()); 
      // console.log(`Wrote BqETH Facet setRewardPerDay`);
      await BqETHFacet.setSecondsPer32Exp(145300).then((tx) => tx.wait()); 
      // console.log(`Wrote BqETH Facet setSecondsPer32Exp`);
  });

  it("Deployment should have the 3 important facets", async function () {
    // 'BigNumbers' is the only one missing because the typechain isn't generated
    const BqETHDecrypt = (await hre.ethers.getContractAt('BqETHDecrypt', diamondProxyAddress)) as unknown as BqETHDecrypt;
    expect(BqETHDecrypt).not.undefined;
    const BqETHPublish = (await hre.ethers.getContractAt('BqETHPublish', diamondProxyAddress)) as unknown as BqETHPublish;
    expect(BqETHPublish).not.undefined;
    const BqETHSolve = (await hre.ethers.getContractAt('BqETHSolve', diamondProxyAddress)) as unknown as BqETHSolve;
    expect(BqETHSolve).not.undefined;
  });

  it("Deployment should have the right version", async function () {
    const BqETHFacet = (await hre.ethers.getContractAt('BqETH', diamondProxyAddress)) as unknown as BqETH;
    expect(await BqETHFacet.version()).to.equal("BqETH Version 3.0");
  });

  it("Deployment should have the preset Reward", async function () {
    const BqETH = await hre.ethers.getContractAt('BqETH', diamondProxyAddress) as unknown as BqETH;
    const rewardPerDay = await BqETH.getRewardPerDay(); 
    expect(rewardPerDay).to.equal(REWARDPERDAY);
  });
  
  it("Deployment should have the preset SecPer32Exp", async function () {
    const BqETH = await hre.ethers.getContractAt('BqETH', diamondProxyAddress) as unknown as BqETH;
    const secPer32Exp = await BqETH.getSecondsPer32Exp(); 
    expect(secPer32Exp).to.equal(SECPER32EXP);
  });

});
