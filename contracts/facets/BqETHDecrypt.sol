pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "../libraries/LibBqETH.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/MerkleTreeVerifier.sol";
import "../libraries/BigNumbers.sol";

// import "../BqETH.sol";

contract BqETHDecrypt is ReentrancyGuard {
    bytes32 immutable salt = "BqETH";

    modifier onlyValidFarmer() {
        require(msg.sender != address(0), "Only valid decryptor.");
        _;
    }

    event decryptionRewardClaimed(
        uint256 pid,
        address creator,
        string decryptedMessage
    );

    function claimDecryption(
        uint256 _pid,
        bytes32 _h1,
        bytes32 _x2
    ) public onlyValidFarmer returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Force execution of claimPuzzle and claimReward to happen in different blocks
        bs.claimBlockNumber[_pid] = block.number;
        // Look up the puzzle
        Puzzle memory puzzle = bs.userPuzzles[_pid];
        ActivePolicy memory policy = bs.activePolicies[puzzle.creator];

        // Accept a claim only if farmer can demonstrate they know H1 and X2 which hash to mkH
        bytes memory b = abi.encodePacked(_x2, _h1);
        console.log(
            "Claiming decryption from Puzzle:",
            LibBqETH.toHexString(_pid)
        );
        // console.log("Received h1:");
        // console.logBytes(abi.encodePacked(_h1));
        // console.log("Received x2:");
        // console.logBytes(abi.encodePacked(_x2));
        // console.log("sha256(b):");
        // console.logBytes(abi.encodePacked(sha256(b)));
        // console.log("Expected h3:");
        // console.logBytes(abi.encodePacked(policy.mkh));

        require(
            sha256(b) == policy.mkh,
            "Commitment must match message kit stamp."
        );
        // Record the farmer who has committed to the solution hash
        bs.claimData[_pid] = msg.sender;
        return _pid;
    }

    // Verifier: Check that H1=Hash(S1), X2=Hash(Salt+S1), and H3=Hash(X2+H1)
    function claimDecryptionReward(
        uint256 _pid,
        string memory _decryptedMessage
    ) public onlyValidFarmer nonReentrant returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Force execution of claimPuzzle and claimReward to happen in different blocks
        require(bs.claimBlockNumber[_pid] < block.number, "Must wait one block before claiming reward.");
        // Look up the puzzle
        Puzzle memory puzzle = bs.userPuzzles[_pid];
        console.log(
            "Claiming decryption from Puzzle:",
            LibBqETH.toHexString(_pid)
        );
        // console.log("Puzzle.x:");
        // console.logBytes(puzzle.x);

        // Inactive puzzle only, reward must be claimed separately to verify proof
        if (BigNumbers.isZero(puzzle.x)) {
            // Must be the same farmer that committed the solution first
            require(
                bs.claimData[_pid] == msg.sender,
                "Original farmer required"
            );
            // The solution submitted must match the commitment
            bytes32 h1 = sha256(abi.encodePacked(_decryptedMessage));
            bytes32 x2 = sha256(abi.encodePacked(salt, _decryptedMessage));
            ActivePolicy memory policy = bs.activePolicies[puzzle.creator];
            require(
                sha256(abi.encodePacked(x2, h1)) == policy.mkh,
                "Decrypted data must match commitment."
            );

            // Pay the decryptor his reward
            uint256 amount = bs.escrow_balances[puzzle.creator];
            console.log("Account Escrow balance:", puzzle.creator, amount);
            console.log("Contract Balance:", address(this).balance);
            require(address(this).balance >= amount, "Insufficient Funds.");
            // (bool success, ) = msg.sender.call.value(balance)("");  Deprecated
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "Transfer failed.");
            console.log("Transfer successful.");

            emit decryptionRewardClaimed(
                _pid,
                puzzle.creator,
                _decryptedMessage
            );

            delete bs.escrow_balances[puzzle.creator];
            delete bs.activePolicies[puzzle.creator];
            delete bs.userPuzzles[_pid];
            delete bs.claimData[_pid];
            delete bs.claimBlockNumber[_pid];
            return _pid;
        } else {
            console.log("Puzzle must be claimed first.");
            return 0;
        }
    }

    // Merkle Tree Case
    function claimDecryptionRewardIPFS(
        uint256 _pid,
        bytes32[] memory proof,
        bool[] memory proofPaths,   // whether to hash as right or left node
        bytes32 leaf,
        string memory newcid
    ) public onlyValidFarmer nonReentrant returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Force execution of claimPuzzle and claimReward to happen in different blocks
        require(bs.claimBlockNumber[_pid] < block.number, "Must wait one block before claiming reward.");

        // Look up the puzzle
        Puzzle memory puzzle = bs.userPuzzles[_pid];

        // Inactive puzzle only, reward must be claimed separately to verify proof
        if (BigNumbers.isZero(puzzle.x)) {
            // Must be the same farmer that committed the solution first
            require(
                bs.claimData[_pid] == msg.sender,
                "Original farmer required"
            );
            ActivePolicy memory policy = bs.activePolicies[puzzle.creator];

            require(
                MerkleTreeVerifier._verify(
                    proof,
                    proofPaths,
                    policy.mtroot,
                    leaf
                ) == true,
                "INVALID_PROOF"
            );

            bytes32 h1 = sha256(abi.encodePacked(leaf));
            bytes32 x2 = sha256(abi.encodePacked(salt, leaf));

            require(
                sha256(abi.encodePacked(x2, h1)) == policy.mkh,
                "Decrypted data must match commitment."
            );

            // We should also verify the new CID
            // if (verifyIPFS.verifyHash(newcid, newcid)) {
            // }

            emit decryptionRewardClaimed(_pid, puzzle.creator, newcid);

            // Pay the decryptor his reward
            uint256 amount = bs.escrow_balances[puzzle.creator];
            console.log("Account Escrow balance:", puzzle.creator, amount);
            console.log("Contract Balance:", address(this).balance);
            require(address(this).balance >= amount, "Insufficient Funds.");
            // (bool success, ) = msg.sender.call.value(balance)("");  Deprecated
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "Transfer failed.");
            console.log("Transfer successful.");

            delete bs.escrow_balances[puzzle.creator];
            delete bs.activePolicies[puzzle.creator];
            delete bs.userPuzzles[_pid];
            delete bs.claimData[_pid];
            delete bs.claimBlockNumber[_pid];

            return _pid;
        } else {
            console.log("Puzzle is not yet claimed.");
            return 0;
        }
    }
}
