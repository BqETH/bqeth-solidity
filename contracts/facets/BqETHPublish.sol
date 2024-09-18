pragma solidity >=0.8.19;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import "../libraries/LibBqETH.sol";
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
    bytes32 mkh;
    bytes32 mtroot;
    bytes32 kwh;
    bytes32 dkh;
}

struct BqETHData {
    uint128 passThrough;  // Pre-paid subscription amount
    uint64 servicesAmt;   // Services escrow
    string notifications; // BqETH encrypted Notification payload
}

contract BqETHPublish is ReentrancyGuard {
    
    event NewPuzzleRegistered(
        address sender, 
        uint256 pid, 
        bool ready,
        uint128 t
    );

    // Used for sponsoring
    event NewPolicyRegistered(
        string ritualId, 
        address sender
    );

    // Used for BqETH Tracking of notification selections
    event NewNotificationSet(
        address sender,
        string notifications    // BqETH encrypted Notification payload
    );

    // Used for BqETH to know how much is refunded
    event FlipNotification(
        address sender,
        uint128 refund,
        string notifications,    // BqETH Encrypted Notification Payload
        uint128[] times
    );
    // Used for BqETH to know how much to Refund for services
    event CancellationNotification(
        address sender,
        uint128[] times,
        uint128 refund
    );

    // Not virtual to prevent derived contracts from altering this
    modifier onlyContractCustomer(address _user) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        Puzzle memory puzzle = bs.userPuzzles[bs.activeChainHead[_user]];
        require(msg.sender == puzzle.creator, "Owner only function");
        _;
    }

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
    ) private returns (uint256) {  
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        uint256 reward_total = 0;
        uint256 first_pid = 0;
        require(_c.length < 33, "Chain too long.");
        require(_c.length > 5,  "Chain too short.");

        // Check that modulus is long enough in bits ~2048
        // To avoid bringing in BigNumber library, we're going to check that some bits are set in the high bits of _N
        // In Solidity, you can't directly access the length of a bytes memory parameter. Must assign it first.
        if (true) {
            bytes memory myBytes = _N;
            uint length = myBytes.length;
            require(length == 256,  "Modulus too short"); // N is 2048 bits 
            require((myBytes[0] & 0xe0) != 0, "Modulus too simple");  // At least one of the 3 highest bits is set
            require((myBytes[length-1] & 0x01) != 0, "Modulus even");  // N is odd because it's a product of two safe primes
            require(_c.length == 6 || keccak256(_N) != LibBqETH.TESTNK, "Wrong chain length"); // Test Puzzles fixed at 6 in chain with reward.
        }

        for (uint256 i = 0; i < _c.length; i++) {
            uint256 ph = LibBqETH.puzzleKey(_N, _c[i].x, _c[i].t);
            // Check that the puzzle did not already exist:
            Puzzle memory previous = bs.userPuzzles[ph];
            require(previous.t == 0, "Puzzle already registered");   // We don't want a collision (no copycats or replays)

            // Store the puzzle
            Puzzle memory pz;
            pz.creator = msg.sender;

            pz.x = _c[i].x;
            pz.t = _c[i].t;
            pz.sdate = (i == _c.length - 1) ? _sdate : _c[i].pid; // Only last puzzle gets sdate
            pz.h3 = _c[i].h3;
            pz.reward = _c[i].reward;

            require(pz.x.length >= 254, "Start point too small");  // Check that start point is a 2048 integer
            require(pz.h3 != 0, "Puzzle hash is zero"); // Check that h3 isn't 0
            require(_c.length == 6 || pz.reward != 0, "Zero reward forbidden"); // Check that reward isn't 0 (for real mode)
            // Do we bother with safe math here ? No. Solvers will just ignore the puzzle
            // Check that exponent is not larger than the value for 1 month
            require(pz.t / LibBqETH._getSecondsPer32Exp() < uint128(3600*24*30), "Exponent too large");

            // Notice we store the puzzle at a hash we calculate, pointing to a pid we were given
            // which must match, if the client uses this contract's puzzleKey() with correct values
            bs.userPuzzles[ph] = pz;

            reward_total += _c[i].reward;

            if (i == 0) {
                bs.activeChainHead[msg.sender] = ph;
                first_pid = ph;
            }
            // Send the Event, only the first puzzle in a chain is read-to-solve
            emit NewPuzzleRegistered(msg.sender, ph, (i == 0) ? true : false, pz.t); 
        }
        // msg.value better be more than the sum of puzzle chain rewards
        require(msg.value >= reward_total, "Insufficient value provided.");

        // Record a new chain
        Chain memory chain = Chain(first_pid, _N);
        bs.userChains[msg.sender].chains.push(chain);

        return first_pid;
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
    ) external payable isNotAContract nonReentrant returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        uint256 first_pid = recordPuzzles(_N, _c, _sdate);
        require(first_pid != 0);
        // TODO: Needs to add if existing escrow
        bs.escrow_balances[msg.sender] = msg.value - _bqethData.passThrough;
        // AUDIT: Can't prevent being called by a contract constructor
        require(msg.sender != address(0), "No calls from other contracts"); 
    // Minimum amount for puzzles (5 USD), to prevent DDOS on mainnet
    // require(msg.value > 10);  
        // Make sure the start date preceeds the block (no thwarting the expiration check)
        require(block.timestamp > _sdate/1000, "Puzzle in the future");

        bs.activePolicies[msg.sender] = ActivePolicy(
            msg.sender,
            first_pid,
            _payload.mkh,                   // Decryption gating payload
            _payload.dkh,                   // Decryption gating delivery
            _payload.mtroot,
            _payload.encryptedPayload,
            _payload.encryptedDelivery,
            _policy.ritualId,
            _payload.kwh,
            _policy.whistleBlower
        );

        // Handle BqETH Subscription payment
        if (_bqethData.passThrough > 0) {
            // Send _passthrough Funds to BqETH
            address bqethServices = LibBqETH._getBqETHServicesAddress();
            // Safe way to send funds
            (bool success, ) = bqethServices.call{value: _bqethData.passThrough+_bqethData.servicesAmt}("");
            require(success, "Subscription & Services Transfer failed.");
        }

        // This event is needed for sponsoring
        emit NewPolicyRegistered(
            _policy.ritualId,
            msg.sender
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
    ) external payable onlyContractCustomer(msg.sender) nonReentrant returns (uint256) {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Check previous
        uint256 prev = bs.activeChainHead[msg.sender];
        
        // Puzzle flip restricted to creator of the previous puzzle
        address previous = bs.userPuzzles[prev].creator;
        require(msg.sender == previous, "Only puzzle owner.");

        uint128[] memory times = getCurrentRemainingTimes(prev);

        // Prune previous chains and refund the user if necessary
        uint128 refund = pruneChains(msg.sender);
        if (refund > 0) {
            (bool success, ) = msg.sender.call{value: refund}("");
            // AUDIT: This is also flagged as a re-entrency problem because of the external call but isn't actually a problem.
            require(success, "Refund failed.");
        }

        emit FlipNotification(msg.sender, refund, _bqethData.notifications, times);
        
        uint256 first_pid = recordPuzzles(_N, _c, _sdate);
        // Add to the escrow total for the creator's address.
        bs.escrow_balances[msg.sender] += msg.value - _bqethData.passThrough;

        // Handle BqETH Subscription payment
        if (_bqethData.passThrough > 0) {
            // Send _passthrough Funds to BqETH
            address bqethServices = LibBqETH._getBqETHServicesAddress();
            // Safe way to send funds
            // AUDIT: This is also flagged as a re-entrency problem because of the external call but isn't actually a problem.
            (bool success, ) = bqethServices.call{value: _bqethData.passThrough+_bqethData.servicesAmt}("");
            require(success, "Subscription & Services Transfer failed.");
        }
        
        return first_pid;
    }

    function replaceMessageKit(
        PayloadData memory _payload
    ) external onlyContractCustomer(msg.sender) 
    {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Look up the active policy object and just change the treasuremap
        ActivePolicy storage policy = bs.activePolicies[msg.sender];

        // Whistleblower mode refuses to change messageKit
        if (!policy.whistleBlower) {
            // Only these 5 things change
            if (bytes(_payload.encryptedPayload).length > 0) {
                policy.mkh = _payload.mkh;
                policy.mtroot = _payload.mtroot;
                policy.encryptedPayload = _payload.encryptedPayload;
                policy.kwh = _payload.kwh;
            }
            if (bytes(_payload.encryptedDelivery).length > 0) {
                policy.dkh = _payload.dkh;
                policy.encryptedDelivery = _payload.encryptedDelivery;
            }
        }
    }

    function replaceNotification(
        string memory _notification
    ) external onlyContractCustomer(msg.sender) {

        emit NewNotificationSet(
            msg.sender,
            _notification
        );

    }

    function setWhistleBlower(address user, bool wb
    ) 
        external onlyContractCustomer(msg.sender) nonReentrant
    {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Look up the active policy object and just change the treasuremap
        ActivePolicy storage policy = bs.activePolicies[user];
        policy.whistleBlower = wb;
    }


    // Cancel, Refund, Pruning, Flip Credit, functions

    // Prune all chains for this user to the last unsolved puzzle, return the sum of rewards to refund
    function pruneChains(address _creator) 
        private returns (uint128) 
    {

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
            while (pid_to_check > LibBqETH.Y3K) {    // There is a next puzzle
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
            // Move sdate to the last active puzzle: pid_to_check at the end of the loop is sdate for the chain
            // and we assign it to the last new active puzzle so it is terminated properly
            bs.userPuzzles[last_active].sdate = pid_to_check;
        }

        return refund;
    }


    // Inspired from claimPuzzleReward
    function cancelEverything() 
        external onlyContractCustomer(msg.sender) nonReentrant
    {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();

        // Now take care of wiping out secrets so they are undecryptable forever
        // User will appear 'dead' but their payload will never be decryptable
        bs.activePolicies[msg.sender].mkh = keccak256(abi.encodePacked(LibBqETH.Y3K));
        bs.activePolicies[msg.sender].dkh = keccak256(abi.encodePacked(LibBqETH.Y3K));

        uint256 prev = bs.activeChainHead[msg.sender];
        uint128[] memory times = getCurrentRemainingTimes(prev);

        // Prune previous chains and refund the user if necessary
        uint128 refund = pruneChains(msg.sender);
        if (refund > 0) {
            (bool success, ) = msg.sender.call{value: refund}("");
            require(success, "Refund failed.");
            bs.escrow_balances[msg.sender] -= refund;
        }

        // Now that we have the list of all puzzle times being cancelled
        // Send the event for services refund
        emit CancellationNotification(
            msg.sender,
            times,
            refund
        );
        // This leaves an amount in escrow for the remaining active puzzles
        // and for the decryption reward which will be sent to BqETH 
        // when the last Puzzle reward has been claimed.
    }

    function getCurrentRemainingTimes(uint256 start_pid) 
        private view returns (uint128[] memory times) {
                
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Memory arrays are not resizable, and we don't want this stuff in storage
        uint128[] memory tarray = new uint128[](32);
        uint index = 0;
        // collect all puzzle times from the active puzzle down to the end of the chain
        uint256 pid_to_check = start_pid;
        while (pid_to_check > LibBqETH.Y3K) {
            uint256 next_pid = bs.userPuzzles[pid_to_check].sdate;
            if (bs.userPuzzles[pid_to_check].x.length != 0) {
                tarray[index] = bs.userPuzzles[pid_to_check].t;
                index++;
            }
            pid_to_check = next_pid;
        }
        return tarray;
    }

    // This function checks whether any chain belonging to user _creator has been unclaimed for more than  
    // EXPIRE times the amount of time expected and deleted it, sending rewards to BqETH.  
    function invalidateChain(address _creator) external isNotAContract nonReentrant   
    {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        LibDiamond.enforceIsContractOwner();

        // Now take care of wiping out secrets so they are undecryptable forever
        // User will appear 'dead' but their payload will never be decryptable
        bs.activePolicies[msg.sender].mkh = keccak256(abi.encodePacked(LibBqETH.Y3K));
        bs.activePolicies[msg.sender].dkh = keccak256(abi.encodePacked(LibBqETH.Y3K));

        uint256 timeleft = 0;
        // Collect all puzzle times from the active puzzle down to the end of the chain
        uint128 sp32e = LibBqETH._getSecondsPer32Exp();
        uint128 refund  = 0;

        // Traverse all the chains (some of the user's chains may be legitimate at first)
        Chain[] memory mychains = bs.userChains[_creator].chains;
        uint chainsLength = mychains.length;
        for (uint i = 0; i < chainsLength; i++) {
            // Within each chain, count all puzzles to see if the whole chain has expired
            timeleft = 0;
            Chain memory c = mychains[i];
            uint256 pid_to_check = c.head;
            while (pid_to_check > LibBqETH.Y3K) {    // There is a next puzzle
                uint256 next_pid = bs.userPuzzles[pid_to_check].sdate;
                uint128 exp = bs.userPuzzles[pid_to_check].t;
                timeleft += (sp32e * exp);
                pid_to_check = next_pid;
            }
            // Last one is sdate, convert since original sdate is in milliseconds and block time in seconds
            uint256 start_date = pid_to_check / 1000;

            // If the time elapsed since sdate is greater than EXPIRE times the estimated length of the chain
            if ((block.timestamp - start_date) > (LibBqETH.EXPIRE* timeleft)) {
                uint256 pid_to_clear = mychains[i].head;
                // Delete the puzzles
                while (pid_to_clear > LibBqETH.Y3K) {    // There is a next puzzle
                    uint256 next_pid = bs.userPuzzles[pid_to_clear].sdate;
                    pid_to_clear = next_pid;
                    if (bs.userPuzzles[pid_to_check].x.length != 0) {
                        // Add its reward to the refund
                        refund += bs.userPuzzles[pid_to_clear].reward;
                    }
                    // Let the farmers know
                    emit LibBqETH.PuzzleInactive(
                        pid_to_clear,
                        "","Pruned","","",
                        bs.userPuzzles[pid_to_clear].sdate
                    );
                    // Delete it
                    delete bs.userPuzzles[pid_to_clear];
                }
                delete bs.userChains[_creator].chains[i];
            }
        }

        // Prune previous chains and refund the user if necessary
        if (refund > 0) {
            // Send _passthrough Funds to BqETH
            address bqethServices = LibBqETH._getBqETHServicesAddress();
            // Send reward to BqETH
            (bool success, ) = bqethServices.call{value: refund}("");
            require(success, "Refund failed.");
            bs.escrow_balances[msg.sender] -= refund;
        }
    }
}