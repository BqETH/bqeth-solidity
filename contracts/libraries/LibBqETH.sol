// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { LibDiamond } from "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

struct PuzzleChains {
    Chain[] chains;
}

struct Chain {
    uint256 head; // Chain head pid
    bytes N; // The modulus for all puzzles in the chain
}

struct Puzzle {
    address creator; // The user who registered the puzzle
    uint128 t; // The time parameter
    uint128 reward; // The amount that should be dispensed
    uint256 sdate; // The start date or next pid in chain
    bytes32 h3; // H3 Hash value of the solution
    bytes x; // The start value
}

struct ActivePolicy {
    address creator;    // The user who registered the puzzle
    uint256 pid;        // The puzzle id which issued the policy
    bytes32 mkh;        // Decrypted message hash of hashes
    bytes32 dkh;        // Delivery kit hash of hashes
    bytes32 mtroot;     // The Merkle Tree Root for verification
    string encryptedPayload;  // The encrypted secret
    string encryptedDelivery; // The encrypted delivery
    string ritualId;    // The Threshold Ritual ID
    bytes32 kwh;        // Hash of the search keywords
    bool whistleBlower;
}

library LibBqETH {
    bytes32 constant BQETH_PUZZLES = keccak256("bqeth.puzzles.storage");  // Diamond storage
    bytes32 constant BQETH_METRICS = keccak256("bqeth.metrics.storage");  // Diamond storage
    bytes32 constant BQETH_ADMIN   = keccak256("bqeth.admin.storage");    // Diamond storage
    string public constant version = "BqETH Version 3.0";
    uint64 public constant Y3K = 32503680000000;
    bytes32 public constant TESTNK = keccak256(hex"36da36ef00062a5b988efd0df129f8b8bd4a56d143dbbb3633e6729b7099238623f2115aaad348c64dec719cb66f99add07eea357a69f1867bdec91895e3c737fd8579b0598f660cf6ddd95426aab89afcc062e83fb5f5e43ef54f828c5ca1cefdc083b2497641b0ddfe3d5cc86bc84c7b47714c4cfe96e75b4d9d03cbaa4c9b017c20d28ddd796079f7c3c5de3916329be7fcee168c129180225ad8494520ce53348936dbd6060de15c994df2d8d47d26d1919fee4d405f42f0868962168a23912b3a198abf7b5b600c75868f3a66ae5bd61217867add8618e049992abe8a0464c5d9cad69c0c57a84d14912ebb22f393fdcba2ba0eaf02fb10329e38224ea3");

    event PuzzleInactive(
        uint256 pid,
        string ritualId,
        string encryptedPayload,
        string encryptedDelivery,
        bytes solution,
        uint256 sdate
    );    
    
    struct BqETHStorage {
        mapping(address => PuzzleChains) userChains;    // User -> Chains -> [(head,modulus)]
        mapping(uint256 => Puzzle) userPuzzles;         // Pid -> Puzzle
        mapping(uint256 => address) claimData;          // Pid -> Farmer
        mapping(uint256 => uint256) claimBlockNumber;   // Pid -> BlockNumber
        mapping(address => uint256) escrow_balances;    // User -> Escrow
        mapping(address => ActivePolicy) activePolicies; // User -> ActivePolicy
        mapping(address => uint256) activeChainHead;    // User -> Active chain head pid
    }

    function bqethStorage() public pure returns (BqETHStorage storage bds) {
        bytes32 position = BQETH_PUZZLES;
        assembly {
            bds.slot := position
        }
    }

    struct BqETHMetrics {
        uint128 gweiPerDay;                // Market Reward per Day in Gwei
        uint128 secondsPer32Exp;           // Best recorded speed for x^(2^32) in seconds
    }

    function bqethAdmin() public pure returns (BqETHAdmin storage bas) {
        bytes32 position = BQETH_ADMIN;
        assembly {
            bas.slot := position
        }
    }

    struct BqETHAdmin {
        address bqethServices;                // Address for BqETH Services Pass-Through
    }

    function bqethMetrics() public pure returns (BqETHMetrics storage bms) {
        bytes32 position = BQETH_METRICS;
        assembly {
            bms.slot := position
        }
    }

    function toHexString(uint i) public pure returns (string memory) {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0) {
            length++;
            j = j >> 4;
        }
        uint mask = 15;
        bytes memory bstr = new bytes(length);
        uint k = length;
        while (i != 0) {
            uint curr = (i & mask);
            bstr[--k] = curr > 9
                ? bytes1(uint8(55 + curr))
                : bytes1(uint8(48 + curr)); // 55 = 65 - 10
            i = i >> 4;
        }
        return string(bstr);
    }

    // Some unique key for each puzzle
    function puzzleKey(
        bytes memory _N,
        bytes memory _x,
        uint256 _t
    ) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_N, _x, _t)));
    }

    function _findPuzzleChain(
        uint256 _pid,
        address _creator
    ) internal view returns (Chain memory) {
        BqETHStorage storage bs = bqethStorage();
        // AUDIT LibBqETH._findPuzzleChain(uint256,address).chain (contracts/libraries/LibBqETH.sol#117) is a local variable never initialized
        // Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#uninitialized-local-variables
        Chain memory chain; // Not always initialized, but not a risk.
        bool found = false;
        // We must first find the chain for this puzzle
        Chain[] memory mychains = bs.userChains[_creator].chains;
        uint chainsLength = mychains.length;
        for (uint i = 0; i < chainsLength; i++) {
            Chain memory c = mychains[i];
            uint256 pid_to_check = c.head;
            while (pid_to_check > Y3K) {
                // Clear puzzle chain
                uint256 next_pid = bs.userPuzzles[pid_to_check].sdate;
                if (pid_to_check == _pid) {
                    chain = c;
                    found = true;
                    break; // We found our Puzzle
                }
                pid_to_check = next_pid;
            }
            if (found) {
                // We found it, look no further
                break;
            }
        }
        return chain;
    }

    function _getActiveChain(
        address _user
    )
        public
        view
        returns (
            Puzzle[] memory chain // The Puzzle chain
        )
    {
        // This is now always the first puzzle of a chain
        BqETHStorage storage bs = bqethStorage();
        uint256 ph = bs.activeChainHead[_user];
        Puzzle memory puzzle = bs.userPuzzles[ph];

        // Count the puzzles in the chain
        uint256 idx = 1;
        while (puzzle.sdate > Y3K) {
            puzzle = bs.userPuzzles[puzzle.sdate];
            idx++;
        }

        Puzzle[] memory puzzles = new Puzzle[](idx);
        puzzle = bs.userPuzzles[ph];
        uint256 i = 0;
        while (puzzle.sdate > Y3K) {
            puzzles[i] = puzzle;
            puzzle = bs.userPuzzles[puzzle.sdate];
            i++;
        }
        puzzles[i] = puzzle; // Save the final puzzle

        return (
            puzzles // The puzzle chain
        );
    }

    function _getActivePuzzle(
        address _user
    )
        public
        view
        returns (
            uint256 pid, // The puzzle key
            address creator, // The puzzle creator
            bytes memory N, // The modulus
            bytes memory x, // The start value
            uint256 t, // The time parameter
            bytes32 h3, // H3 Hash value of the solution
            uint256 reward, // The amount that should be dispensed
            uint256 sdate
        )
    {
        // This is now always the first puzzle of a chain as long as the chain is active
        BqETHStorage storage bs = bqethStorage();
        // If the user has cancelled their hourglass, the active chain will still be valid for a while until
        // their last puzzle is solved and claimed
        // We're going to check that the policy mkh is bogus, to see whether we should return anything
        if (bs.activePolicies[_user].mkh == keccak256(abi.encodePacked(Y3K))) {
            revert("Cancelled puzzle.");
        }
        uint256 ph = bs.activeChainHead[_user];
        if (ph == 0) {
            bytes memory nullbytes = new bytes(0);
            uint256 nullint = 0;
            return (nullint,address(0), nullbytes,nullbytes,nullint,bytes32(0),nullint,0);
        }
        return _getPuzzle(ph);
    }

    /// @notice Performs a formal request for all of a puzzle's data
    /// @param _pid uint256 The puzzle hash
    function _getPuzzle(
        uint256 _pid
    )
        public
        view
        returns (
            uint256 pid, // The puzzle key
            address creator, // The puzzle creator
            bytes memory N, // The modulus
            bytes memory x, // The start value
            uint256 t, // The time parameter
            bytes32 h3, // H3 Hash value of the solution
            uint256 reward, // The amount that should be dispensed
            uint256 sdate
        )
    {
        BqETHStorage storage bs = bqethStorage();
        Puzzle memory puzzle = bs.userPuzzles[_pid];
        require(puzzle.creator != address(0), "Puzzle not found.");
        Chain memory chain = _findPuzzleChain(_pid, puzzle.creator);

        return (
            _pid,
            puzzle.creator, // The puzzle creator
            chain.N, // The modulus
            puzzle.x, // The start value
            puzzle.t, // The time parameter
            puzzle.h3, // H3 Hash value of the solution
            puzzle.reward, // The amount that should be dispensed
            puzzle.sdate // The start date or next puzzle pid
        );
    }

    function _setRewardPerDay(uint128 gweiPerDay) internal {
        LibDiamond.enforceIsContractOwner();
        BqETHMetrics storage bms = bqethMetrics();
        bms.gweiPerDay = gweiPerDay;
    }

    function _getRewardPerDay() internal view 
    returns (uint128 gweiPerDay) {
        BqETHMetrics storage bms = bqethMetrics();
        return bms.gweiPerDay;
    }

    function _setSecondsPer32Exp(uint128 secondsPer32Exp) internal {
        LibDiamond.enforceIsContractOwner();
        BqETHMetrics storage bms = bqethMetrics();
        bms.secondsPer32Exp = secondsPer32Exp;
    }

    function _getSecondsPer32Exp() internal view 
    returns (uint128 secondsPer32Exp) {
        BqETHMetrics storage bms = bqethMetrics();
        return bms.secondsPer32Exp;
    }

    function _setBqETHServicesAddress(address bqethSvc) internal {
        LibDiamond.enforceIsContractOwner();
        BqETHAdmin storage bas = bqethAdmin();
        bas.bqethServices = bqethSvc;
    }

    function _getBqETHServicesAddress() internal view 
    returns (address bqethServices) {
        BqETHAdmin storage bas = bqethAdmin();
        address bqethSvc = bas.bqethServices;
        if (bqethSvc == address(0x0)) {
            return LibDiamond.contractOwner();
        }
        else {
            return bqethSvc;
            
        }
    }
}
