export default [
  {
    "inputs": [],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "stateMutability": "payable",
    "type": "fallback"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_user",
        "type": "address"
      }
    ],
    "name": "getActiveChain",
    "outputs": [
      {
        "components": [
          {
            "internalType": "address",
            "name": "creator",
            "type": "address"
          },
          {
            "internalType": "uint128",
            "name": "t",
            "type": "uint128"
          },
          {
            "internalType": "uint128",
            "name": "reward",
            "type": "uint128"
          },
          {
            "internalType": "uint256",
            "name": "sdate",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "h3",
            "type": "bytes32"
          },
          {
            "internalType": "bytes",
            "name": "x",
            "type": "bytes"
          }
        ],
        "internalType": "struct Puzzle[]",
        "name": "chain",
        "type": "tuple[]"
      }
    ],
    "stateMutability": "view",
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
    "name": "getActivePolicy",
    "outputs": [
      {
        "internalType": "string",
        "name": "ritualId",
        "type": "string"
      },
      {
        "internalType": "bytes32",
        "name": "mkh",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
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
    "name": "getActivePuzzle",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "pid",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "creator",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "N",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "x",
        "type": "bytes"
      },
      {
        "internalType": "uint256",
        "name": "t",
        "type": "uint256"
      },
      {
        "internalType": "bytes32",
        "name": "h3",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "reward",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "sdate",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_pid",
        "type": "uint256"
      }
    ],
    "name": "getPuzzle",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "pid",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "creator",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "N",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "x",
        "type": "bytes"
      },
      {
        "internalType": "uint256",
        "name": "t",
        "type": "uint256"
      },
      {
        "internalType": "bytes32",
        "name": "h3",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "reward",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "sdate",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getRewardPerDay",
    "outputs": [
      {
        "internalType": "uint128",
        "name": "gweiPerDay",
        "type": "uint128"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getSecondsPer32Exp",
    "outputs": [
      {
        "internalType": "uint128",
        "name": "secondsPer32Exp",
        "type": "uint128"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "user",
        "type": "address"
      }
    ],
    "name": "hasNoActivePuzzle",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "hash",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "_N",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "_x",
        "type": "bytes"
      },
      {
        "internalType": "uint256",
        "name": "_t",
        "type": "uint256"
      }
    ],
    "name": "puzzleKey",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint128",
        "name": "gweiPerDay",
        "type": "uint128"
      }
    ],
    "name": "setRewardPerDay",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint128",
        "name": "secondsPer32Exp",
        "type": "uint128"
      }
    ],
    "name": "setSecondsPer32Exp",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "sweepFunds",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "version",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "stateMutability": "payable",
    "type": "receive"
  }
];
