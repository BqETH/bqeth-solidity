export default [
  {
    "inputs": [
      {
        "internalType": "bytes32[]",
        "name": "proof",
        "type": "bytes32[]"
      },
      {
        "internalType": "bool[]",
        "name": "paths",
        "type": "bool[]"
      },
      {
        "internalType": "bytes32",
        "name": "leaf",
        "type": "bytes32"
      }
    ],
    "name": "_computeRoot",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "left",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "right",
        "type": "bytes32"
      }
    ],
    "name": "_hashBranch",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "leaf",
        "type": "bytes32"
      }
    ],
    "name": "_hashLeaf",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32[]",
        "name": "proof",
        "type": "bytes32[]"
      },
      {
        "internalType": "bool[]",
        "name": "paths",
        "type": "bool[]"
      },
      {
        "internalType": "bytes32",
        "name": "root",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "leaf",
        "type": "bytes32"
      }
    ],
    "name": "_verify",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  }
];
