import {DiamondOptions} from 'hardhat-deploy/types';
import {HardhatRuntimeEnvironment} from 'hardhat/types';
import hre from "hardhat";
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import { expect } from 'chai';
import {BqETH} from '../types/contracts/index.ts';

const REWARDPERDAY = 700;
const SECPER32EXP = 145300;

describe("BqETH contract", function () {
  var diamondProxyAddress: string;

  beforeEach(async () => {
      await hre.deployments.fixture(["BqETHDiamond"]);
      // console.log(`Diamond Deployment finished`);
      const {owner} = await hre.getNamedAccounts();
      const BqETHDiamond = await hre.ethers.getContract('BqETHDiamond_DiamondProxy', owner);
      diamondProxyAddress = await BqETHDiamond.getAddress();
      // console.log(`Diamond Deployed at: `, diamondProxyAddress);
      const BqETHFacet = (await hre.ethers.getContractAt('BqETH', diamondProxyAddress)) as BqETH;
      // console.log(`Found BqETH Facet `, await BqETHFacet.getAddress());
      await BqETHFacet.setRewardPerDay(REWARDPERDAY).then((tx) => tx.wait()); 
      // console.log(`Wrote BqETH Facet setRewardPerDay`);
      await BqETHFacet.setSecondsPer32Exp(145300).then((tx) => tx.wait()); 
      // console.log(`Wrote BqETH Facet setSecondsPer32Exp`);
  });

  it("Deployment should have the right version", async function () {
    const BqETHFacet = (await hre.ethers.getContractAt('BqETH', diamondProxyAddress)) as BqETH;
    expect(await BqETHFacet.version()).to.equal("BqETH Version 3.0");
  });

  it("Deployment should have the preset Reward", async function () {
    const BqETH = await hre.ethers.getContractAt('BqETH', diamondProxyAddress) as BqETH;
    const rewardPerDay = await BqETH.getRewardPerDay(); 
    expect(rewardPerDay).to.equal(REWARDPERDAY);
  });
  
  it("Deployment should have the preset SecPer32Exp", async function () {
    const BqETH = await hre.ethers.getContractAt('BqETH', diamondProxyAddress) as BqETH;
    const secPer32Exp = await BqETH.getSecondsPer32Exp(); 
    expect(secPer32Exp).to.equal(SECPER32EXP);
  });

});
