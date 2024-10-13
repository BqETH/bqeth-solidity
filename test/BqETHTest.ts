import { expect } from "chai";
import { ethers, getNamedAccounts, deployments} from 'hardhat';

// describe("Token contract", function () {
//   it("Deployment should assign the total supply of tokens to the owner", async function () {
//     const [owner] = await ethers.getSigners();

//     const hardhatToken = await ethers.deployContract("Token");

//     const ownerBalance = await hardhatToken.balanceOf(owner.address);
//     expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
//   });
// });

// describe('Token', () => {
//   it('testing 1 2 3', async function () {
//     await deployments.fixture(['Token']);
//     const Token = await deployments.get('Token'); // Token is available because the fixture was executed
//     console.log(Token.address);
//     const ERC721BidSale = await deployments.get('ERC721BidSale');
//     console.log({ERC721BidSale});
//   });
// });

// describe('Token', () => {
//   it('testing 1 2 3', async function () {
//     await deployments.fixture(['Token']);
//     const {tokenOwner} = await getNamedAccounts();
//     const TokenContract = await ethers.getContractAt('Token', tokenOwner);
//     await TokenContract.mint(2).then((tx) => tx.wait());
//   });
// });

// const setupTest = deployments.createFixture(
//     async ({deployments, getNamedAccounts, ethers}, options) => {
//       await deployments.fixture(); // ensure you start from a fresh deployments
//       const {tokenOwner} = await getNamedAccounts();
//       const TokenContract = await ethers.getContract('Token', tokenOwner);
//       await TokenContract.mint(10).then((tx) => tx.wait()); //this mint is executed once and then `createFixture` will ensure it is snapshotted
//       return {
//         tokenOwner: {
//           address: tokenOwner,
//           TokenContract,
//         },
//       };
//     }
//   );
//   describe('Token', () => {
//     it('testing 1 2 3', async function () {
//       const {tokenOwner} = await setupTest();
//       await tokenOwner.TokenContract.mint(2);
//     });
//   });
