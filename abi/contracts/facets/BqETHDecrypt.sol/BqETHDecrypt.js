export default [
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "pid",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "creator",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "decryptedMessage",
        "type": "string"
      }
    ],
    "name": "decryptionRewardClaimed",
    "type": "event"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_pid",
        "type": "uint256"
      },
      {
        "internalType": "bytes32",
        "name": "_h1",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "_x2",
        "type": "bytes32"
      }
    ],
    "name": "claimDecryption",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_pid",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_decryptedMessage",
        "type": "string"
      }
    ],
    "name": "claimDecryptionReward",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_pid",
        "type": "uint256"
      },
      {
        "internalType": "bytes32[]",
        "name": "proof",
        "type": "bytes32[]"
      },
      {
        "internalType": "bool[]",
        "name": "proofPaths",
        "type": "bool[]"
      },
      {
        "internalType": "bytes32",
        "name": "leaf",
        "type": "bytes32"
      },
      {
        "internalType": "string",
        "name": "newcid",
        "type": "string"
      }
    ],
    "name": "claimDecryptionRewardIPFS",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
