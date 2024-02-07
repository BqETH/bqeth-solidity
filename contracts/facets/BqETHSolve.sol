pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "../libraries/LibBqETH.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/PietrzakVerifier.sol";

contract BqETHSolve is ReentrancyGuard {
    bytes32 immutable salt = "BqETH";
    uint256 constant min_verification_reward = 447552447552444;

    modifier onlyValidFarmer() {
        require(msg.sender != address(0), "Only valid farmer.");
        _;
    }

    event PuzzleInactive(
        uint256 pid,
        string ritualId,
        string encryptedPayload,
        string encryptedDelivery,
        bytes solution,
        uint256 sdate
    );
    event RewardClaimed(uint256 pid, bytes y, uint256 sdate, uint256 reward);

    // Creator H1=Hash(S1), X2=Hash(Salt+S1), H3=Hash(X2+H1) -> publishes H3
    // Claim: Publish H1, X2
    // Verifier: Verify Hash(H1,X2) = H3  accept the lock
    function claimPuzzle(
        uint256 _pid,
        bytes32 _h1,
        bytes32 _x2
    ) public onlyValidFarmer returns (uint256) {
        // Force execution of claimPuzzle and claimReward to happen in different blocks
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        bs.claimBlockNumber[_pid] = block.number;
        // Look up the puzzle
        Puzzle memory puzzle = bs.userPuzzles[_pid];
        console.log("Claiming puzzle:", LibBqETH.toHexString(_pid));

        // Accept a claim only if farmer can demonstrate they know H1 and X2 which hash to H3
        bytes memory b = abi.encode(_x2, _h1);
        require(sha256(b) == puzzle.h3, "Commitment must match puzzle stamp.");
        // Record the farmer who has committed to the solution hash
        bs.claimData[_pid] = msg.sender;
        return _pid;
    }

    // Fast and low gas log base2
    function log2(uint256 x) public pure returns (uint8) {
        uint8 n = 0;

        if (x >= 2 ** 128) { x >>= 128; n += 128; }
        if (x >= 2 ** 64) {  x >>= 64;  n += 64;  }
        if (x >= 2 ** 32) {  x >>= 32;  n += 32;  }
        if (x >= 2 ** 16) {  x >>= 16;  n += 16;  }
        if (x >= 2 ** 8) {   x >>= 8;   n += 8;   }
        if (x >= 2 ** 4) {   x >>= 4;   n += 4;   }
        if (x >= 2 ** 2) {   x >>= 2;   n += 2;   }
        if (x >= 2 ** 1) {/* x >>= 1; */ n += 1; }
        return n;
    }

    // Reward claim: S1, Proof p
    // Verifier: Check Proof is valid for S1, Check that H1=Hash(S1), X2=Hash(Salt+S1), and H3=Hash(X2+H1)
    function claimReward(
        uint256 _pid,
        bytes memory _y,
        bytes[] memory _proof
    ) public onlyValidFarmer nonReentrant returns (uint256) {
        // Force execution of claimPuzzle and claimReward to happen in different blocks
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        require(
            bs.claimBlockNumber[_pid] < block.number,
            "Block number too low"
        );
        // Look up the puzzle
        Puzzle memory puzzle = bs.userPuzzles[_pid];
        Chain memory chain = LibBqETH._findPuzzleChain(_pid, puzzle.creator);
        ActivePolicy memory policy = bs.activePolicies[puzzle.creator];

        if (!BigNumbers.isZero(puzzle.x)) {
            // Valid and active puzzle
            // Must be the same farmer that committed the solution first
            require(
                bs.claimData[_pid] == msg.sender,
                "Original farmer required"
            );
            // The solution submitted must match the commitment
            // bytes32 h1 = sha256(abi.encodePacked(_y));
            // bytes32 x2 = sha256(abi.encodePacked(salt, _y));

            require(
                sha256(abi.encodePacked(
                    sha256(abi.encodePacked(salt, _y)), // x2
                    sha256(abi.encodePacked(_y))        // h1
                )) == puzzle.h3,
                "Solution must match commitment."
            );

            // We can't fetch N from the Chain array, because a flip might have modified it
            // Make sure the pid is valid for the _N given
            uint256 ph = LibBqETH._puzzleKey(chain.N, puzzle.x, puzzle.t);
            require(ph == _pid, "Must claim a valid puzzle.");

            // Now we can bother to verify if the reward is high enough, and clean up the chain
            if (puzzle.reward < min_verification_reward ||
                PietrzakVerifier.verifyProof(
                    chain.N,
                    puzzle.x,
                    log2(puzzle.t) - 1,
                    _y,
                    0,
                    _proof
                )
            ) {
                // Pay the farmer his reward
                // console.log("Account Escrow balance:", escrow_balances[puzzle.creator]);
                uint256 amount = puzzle.reward;
                require(address(this).balance >= amount, "Insufficient Funds.");
                (bool success, ) = msg.sender.call{value: amount}("");
                require(success, "Transfer failed.");

                bs.escrow_balances[puzzle.creator] -= puzzle.reward;
                console.log(
                    "Account Escrow balance:",
                    puzzle.creator,
                    bs.escrow_balances[puzzle.creator]
                );
                console.log("Contract Balance:", address(this).balance);
                // console.log("New Escrow balance:    ", escrow_balances[puzzle.creator]);
                bs.userPuzzles[_pid].x = ""; // Set puzzle to inactive
                // console.log("Zeroed Puzzle:", LibBqETH.toHexString(_pid));
                bs.userPuzzles[_pid].reward = 0; // Set reward to zero

                emit RewardClaimed(_pid, _y, puzzle.sdate, puzzle.reward);

                // Handle the end of puzzle chain situation
                if (puzzle.sdate < Y3K) {
                    
                    houseKeeping(puzzle, chain);

                    emit PuzzleInactive(
                        _pid, // Puzzle Hash
                        policy.ritualId, // The verifying key
                        policy.encryptedPayload,  // The secret
                        policy.encryptedDelivery, // The secret
                        _y,   // The solution
                        puzzle.sdate
                    );

                } else {
                    // Intermediate puzzles don't need to send the cyphers out
                    emit PuzzleInactive(
                        _pid, // Puzzle Hash
                        policy.ritualId, // The ritual Id key
                        "", // The encryptedPayload
                        "", // The encryptedDelivery
                        "",
                        puzzle.sdate
                    );
                }
            }
            delete bs.claimBlockNumber[_pid];
            return _pid;
        } else {
            console.log("Puzzle already claimed");
            return 0;
        }
    }

    function houseKeeping(Puzzle memory puzzle, Chain memory chain) internal {

        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();

        // last puzzle in the chain -> remove all puzzles from the chain
        uint256 pid_to_clear = chain.head;
        while (pid_to_clear > Y3K) {
            // Clear puzzle chain
            uint256 next_pid = bs.userPuzzles[pid_to_clear].sdate;
            if (next_pid > Y3K) {
                delete bs.userPuzzles[pid_to_clear];
                // console.log(
                //     "Deleted puzzle:",
                //     LibBqETH.toHexString(pid_to_clear)
                // );
            }
            pid_to_clear = next_pid;
        }
        // This leaves the current (last) puzzle still in userPuzzles

        // clear out the puzzle if no new one took its place
        if (bs.activeChainHead[puzzle.creator] == chain.head) {
            delete bs.activeChainHead[puzzle.creator];
            // We can also get rid of the chain
            Chain[] memory mychains = bs
                .userChains[puzzle.creator]
                .chains;
            uint chainsLength = mychains.length;
            for (uint i = 0; i < chainsLength; i++) {
                Chain memory c = mychains[i];
                if (c.head == chain.head) {
                    // Is this going to cause the chain array loop to barf ?
                    delete bs.userChains[puzzle.creator].chains[i];
                    break;
                }
            }
        }
    }

    // TODO Delete this function before releasing to Production
    function setMeDead(address _user) public {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        ActivePolicy storage policy = bs.activePolicies[_user];
        emit PuzzleInactive(
            0,                  // Puzzle Hash
            policy.ritualId, // The verifying key
            policy.encryptedPayload,  // The secret
            policy.encryptedDelivery, // The delivery
            "",
            32400080000000
        );
        delete bs.activeChainHead[_user];
    }
}
