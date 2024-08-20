pragma solidity >=0.8.19;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "../libraries/LibBqETH.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/PietrzakVerifier.sol";

contract BqETHSolve is ReentrancyGuard {
    bytes32 immutable salt = "BqETH";
    uint256 constant min_verification_reward = 447552447552444;

    modifier isNotAContract() {
        require(!isAContract(msg.sender));  // Warning: will return false if the call is made from the constructor of a smart contract
        require(tx.origin == msg.sender);   // Prevents a constructor from making the call, overkill ?
        _;
    }
    function isAContract(address _address) private view returns (bool isContract) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size != 0);
    }

    event RewardClaimed(uint256 pid, bytes y, uint256 sdate, uint256 reward);

    // Creator H1=Hash(S1), X2=Hash(Salt+S1), H3=Hash(X2+H1) -> publishes H3
    // Claim: Publish H1, X2
    // Verifier: Verify Hash(H1,X2) = H3  accept the lock
    function claimPuzzle(
        uint256 _pid,
        bytes32 _h1,
        bytes32 _x2
    ) external isNotAContract returns (uint256) {
        // Force execution of claimPuzzle and claimReward to happen in different blocks
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Look up the puzzle
        Puzzle memory puzzle = bs.userPuzzles[_pid];
        console.log("Claiming puzzle:", LibBqETH.toHexString(_pid));

        // Accept a claim only if farmer can demonstrate they know H1 and X2 which hash to H3
        bytes memory b = abi.encode(_x2, _h1);
        require(sha256(b) == puzzle.h3, "Commitment must match puzzle stamp.");
        // Record the farmer who has committed to the solution hash        
        // TODO: Add a condition that the new claiming block must be 20+ than the previous one if any
        bs.claimBlockNumber[_pid] = block.number;
        bs.claimData[_pid] = msg.sender;
        return _pid;
    }

    // Fast and low gas log base2
    function log2(uint256 x) private pure returns (uint8) {
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
    ) external isNotAContract nonReentrant returns (uint256) {
        // Force execution of claimPuzzle and claimReward to happen in different blocks
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        require(
            bs.claimBlockNumber[_pid] < block.number,
            "Must wait one block before claiming puzzle reward."
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

            require(
                sha256(abi.encodePacked(
                    sha256(abi.encodePacked(salt, _y)), // x2
                    sha256(abi.encodePacked(_y))        // h1
                )) == puzzle.h3,
                "Solution must match commitment."
            );

            // Make sure the pid is valid for the _N in the chain
            uint256 ph = LibBqETH.puzzleKey(chain.N, puzzle.x, puzzle.t);
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
                uint256 amount = puzzle.reward;
                require(address(this).balance >= amount, "Contract Insufficient Balance.");
                (bool success, ) = msg.sender.call{value: amount}("");
                require(success, "Transfer failed.");

                bs.escrow_balances[puzzle.creator] -= puzzle.reward;
                console.log(
                    "Account Escrow balance:",
                    puzzle.creator,
                    bs.escrow_balances[puzzle.creator]
                );
                bs.userPuzzles[_pid].x = "";       // Set puzzle to inactive
                // console.log("Zeroed Puzzle:", LibBqETH.toHexString(_pid));
                bs.userPuzzles[_pid].reward = 0;   // Set reward to zero

                emit RewardClaimed(_pid, _y, puzzle.sdate, puzzle.reward);

                // Handle the end of puzzle chain situation
                if (puzzle.sdate < LibBqETH.Y3K) {
                    
                    // Remove all puzzles from the chain
                    houseKeeping(puzzle, chain);

                    emit LibBqETH.PuzzleInactive(
                        _pid, // Puzzle Hash
                        policy.ritualId, // The verifying key
                        policy.encryptedPayload,  // The secret
                        policy.encryptedDelivery, // The secret
                        _y,   // The solution
                        puzzle.sdate    // This is the start date
                    );

                } 
                else {
                    // Intermediate puzzles don't need to send the cyphers out
                    emit LibBqETH.PuzzleInactive(
                        _pid, // Puzzle Hash
                        policy.ritualId, // The ritual Id key
                        "", // The encryptedPayload
                        "", // The encryptedDelivery
                        "",
                        puzzle.sdate    // This is a pid
                    );
                }
            }
            delete bs.claimBlockNumber[_pid];
            delete bs.claimData[_pid];
            return _pid;
        } else {
            console.log("Puzzle already claimed");
            return 0;
        }
    }

    function houseKeeping(Puzzle memory puzzle, Chain memory chain) private {

        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();

        // last puzzle in the chain -> remove all puzzles from the chain
        uint256 pid_to_clear = chain.head;
        while (pid_to_clear > LibBqETH.Y3K) {
            // Clear puzzle chain
            uint256 next_pid = bs.userPuzzles[pid_to_clear].sdate;
            if (next_pid > LibBqETH.Y3K) {
                delete bs.userPuzzles[pid_to_clear];
            }
            pid_to_clear = next_pid;
        }
        // This leaves the current (last) puzzle still in userPuzzles

        // Clear out the puzzle chain if no new one took its place
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

        // If the user has no remaining chain and his policy is marked as cancelled
        if (bs.userChains[puzzle.creator].chains.length == 0 &&
            (bs.activePolicies[puzzle.creator].mkh == 0 ||
             bs.activePolicies[puzzle.creator].mkh == keccak256(abi.encodePacked(LibBqETH.Y3K))
            )
            ) {
            // Send remaining decryption escrow funds to BqETH
            address bqethServices = LibBqETH._getBqETHServicesAddress();
            (bool success, ) = bqethServices.call{value: bs.escrow_balances[puzzle.creator]}("");
            require(success, "Subscription & Services Transfer failed.");

            // Now we can free up space in the contract
            delete bs.escrow_balances[puzzle.creator];
            delete bs.activePolicies[puzzle.creator];
        }
    }
}
