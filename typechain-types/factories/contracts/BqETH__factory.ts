/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type { Signer, ContractDeployTransaction, ContractRunner } from "ethers";
import type { NonPayableOverrides } from "../../common";
import type { BqETH, BqETHInterface } from "../../contracts/BqETH";

const _abi = [
  {
    inputs: [],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
    ],
    name: "getActiveChain",
    outputs: [
      {
        components: [
          {
            internalType: "address",
            name: "creator",
            type: "address",
          },
          {
            internalType: "uint128",
            name: "t",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "reward",
            type: "uint128",
          },
          {
            internalType: "uint256",
            name: "sdate",
            type: "uint256",
          },
          {
            internalType: "bytes32",
            name: "h3",
            type: "bytes32",
          },
          {
            internalType: "bytes",
            name: "x",
            type: "bytes",
          },
        ],
        internalType: "struct Puzzle[]",
        name: "chain",
        type: "tuple[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
    ],
    name: "getActivePolicy",
    outputs: [
      {
        internalType: "string",
        name: "ritualId",
        type: "string",
      },
      {
        internalType: "bytes32",
        name: "mkh",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "dkh",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
    ],
    name: "getActivePuzzle",
    outputs: [
      {
        internalType: "uint256",
        name: "pid",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "creator",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "N",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "x",
        type: "bytes",
      },
      {
        internalType: "uint256",
        name: "t",
        type: "uint256",
      },
      {
        internalType: "bytes32",
        name: "h3",
        type: "bytes32",
      },
      {
        internalType: "uint256",
        name: "reward",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "sdate",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_pid",
        type: "uint256",
      },
    ],
    name: "getPuzzle",
    outputs: [
      {
        internalType: "uint256",
        name: "pid",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "creator",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "N",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "x",
        type: "bytes",
      },
      {
        internalType: "uint256",
        name: "t",
        type: "uint256",
      },
      {
        internalType: "bytes32",
        name: "h3",
        type: "bytes32",
      },
      {
        internalType: "uint256",
        name: "reward",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "sdate",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getRewardPerDay",
    outputs: [
      {
        internalType: "uint128",
        name: "gweiPerDay",
        type: "uint128",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getSecondsPer32Exp",
    outputs: [
      {
        internalType: "uint128",
        name: "secondsPer32Exp",
        type: "uint128",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
    ],
    name: "hasNoActivePuzzleForDelivery",
    outputs: [
      {
        internalType: "bytes32",
        name: "hash",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
    ],
    name: "hasNoActivePuzzleForPayload",
    outputs: [
      {
        internalType: "bytes32",
        name: "hash",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "_N",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "_x",
        type: "bytes",
      },
      {
        internalType: "uint256",
        name: "_t",
        type: "uint256",
      },
    ],
    name: "puzzleKey",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint128",
        name: "gweiPerDay",
        type: "uint128",
      },
    ],
    name: "setRewardPerDay",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint128",
        name: "secondsPer32Exp",
        type: "uint128",
      },
    ],
    name: "setSecondsPer32Exp",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "version",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x60806040523480156200001157600080fd5b5060016000819055506200007f60405180606001604052806026815260200162002507602691396040518060400160405280601181526020017f42714554482056657273696f6e20332e300000000000000000000000000000008152506200008560201b620011ee1760201c565b620002a3565b6200012782826040516024016200009e92919062000239565b6040516020818303038152906040527f4b5c4277000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19166020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff83818316178352505050506200012b60201b60201c565b5050565b62000151816200014c6200015460201b6200128a176200017560201b60201c565b60201c565b50565b60006a636f6e736f6c652e6c6f679050600080835160208501845afa505050565b6200018960201b6200139817819050919050565b6200019362000274565b565b600081519050919050565b600082825260208201905092915050565b60005b83811015620001d1578082015181840152602081019050620001b4565b83811115620001e1576000848401525b50505050565b6000601f19601f8301169050919050565b6000620002058262000195565b620002118185620001a0565b935062000223818560208601620001b1565b6200022e81620001e7565b840191505092915050565b60006040820190508181036000830152620002558185620001f8565b905081810360208301526200026b8184620001f8565b90509392505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052605160045260246000fd5b61225480620002b36000396000f3fe6080604052600436106100ab5760003560e01c80637eeb5bdf116100645780637eeb5bdf1461020e57806387cc46201461024b578063acaab83d14610274578063aed284d9146102b1578063efe994cd146102dc578063f53c064d14610305576100b2565b80630cf466b2146100b45780631652896a146100f35780631f2d8b461461013057806332ced772146101745780633fed202d1461019f57806354fd4d50146101e3576100b2565b366100b257005b005b3480156100c057600080fd5b506100db60048036038101906100d69190611414565b610342565b6040516100ea939291906114f3565b60405180910390f35b3480156100ff57600080fd5b5061011a6004803603810190610115919061169c565b610680565b6040516101279190611736565b60405180910390f35b34801561013c57600080fd5b5061015760048036038101906101529190611751565b610707565b60405161016b9897969594939291906117e2565b60405180910390f35b34801561018057600080fd5b506101896107ab565b6040516101969190611899565b60405180910390f35b3480156101ab57600080fd5b506101c660048036038101906101c19190611414565b61081f565b6040516101da9897969594939291906117e2565b60405180910390f35b3480156101ef57600080fd5b506101f86108c3565b60405161020591906118b4565b60405180910390f35b34801561021a57600080fd5b5061023560048036038101906102309190611414565b610900565b6040516102429190611aa7565b60405180910390f35b34801561025757600080fd5b50610272600480360381019061026d9190611af5565b610986565b005b34801561028057600080fd5b5061029b60048036038101906102969190611414565b6109f8565b6040516102a89190611b22565b60405180910390f35b3480156102bd57600080fd5b506102c6610d80565b6040516102d39190611899565b60405180910390f35b3480156102e857600080fd5b5061030360048036038101906102fe9190611af5565b610df4565b005b34801561031157600080fd5b5061032c60048036038101906103279190611414565b610e66565b6040516103399190611b22565b60405180910390f35b6060600080600073__$661a58beb0e36577313759df90938914fe$__63e1ba13416040518163ffffffff1660e01b8152600401602060405180830381865af4158015610392573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906103b69190611b73565b905060008160050160008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020604051806101400160405290816000820160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020016001820154815260200160028201548152602001600382015481526020016004820154815260200160058201805461049590611bcf565b80601f01602080910402602001604051908101604052809291908181526020018280546104c190611bcf565b801561050e5780601f106104e35761010080835404028352916020019161050e565b820191906000526020600020905b8154815290600101906020018083116104f157829003601f168201915b5050505050815260200160068201805461052790611bcf565b80601f016020809104026020016040519081016040528092919081815260200182805461055390611bcf565b80156105a05780601f10610575576101008083540402835291602001916105a0565b820191906000526020600020905b81548152906001019060200180831161058357829003601f168201915b505050505081526020016007820180546105b990611bcf565b80601f01602080910402602001604051908101604052809291908181526020018280546105e590611bcf565b80156106325780601f1061060757610100808354040283529160200191610632565b820191906000526020600020905b81548152906001019060200180831161061557829003601f168201915b50505050508152602001600882015481526020016009820160009054906101000a900460ff16151515158152505090508060e001518160400151826060015194509450945050509193909250565b600073__$661a58beb0e36577313759df90938914fe$__63e7cc69c08585856040518463ffffffff1660e01b81526004016106bd93929190611c5a565b602060405180830381865af41580156106da573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906106fe9190611cb4565b90509392505050565b60008060608060008060008073__$661a58beb0e36577313759df90938914fe$__63658696ff8a6040518263ffffffff1660e01b815260040161074a9190611ce1565b600060405180830381865af4158015610767573d6000803e3d6000fd5b505050506040513d6000823e3d601f19601f820116820180604052508101906107909190611dad565b97509750975097509750975097509750919395975091939597565b600073__$661a58beb0e36577313759df90938914fe$__63f8f803056040518163ffffffff1660e01b8152600401602060405180830381865af41580156107f6573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061081a9190611eb0565b905090565b60008060608060008060008073__$661a58beb0e36577313759df90938914fe$__637880ff5d8a6040518263ffffffff1660e01b81526004016108629190611eec565b600060405180830381865af415801561087f573d6000803e3d6000fd5b505050506040513d6000823e3d601f19601f820116820180604052508101906108a89190611dad565b97509750975097509750975097509750919395975091939597565b60606040518060400160405280601181526020017f42714554482056657273696f6e20332e30000000000000000000000000000000815250905090565b606073__$661a58beb0e36577313759df90938914fe$__63e06bf7c7836040518263ffffffff1660e01b81526004016109399190611eec565b600060405180830381865af4158015610956573d6000803e3d6000fd5b505050506040513d6000823e3d601f19601f8201168201806040525081019061097f91906120b3565b9050919050565b61098e6112ab565b73__$661a58beb0e36577313759df90938914fe$__63fd594ce0826040518263ffffffff1660e01b81526004016109c5919061210b565b60006040518083038186803b1580156109dd57600080fd5b505af41580156109f1573d6000803e3d6000fd5b5050505050565b60008073__$661a58beb0e36577313759df90938914fe$__63e1ba13416040518163ffffffff1660e01b8152600401602060405180830381865af4158015610a44573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610a689190611b73565b905060008160060160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054905060008260050160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020604051806101400160405290816000820160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200160018201548152602001600282015481526020016003820154815260200160048201548152602001600582018054610b8d90611bcf565b80601f0160208091040260200160405190810160405280929190818152602001828054610bb990611bcf565b8015610c065780601f10610bdb57610100808354040283529160200191610c06565b820191906000526020600020905b815481529060010190602001808311610be957829003601f168201915b50505050508152602001600682018054610c1f90611bcf565b80601f0160208091040260200160405190810160405280929190818152602001828054610c4b90611bcf565b8015610c985780601f10610c6d57610100808354040283529160200191610c98565b820191906000526020600020905b815481529060010190602001808311610c7b57829003601f168201915b50505050508152602001600782018054610cb190611bcf565b80601f0160208091040260200160405190810160405280929190818152602001828054610cdd90611bcf565b8015610d2a5780601f10610cff57610100808354040283529160200191610d2a565b820191906000526020600020905b815481529060010190602001808311610d0d57829003601f168201915b50505050508152602001600882015481526020016009820160009054906101000a900460ff161515151581525050905060008214610d70576000801b9350505050610d7b565b806040015193505050505b919050565b600073__$661a58beb0e36577313759df90938914fe$__6321c2c1e86040518163ffffffff1660e01b8152600401602060405180830381865af4158015610dcb573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610def9190611eb0565b905090565b610dfc6112ab565b73__$661a58beb0e36577313759df90938914fe$__63595fcef1826040518263ffffffff1660e01b8152600401610e33919061210b565b60006040518083038186803b158015610e4b57600080fd5b505af4158015610e5f573d6000803e3d6000fd5b5050505050565b60008073__$661a58beb0e36577313759df90938914fe$__63e1ba13416040518163ffffffff1660e01b8152600401602060405180830381865af4158015610eb2573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610ed69190611b73565b905060008160060160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054905060008260050160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020604051806101400160405290816000820160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200160018201548152602001600282015481526020016003820154815260200160048201548152602001600582018054610ffb90611bcf565b80601f016020809104026020016040519081016040528092919081815260200182805461102790611bcf565b80156110745780601f1061104957610100808354040283529160200191611074565b820191906000526020600020905b81548152906001019060200180831161105757829003601f168201915b5050505050815260200160068201805461108d90611bcf565b80601f01602080910402602001604051908101604052809291908181526020018280546110b990611bcf565b80156111065780601f106110db57610100808354040283529160200191611106565b820191906000526020600020905b8154815290600101906020018083116110e957829003601f168201915b5050505050815260200160078201805461111f90611bcf565b80601f016020809104026020016040519081016040528092919081815260200182805461114b90611bcf565b80156111985780601f1061116d57610100808354040283529160200191611198565b820191906000526020600020905b81548152906001019060200180831161117b57829003601f168201915b50505050508152602001600882015481526020016009820160009054906101000a900460ff1615151515815250509050600082146111de576000801b93505050506111e9565b806060015193505050505b919050565b6112868282604051602401611204929190612126565b6040516020818303038152906040527f4b5c4277000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19166020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff8381831617835250505050611346565b5050565b60006a636f6e736f6c652e6c6f679050600080835160208501845afa505050565b6112b3611360565b60040160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614611344576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161133b906121cf565b60405180910390fd5b565b61135d8161135561128a61138d565b63ffffffff16565b50565b6000807fc8fcad8db84d3cc18b4c41d551ea0ee66dd599cde068d998e57d5e09332c131c90508091505090565b611398819050919050565b6113a06121ef565b565b6000604051905090565b600080fd5b600080fd5b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b60006113e1826113b6565b9050919050565b6113f1816113d6565b81146113fc57600080fd5b50565b60008135905061140e816113e8565b92915050565b60006020828403121561142a576114296113ac565b5b6000611438848285016113ff565b91505092915050565b600081519050919050565b600082825260208201905092915050565b60005b8381101561147b578082015181840152602081019050611460565b8381111561148a576000848401525b50505050565b6000601f19601f8301169050919050565b60006114ac82611441565b6114b6818561144c565b93506114c681856020860161145d565b6114cf81611490565b840191505092915050565b6000819050919050565b6114ed816114da565b82525050565b6000606082019050818103600083015261150d81866114a1565b905061151c60208301856114e4565b61152960408301846114e4565b949350505050565b600080fd5b600080fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b61157382611490565b810181811067ffffffffffffffff821117156115925761159161153b565b5b80604052505050565b60006115a56113a2565b90506115b1828261156a565b919050565b600067ffffffffffffffff8211156115d1576115d061153b565b5b6115da82611490565b9050602081019050919050565b82818337600083830152505050565b6000611609611604846115b6565b61159b565b90508281526020810184848401111561162557611624611536565b5b6116308482856115e7565b509392505050565b600082601f83011261164d5761164c611531565b5b813561165d8482602086016115f6565b91505092915050565b6000819050919050565b61167981611666565b811461168457600080fd5b50565b60008135905061169681611670565b92915050565b6000806000606084860312156116b5576116b46113ac565b5b600084013567ffffffffffffffff8111156116d3576116d26113b1565b5b6116df86828701611638565b935050602084013567ffffffffffffffff811115611700576116ff6113b1565b5b61170c86828701611638565b925050604061171d86828701611687565b9150509250925092565b61173081611666565b82525050565b600060208201905061174b6000830184611727565b92915050565b600060208284031215611767576117666113ac565b5b600061177584828501611687565b91505092915050565b611787816113d6565b82525050565b600081519050919050565b600082825260208201905092915050565b60006117b48261178d565b6117be8185611798565b93506117ce81856020860161145d565b6117d781611490565b840191505092915050565b6000610100820190506117f8600083018b611727565b611805602083018a61177e565b818103604083015261181781896117a9565b9050818103606083015261182b81886117a9565b905061183a6080830187611727565b61184760a08301866114e4565b61185460c0830185611727565b61186160e0830184611727565b9998505050505050505050565b60006fffffffffffffffffffffffffffffffff82169050919050565b6118938161186e565b82525050565b60006020820190506118ae600083018461188a565b92915050565b600060208201905081810360008301526118ce81846114a1565b905092915050565b600081519050919050565b600082825260208201905092915050565b6000819050602082019050919050565b61190b816113d6565b82525050565b61191a8161186e565b82525050565b61192981611666565b82525050565b611938816114da565b82525050565b600082825260208201905092915050565b600061195a8261178d565b611964818561193e565b935061197481856020860161145d565b61197d81611490565b840191505092915050565b600060c0830160008301516119a06000860182611902565b5060208301516119b36020860182611911565b5060408301516119c66040860182611911565b5060608301516119d96060860182611920565b5060808301516119ec608086018261192f565b5060a083015184820360a0860152611a04828261194f565b9150508091505092915050565b6000611a1d8383611988565b905092915050565b6000602082019050919050565b6000611a3d826118d6565b611a4781856118e1565b935083602082028501611a59856118f2565b8060005b85811015611a955784840389528151611a768582611a11565b9450611a8183611a25565b925060208a01995050600181019050611a5d565b50829750879550505050505092915050565b60006020820190508181036000830152611ac18184611a32565b905092915050565b611ad28161186e565b8114611add57600080fd5b50565b600081359050611aef81611ac9565b92915050565b600060208284031215611b0b57611b0a6113ac565b5b6000611b1984828501611ae0565b91505092915050565b6000602082019050611b3760008301846114e4565b92915050565b6000819050919050565b611b5081611b3d565b8114611b5b57600080fd5b50565b600081519050611b6d81611b47565b92915050565b600060208284031215611b8957611b886113ac565b5b6000611b9784828501611b5e565b91505092915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b60006002820490506001821680611be757607f821691505b60208210811415611bfb57611bfa611ba0565b5b50919050565b600082825260208201905092915050565b6000611c1d8261178d565b611c278185611c01565b9350611c3781856020860161145d565b611c4081611490565b840191505092915050565b611c5481611666565b82525050565b60006060820190508181036000830152611c748186611c12565b90508181036020830152611c888185611c12565b9050611c976040830184611c4b565b949350505050565b600081519050611cae81611670565b92915050565b600060208284031215611cca57611cc96113ac565b5b6000611cd884828501611c9f565b91505092915050565b6000602082019050611cf66000830184611c4b565b92915050565b600081519050611d0b816113e8565b92915050565b6000611d24611d1f846115b6565b61159b565b905082815260208101848484011115611d4057611d3f611536565b5b611d4b84828561145d565b509392505050565b600082601f830112611d6857611d67611531565b5b8151611d78848260208601611d11565b91505092915050565b611d8a816114da565b8114611d9557600080fd5b50565b600081519050611da781611d81565b92915050565b600080600080600080600080610100898b031215611dce57611dcd6113ac565b5b6000611ddc8b828c01611c9f565b9850506020611ded8b828c01611cfc565b975050604089015167ffffffffffffffff811115611e0e57611e0d6113b1565b5b611e1a8b828c01611d53565b965050606089015167ffffffffffffffff811115611e3b57611e3a6113b1565b5b611e478b828c01611d53565b9550506080611e588b828c01611c9f565b94505060a0611e698b828c01611d98565b93505060c0611e7a8b828c01611c9f565b92505060e0611e8b8b828c01611c9f565b9150509295985092959890939650565b600081519050611eaa81611ac9565b92915050565b600060208284031215611ec657611ec56113ac565b5b6000611ed484828501611e9b565b91505092915050565b611ee6816113d6565b82525050565b6000602082019050611f016000830184611edd565b92915050565b600067ffffffffffffffff821115611f2257611f2161153b565b5b602082029050602081019050919050565b600080fd5b600080fd5b600080fd5b600060c08284031215611f5857611f57611f38565b5b611f6260c061159b565b90506000611f7284828501611cfc565b6000830152506020611f8684828501611e9b565b6020830152506040611f9a84828501611e9b565b6040830152506060611fae84828501611c9f565b6060830152506080611fc284828501611d98565b60808301525060a082015167ffffffffffffffff811115611fe657611fe5611f3d565b5b611ff284828501611d53565b60a08301525092915050565b600061201161200c84611f07565b61159b565b9050808382526020820190506020840283018581111561203457612033611f33565b5b835b8181101561207b57805167ffffffffffffffff81111561205957612058611531565b5b8086016120668982611f42565b85526020850194505050602081019050612036565b5050509392505050565b600082601f83011261209a57612099611531565b5b81516120aa848260208601611ffe565b91505092915050565b6000602082840312156120c9576120c86113ac565b5b600082015167ffffffffffffffff8111156120e7576120e66113b1565b5b6120f384828501612085565b91505092915050565b6121058161186e565b82525050565b600060208201905061212060008301846120fc565b92915050565b6000604082019050818103600083015261214081856114a1565b9050818103602083015261215481846114a1565b90509392505050565b7f4c69624469616d6f6e643a204d75737420626520636f6e7472616374206f776e60008201527f6572000000000000000000000000000000000000000000000000000000000000602082015250565b60006121b960228361144c565b91506121c48261215d565b604082019050919050565b600060208201905081810360008301526121e8816121ac565b9050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052605160045260246000fdfea26469706673582212203f4cbda60eece021181c5dcea8f89c3b99cd961c12575799a06a44e435c688ed64736f6c634300080a00334465706c6f79696e6720427145544820436f6e747261637420776974682076657273696f6e3a";

type BqETHConstructorParams =
  | [linkLibraryAddresses: BqETHLibraryAddresses, signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: BqETHConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => {
  return (
    typeof xs[0] === "string" ||
    (Array.isArray as (arg: any) => arg is readonly any[])(xs[0]) ||
    "_isInterface" in xs[0]
  );
};

export class BqETH__factory extends ContractFactory {
  constructor(...args: BqETHConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      const [linkLibraryAddresses, signer] = args;
      super(_abi, BqETH__factory.linkBytecode(linkLibraryAddresses), signer);
    }
  }

  static linkBytecode(linkLibraryAddresses: BqETHLibraryAddresses): string {
    let linkedBytecode = _bytecode;

    linkedBytecode = linkedBytecode.replace(
      new RegExp("__\\$661a58beb0e36577313759df90938914fe\\$__", "g"),
      linkLibraryAddresses["contracts/libraries/LibBqETH.sol:LibBqETH"]
        .replace(/^0x/, "")
        .toLowerCase()
    );

    return linkedBytecode;
  }

  override getDeployTransaction(
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(overrides || {});
  }
  override deploy(overrides?: NonPayableOverrides & { from?: string }) {
    return super.deploy(overrides || {}) as Promise<
      BqETH & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): BqETH__factory {
    return super.connect(runner) as BqETH__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): BqETHInterface {
    return new Interface(_abi) as BqETHInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): BqETH {
    return new Contract(address, _abi, runner) as unknown as BqETH;
  }
}

export interface BqETHLibraryAddresses {
  ["contracts/libraries/LibBqETH.sol:LibBqETH"]: string;
}
