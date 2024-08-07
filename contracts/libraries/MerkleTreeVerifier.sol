// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

// From https://github.com/liamzebedee/typescript-solidity-merkle-tree
// I had to make it an abstract contract and change the pragma because the 
// original library could be installed but pins the solidity version to 0.5.0 
// and hasn't been modified in 5 years.

/**
 * @notice Merkle Tree Verifier library for Solidity.
 */
library MerkleTreeVerifier {

    /**
     * @dev Verifies a Merkle proof proving the existence of a leaf in a Merkle tree. 
     * Assumes that each pair of leaves and each pair of pre-images are sorted.
     * @param proof Merkle proof containing sibling hashes on the branch from the leaf to the root of the Merkle tree
     * @param root Merkle root
     * @param leaf Leaf of Merkle tree
     */
    function _verify(
        bytes32[] memory proof,
        bool[] memory paths,
        bytes32 root,
        bytes32 leaf
    ) public pure returns (bool) {
        // Check if the computed hash (root) is equal to the provided root
        return _computeRoot(proof, paths, leaf) == root;
    }

    function _computeRoot(
        bytes32[] memory proof,
        bool[] memory paths,
        bytes32 leaf
    ) private pure returns (bytes32) {
        bytes32 node = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 pairNode = proof[i];

            if (paths[i]) {
                // Hash(current element of the proof + current computed hash)
                node = _hashBranch(pairNode, node);
            } else {
                // Hash(current computed hash + current element of the proof)
                node = _hashBranch(node, pairNode);
            }
        }

        return node;
    }

    // function _hashLeaf(bytes32 leaf) private pure returns (bytes32) {
    //     bytes1 LEAF_PREFIX = 0x00;
    //     return keccak256(abi.encodePacked(LEAF_PREFIX, leaf));
    // }

    function _hashBranch(
        bytes32 left,
        bytes32 right
    ) private pure returns (bytes32) {
        bytes1 BRANCH_PREFIX = 0x01;
        return keccak256(abi.encodePacked(BRANCH_PREFIX, left, right));
    }
}
