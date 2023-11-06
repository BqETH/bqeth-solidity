export default [
  {
    "inputs": [
      {
        "components": [
          {
            "internalType": "bytes",
            "name": "val",
            "type": "bytes"
          },
          {
            "internalType": "bool",
            "name": "neg",
            "type": "bool"
          },
          {
            "internalType": "uint256",
            "name": "bitlen",
            "type": "uint256"
          }
        ],
        "internalType": "struct BigNumber",
        "name": "n",
        "type": "tuple"
      }
    ],
    "name": "toBytes",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "r",
        "type": "bytes"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  }
];
