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
        "internalType": "string",
        "name": "ritualId",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "encryptedPayload",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "encryptedDelivery",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "solution",
        "type": "bytes"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "sdate",
        "type": "uint256"
      }
    ],
    "name": "PuzzleInactive",
    "type": "event"
  },
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
        "internalType": "bytes",
        "name": "y",
        "type": "bytes"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "sdate",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "reward",
        "type": "uint256"
      }
    ],
    "name": "RewardClaimed",
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
    "name": "claimPuzzle",
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
        "internalType": "bytes",
        "name": "_y",
        "type": "bytes"
      },
      {
        "internalType": "bytes[]",
        "name": "_proof",
        "type": "bytes[]"
      }
    ],
    "name": "claimReward",
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
        "name": "x",
        "type": "uint256"
      }
    ],
    "name": "log2",
    "outputs": [
      {
        "internalType": "uint8",
        "name": "",
        "type": "uint8"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_user",
        "type": "address"
      }
    ],
    "name": "setMeDead",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
