/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { ethers } from "ethers";
import {
  DeployContractOptions,
  FactoryOptions,
  HardhatEthersHelpers as HardhatEthersHelpersBase,
} from "@nomicfoundation/hardhat-ethers/types";

import * as Contracts from ".";

declare module "hardhat/types/runtime" {
  interface HardhatEthersHelpers extends HardhatEthersHelpersBase {
    getContractFactory(
      name: "BqETH",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.BqETH__factory>;
    getContractFactory(
      name: "BqETHDecrypt",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.BqETHDecrypt__factory>;
    getContractFactory(
      name: "BqETHPublish",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.BqETHPublish__factory>;
    getContractFactory(
      name: "BqETHSolve",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.BqETHSolve__factory>;
    getContractFactory(
      name: "IERC20MetaDataStub",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC20MetaDataStub__factory>;
    getContractFactory(
      name: "LibBqETH",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.LibBqETH__factory>;
    getContractFactory(
      name: "MerkleTreeVerifier",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.MerkleTreeVerifier__factory>;
    getContractFactory(
      name: "IDiamondCut",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IDiamondCut__factory>;
    getContractFactory(
      name: "LibDiamond",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.LibDiamond__factory>;

    getContractAt(
      name: "BqETH",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.BqETH>;
    getContractAt(
      name: "BqETHDecrypt",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.BqETHDecrypt>;
    getContractAt(
      name: "BqETHPublish",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.BqETHPublish>;
    getContractAt(
      name: "BqETHSolve",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.BqETHSolve>;
    getContractAt(
      name: "IERC20MetaDataStub",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC20MetaDataStub>;
    getContractAt(
      name: "LibBqETH",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.LibBqETH>;
    getContractAt(
      name: "MerkleTreeVerifier",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.MerkleTreeVerifier>;
    getContractAt(
      name: "IDiamondCut",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IDiamondCut>;
    getContractAt(
      name: "LibDiamond",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.LibDiamond>;

    deployContract(
      name: "BqETH",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETH>;
    deployContract(
      name: "BqETHDecrypt",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETHDecrypt>;
    deployContract(
      name: "BqETHPublish",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETHPublish>;
    deployContract(
      name: "BqETHSolve",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETHSolve>;
    deployContract(
      name: "IERC20MetaDataStub",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20MetaDataStub>;
    deployContract(
      name: "LibBqETH",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.LibBqETH>;
    deployContract(
      name: "MerkleTreeVerifier",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.MerkleTreeVerifier>;
    deployContract(
      name: "IDiamondCut",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IDiamondCut>;
    deployContract(
      name: "LibDiamond",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.LibDiamond>;

    deployContract(
      name: "BqETH",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETH>;
    deployContract(
      name: "BqETHDecrypt",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETHDecrypt>;
    deployContract(
      name: "BqETHPublish",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETHPublish>;
    deployContract(
      name: "BqETHSolve",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.BqETHSolve>;
    deployContract(
      name: "IERC20MetaDataStub",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20MetaDataStub>;
    deployContract(
      name: "LibBqETH",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.LibBqETH>;
    deployContract(
      name: "MerkleTreeVerifier",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.MerkleTreeVerifier>;
    deployContract(
      name: "IDiamondCut",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IDiamondCut>;
    deployContract(
      name: "LibDiamond",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.LibDiamond>;

    // default types
    getContractFactory(
      name: string,
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<ethers.ContractFactory>;
    getContractFactory(
      abi: any[],
      bytecode: ethers.BytesLike,
      signer?: ethers.Signer
    ): Promise<ethers.ContractFactory>;
    getContractAt(
      nameOrAbi: string | any[],
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<ethers.Contract>;
    deployContract(
      name: string,
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<ethers.Contract>;
    deployContract(
      name: string,
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<ethers.Contract>;
  }
}
