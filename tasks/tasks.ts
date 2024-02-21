import { getNamedAccounts } from 'hardhat';
import { task } from 'hardhat/config';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers'; // Needs ethers@6.6.2 for getBalance to work right
import { HardhatRuntimeEnvironment } from 'hardhat/types';

// This is a sample Hardhat task. To learn how to create your own go to https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre: HardhatRuntimeEnvironment) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    const addr = account.address;
    const bal = await account.provider.getBalance(addr);
    console.log(account.address + ' : ' + hre.ethers.formatEther(bal)+ " ETH");
    console.log();
  }
});



