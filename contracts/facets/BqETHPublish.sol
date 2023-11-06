pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import { LibDiamond } from "../../node_modules/hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

// import "typescript-solidity-merkle-tree/contracts/MerkleTreeVerifier.sol";
import "../libraries/BigNumbers.sol";
import "../libraries/PietrzakVerifier.sol";
import "../libraries/LibBqETH.sol";

// Structures used for passing data through functions
struct ChainData {
    uint128 t; // The time parameter
    uint128 reward; // The amount that should be dispensed
    uint256 pid; // The next pid
    bytes32 h3; // H3 Hash value of the solution
    bytes x; // The start value
}

struct PolicyData {
    string ritualId;
    bool whistleBlower;
}

struct PayloadData {
    string encryptedPayload;
    string encryptedDelivery;
    string condition;
    bytes32 mkh;
    bytes32 mtroot;
}

struct BqETHData {
    uint64 passThrough;   // Pre-paid subscription amount
    uint64 services;      // Services selection
    uint64 servicesAmt;   // Services escrow
    string notifications; // BqETH encrypted Notification payload
}


contract BqETHPublish is ReentrancyGuard {
    event NewPuzzleRegistered(address sender, uint256 pid, bool ready);

    // Used for sponsoring
    event NewPolicyRegistered(
        string ritualId
    );

    // Used for BqETH Tracking of notification selections
    event NewNotificationSet(
        address sender,
        string notifications    // BqETH encrypted Notification payload
    );

    modifier onlyContractCustomer(address _user) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        Puzzle memory puzzle = bs.userPuzzles[bs.activeChainHead[_user]];
        require(msg.sender == puzzle.creator, "Owner only function");
        _;
    }

    /// @notice Registers a user Puzzle Chain
    /// @dev This registration creates an entry per puzzle in the userPuzzles map. The parameters completely and uniquely define the puzzle
    /// and may be repeated across multiple puzzles since (N,φ) will be re-used until N has decayed.
    /// @param _N bytes  The prime composite modulus
    /// @param _c[] ChainData  The puzzle initial challenges
    /// @param _sdate uint256  The start date (UTC) or the next puzzle hash in the chain
    function recordPuzzles(
        bytes memory _N,
        ChainData[] memory _c,
        uint256 _sdate
    ) internal returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        uint256 reward_total = 0;
        uint256 first_pid = 0;

        for (uint256 i = 0; i < _c.length; i++) {
            uint256 ph = puzzleKey(_N, _c[i].x, _c[i].t);
            // TODO Check that the puzzle did not already exist:
            // Puzzle memory puzzle = userPuzzles[ph];
            // require(puzzle.N != 0, "Puzzle already registered");   // We cannot afford a collision

            //Store the puzzle
            Puzzle memory pz;
            pz.creator = msg.sender;

            pz.x = _c[i].x;
            pz.t = _c[i].t;
            pz.sdate = (i == _c.length - 1) ? _sdate : _c[i].pid; // Only last puzzle gets sdate
            pz.h3 = _c[i].h3;
            pz.reward = _c[i].reward;

            // Notice we store the puzzle at a hash we calculate, pointing to a pid we were given
            // which must match, if the client uses this contract's puzzleKey() with correct values
            bs.userPuzzles[ph] = pz;

            reward_total += _c[i].reward;

            if (i == 0) {
                bs.activeChainHead[msg.sender] = ph;
                first_pid = ph;
            }

            // TODO msg.value better be more than the sum of puzzle chain rewards
            require(msg.value >= reward_total, "Insufficient value provided.");

            console.log(
                "Registered puzzle with Hash :'%s'",
                LibBqETH.toHexString(ph),
                "For user", msg.sender
            );
            // Send the Event
            emit NewPuzzleRegistered(msg.sender, ph, (i == 0) ? true : false); // First puzzle in a chain is read-to-work
        }

        // Record a new chain
        Chain memory chain = Chain(first_pid, _N);
        bs.userChains[msg.sender].chains.push(chain);

        return first_pid;
    }

        // Some unique key for each puzzle
    function puzzleKey(
        bytes memory _N,
        bytes memory _x,
        uint256 _t
    ) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_N, _x, _t)));
    }

    /// @notice Registers a user Puzzle Chain
    /// @dev This registration creates an entry per puzzle in the userPuzzles map. The parameters completely and uniquely define the puzzle
    /// and may be repeated across multiple puzzles since (N,φ) will be re-used until N has decayed.
    /// @param _N bytes  The prime composite modulus
    /// @param _c[] ChainData  The puzzle initial challenges
    /// @param _sdate uint256  The start date (UTC) or the next puzzle hash in the chain
    /// @param _policy PolicyData  The details of the NuCypher policy covering this
    /// @param _payload PayloadData The encrypted payload, edlivery and merkle root hash
    /// @param _bqethData A structure for BqETH to anonymously track user choices
    /// @return ph uint256 Returns the puzzle hash key of the first puzzle
    function registerPuzzleChain(
        bytes memory _N,
        ChainData[] memory _c,
        uint256 _sdate,
        PolicyData memory _policy,
        PayloadData memory _payload,
        BqETHData memory _bqethData
    ) public payable returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        uint256 first_pid = recordPuzzles(_N, _c, _sdate);
        bs.escrow_balances[msg.sender] = msg.value - _bqethData.passThrough;
        // console.log("Account Escrow balance:", escrow_balances[msg.sender]);

        bs.activePolicies[msg.sender] = ActivePolicy(
            msg.sender,
            first_pid,
            _payload.mkh,
            _payload.mtroot,
            _payload.encryptedPayload,
            _payload.encryptedDelivery,
            _payload.condition,
            _policy.ritualId,
            _policy.whistleBlower
        );

        // Handle BqETH Subscription payment
        if (_bqethData.passThrough > 0) {
            // Send _passthrough Funds to BqETH
            address owner = LibDiamond.contractOwner();
            // Safe way to send funds
            (bool success, ) = owner.call{value: _bqethData.passThrough+_bqethData.servicesAmt}("");
            require(success, "Subscription & Services Transfer failed.");
        }

        // This event is needed for sponsoring
        emit NewPolicyRegistered(
            _policy.ritualId
        );

        emit NewNotificationSet(
            msg.sender,
            _bqethData.notifications
        );

        return first_pid;
    }

    /// @notice Registers a flipped user Puzzle
    /// @dev This registration creates an entry per puzzle in the userPuzzles map. The parameters completely and uniquely define the puzzle
    /// and may be repeated across multiple puzzles since (N,φ) will be re-used until N has decayed.
    /// @param _N bytes  The prime composite modulus
    /// @param _c[] ChainData  The puzzle initial challenges
    /// @param _sdate uint256  The start date (UTC) or the next puzzle hash in the chain
    /// @return ph uint256 Returns the puzzle hash key
    function registerFlippedPuzzle(
        bytes memory _N,
        ChainData[] memory _c,
        uint256 _sdate,
        BqETHData memory _bqethData
    ) public payable onlyContractCustomer(msg.sender) returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Check previous
        uint256 prev = bs.activeChainHead[msg.sender];
        // Puzzle memory previous = userPuzzles[prev];
        // Puzzle flip restricted to creator of the previous puzzle
        address previous = bs.userPuzzles[prev].creator;
        require(msg.sender == previous, "Only puzzle owner.");

        uint256 first_pid = recordPuzzles(_N, _c, _sdate);
        // Add to the escrow total for the creator's address.
        bs.escrow_balances[msg.sender] += msg.value - _bqethData.passThrough;

        // Handle BqETH Subscription payment
        if (_bqethData.passThrough > 0) {
            // Send _passthrough Funds to BqETH
            address owner = LibDiamond.contractOwner();
            // Safe way to send funds
            (bool success, ) = owner.call{value: _bqethData.passThrough+_bqethData.servicesAmt}("");
            require(success, "Subscription & Services Transfer failed.");
        }
        
        return first_pid;
    }

    function replaceMessageKit(
        PayloadData memory _payload
    ) public onlyContractCustomer(msg.sender) 
    {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Look up the active policy object and just change the treasuremap
        ActivePolicy storage policy = bs.activePolicies[msg.sender];

        // Whistleblower mode refuses to change messageKit
        if (!policy.whistleBlower) {
            // Only these 4 things change
            if (bytes(_payload.encryptedPayload).length > 0) {
                policy.mkh = _payload.mkh;
                policy.mtroot = _payload.mtroot;
                policy.encryptedPayload = _payload.encryptedPayload;
                policy.condition = _payload.condition;
            }
            if (bytes(_payload.encryptedDelivery).length > 0) {
                policy.encryptedDelivery = _payload.encryptedDelivery;
            }
        }
    }

    function replaceNotification(
        string memory _notification
    ) public onlyContractCustomer(msg.sender) {

        emit NewNotificationSet(
            msg.sender,
            _notification
        );

    }

    function setWhistleBlower(address user, bool wb
    ) public onlyContractCustomer(msg.sender) 
    {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Look up the active policy object and just change the treasuremap
        ActivePolicy storage policy = bs.activePolicies[user];
        policy.whistleBlower = wb;
    }

    
}