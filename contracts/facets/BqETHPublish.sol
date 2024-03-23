pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import { LibDiamond } from "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

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
    string condition;   // Maybe remove this ?
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

    // Used for BqETH Refund of a portion of services
    event CancellationNotification(
        address sender,
        uint128[] times
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

            // msg.value better be more than the sum of puzzle chain rewards
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
            _payload.mkh,                   // Decryption reward gating
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
        
        // Puzzle flip restricted to creator of the previous puzzle
        address previous = bs.userPuzzles[prev].creator;
        require(msg.sender == previous, "Only puzzle owner.");

        // Prune previous chains and refund the user if necessary
        uint128 refund = pruneChains(msg.sender);
        if (refund > 0) {
            (bool success, ) = msg.sender.call{value: refund}("");
            require(success, "Refund failed.");
        }

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


    // Cancel, Refund, Pruning, Flip Credit, functions

    // Prune all chains for this user to the last unsolved puzzle, return the sum of rewards to refund
    function pruneChains(address _creator) internal returns (uint128) {

        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        uint128 refund  = 0;

        // Traverse all the chains
        Chain[] memory mychains = bs.userChains[_creator].chains;
        uint chainsLength = mychains.length;
        for (uint i = 0; i < chainsLength; i++) {
            // Within each chain, delete all puzzles except the first unsolved one
            // A chain of (pid,x,sdate) could be [(pid1,'',pid2),(pi2,'',pid3),(pid3,0x0342,pid4), (pid4,0x547a,pid5), (pid5,03453,sdate)]
            // and pid3 is active, so only pid4 and pid5 need to be removed, then replace pid4 inside pid3 with sdate from pid5
            Chain memory c = mychains[i];
            uint256 pid_to_check = c.head;
            uint256 last_active = 0;
            while (pid_to_check > Y3K) {    // There is a next puzzle
                uint256 next_pid = bs.userPuzzles[pid_to_check].sdate;

                if (last_active == 0  && 
                    bs.userPuzzles[pid_to_check].x.length != 0) {
                    // We just found the first unsolved puzzle
                    last_active = pid_to_check;
                }
                else if (last_active != 0 && last_active != pid_to_check) {
                    // This puzzle isn't the last unsolved, 
                    // Add its reward to the refund
                    refund += bs.userPuzzles[pid_to_check].reward;
                    // Let the farmers know
                    emit LibBqETH.PuzzleInactive(
                        pid_to_check,
                        "","Pruned","","",
                        bs.userPuzzles[pid_to_check].sdate
                    );
                    // Delete it
                    delete bs.userPuzzles[pid_to_check];
                }
                pid_to_check = next_pid;
            }
            // pid_to_check is now sdate for the last puzzle in the chain
            bs.userPuzzles[last_active].sdate = pid_to_check;
        }

        return refund;
    }


    // Inspired from claimPuzzleReward
    function cancelEverything() public payable onlyContractCustomer(msg.sender) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();

        // Now take care of wiping out secrets so they are undecryptable forever
        // User will appear 'dead' but their payload will never be decryptable
        bs.activePolicies[msg.sender].mkh = keccak256(abi.encodePacked(Y3K));

        // Memory arrays are not resizable, and we don't want this stuff in storage
        uint128[] memory times = new uint128[](32);
        uint index = 0;
        // collect all puzzle times from the active puzzle down to the end of the chain
        uint256 pid_to_check = bs.activeChainHead[msg.sender];
        while (pid_to_check > Y3K) {
            uint256 next_pid = bs.userPuzzles[pid_to_check].sdate;
            if (bs.userPuzzles[pid_to_check].x.length != 0) {
                times[index] = bs.userPuzzles[pid_to_check].t;
                index++;
            }
            pid_to_check = next_pid;
        }
        // Now that we have the list of all puzzle times being cancelled
        // Send the event for services refund
        emit CancellationNotification(
            msg.sender,
            times
        );

        // Prune previous chains and refund the user if necessary
        uint128 refund = pruneChains(msg.sender);
        if (refund > 0) {
            (bool success, ) = msg.sender.call{value: refund}("");
            require(success, "Refund failed.");
            bs.escrow_balances[msg.sender] -= refund;
        }

        // This leaves an amount in escrow for the remaining active puzzles
        // and for the decryption reward, which will be sent to BqETH 
        // when the last Puzzle has been claimed.
    }
}