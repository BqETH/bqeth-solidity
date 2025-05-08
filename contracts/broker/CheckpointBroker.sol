pragma solidity >=0.8.19;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CheckpointBroker is ReentrancyGuard {

    string public constant version = "Checkpoint Broker Version 1.0";
    address contractOwner;                // This is the contract's owner
    address ownerCandidate;               // Address for new candidate owner
    address confirmedCandidate;           // Address of confirmed candidate owner

    // Who is authorized to participate in the group DH and convo
    mapping(address => bool) internal authorizations;
    address[] public authorized_addresses;

    // This mapping is to store Diffie Hellman key shares
    mapping(address => bytes32) dh_share;
    uint8 public constant ROUND1 = 1;
    uint8 public constant ROUND2 = 2;


    event OwnershipChange(address previousOwner, address newOwner);
    event UpdatedPublicPoint(address indexed participant, uint8 round);
    event UpdatedCheckpoints(address solver, uint256 pid, uint256 blockNumber, uint64 timeout);

    constructor() {
        console.log("Deploying :", version);
        contractOwner = msg.sender;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == contractOwner, "Caller must be the contract owner");
    }
    
    // Use a two-step address change to _governance address separately using setter functions.  
    // This mitigates risk because if an incorrect address is used in step (1) then it
    // can be fixed by re-approving the correct address. Only after a correct
    // address is used in step (1) can step (2) happen and complete the ownership change.
    // Checkpoint Broker will use a 3 step process:

    // 1) Approve a new address as a pendingOwner
    function setNewAuthorityCandidate(address newOwner) external nonReentrant {
        // Must be called BY the candidate
        enforceIsContractOwner();      
        ownerCandidate = newOwner;
    }

    // 2) A transaction from the pendingOwner address claims the pending ownership change.
    function confirmNewAuthorityCandidate() external nonReentrant {
        // Must be called BY the candidate
        address candidate;
        if (ownerCandidate == address(0x0)) {
            candidate = contractOwner;
        }
        else {
            candidate = ownerCandidate;
        }
        require(msg.sender == candidate, "Only owner candidate");
        confirmedCandidate = ownerCandidate;
    }

    // 3) Current owner must confirm the ownership transfer
    function finalizeOwnerTransfer() external nonReentrant() {
        // Only current owner can confirm transfer
        enforceIsContractOwner();
        contractOwner = confirmedCandidate;
        emit OwnershipChange(msg.sender, confirmedCandidate);
    }


    // These function allow the owner of the contract to authorize participation
    // of some addresses in the sharing of their Diffie Hellman shares.
    /**
     * @notice Emitted when an address authorization is set
     * @param _address The address that is authorized
     * @param isAuthorized The authorization status
     */
    event AddressAuthorizationSet(
        address indexed _address,
        bool isAuthorized
    );


    /**
     * @notice Checks if an participant is authorized for the group convo
     * @param participant The address of the participant
     * @return The authorization status
     */
    function isAddressAuthorized(address participant) public view returns (bool) {
        return authorizations[participant];
    }

    function getAuthorizedAddresses() public view returns (address[] memory authorized_list) {
        return authorized_addresses;
    }

    /**
     * @notice Authorizes a list of addresses for a group convo
     * @param participant The addresses to be authorized
     */
    function authorize(
        address[] calldata participant
    ) external {
        enforceIsContractOwner();
        setAuthorizations(participant, true);
    }

    /**
     * @notice Deauthorizes a list of addresses for a ritual
     * @param participant The addresses to be deauthorized
     */
    function deauthorize(
        address[] calldata participant
    ) external {
        enforceIsContractOwner();
        setAuthorizations(participant, false);
    }

    /**
     * @notice Sets the authorization status for a list of addresses for the convo
     * @param addresses The addresses to be authorized or deauthorized
     * @param value The authorization status
     */
    function setAuthorizations(address[] calldata addresses, bool value) internal {

        require(addresses.length <= 8, "Too many addresses");

        for (uint256 i = 0; i < addresses.length; i++) {
            // prevent reusing same address
            require(authorizations[addresses[i]] != value, "Authorization already set");
            authorizations[addresses[i]] = value;
            if (value == true) {
                authorized_addresses.push(addresses[i]);
            }
            else {  // Remove the unauthorized address from the array
                // for (authorized_addresses
            }
            emit AddressAuthorizationSet(addresses[i], value);
        }
    }

    function receivePublicPoint(bytes32 publicPoint) public {
        require(isAddressAuthorized(msg.sender), "Sender not authorized");
        dh_share[msg.sender] = publicPoint;
        emit UpdatedPublicPoint(msg.sender, ROUND1);
    }

    function updatePublicPoint(address[] calldata addresses, bytes32[] memory publicPoint) external nonReentrant {
        enforceIsContractOwner();
        for (uint256 i = 0; i < addresses.length; i++) {
            dh_share[addresses[i]] = publicPoint[i];
            emit UpdatedPublicPoint(addresses[i], ROUND2);
        }
    }

    function getPublicPoint(address participant) public view returns (bytes32) {
        require(isAddressAuthorized(participant), "Participant not authorized");
        return dh_share[participant];
    }

    // Almost Decentralized Diffie-Hellmann:
    //
    // A                 B                 C                 Contract                 Owner
    // |                 |                 |                     |                       |
    // |---------------->|---------------->|-------------------->|                       |
    // | receivePublicPoint(g^alpha)       |                     |                       |
    // |                 |                 |                     |                       |
    // |                 |---------------->|-------------------->|                       |
    // |                 | receivePublicPoint(g^beta)            |                       |
    // |                 |                 |                     |                       |
    // |                 |                 |-------------------->|                       |
    // |                 |                 | receivePublicPoint(g^sigma)                 |
    // |                 |                 |                     |                       |
    // |                 |                 |                     |<----------------------|
    // |                 |                 |                     | updatePublicPoint(    |
    // |                 |                 |                     |   [A, B, C],          |
    // |                 |                 |                     |   [g^(beta*sigma*omega),
    // |                 |                 |                     |    g^(alpha*sigma*omega),
    // |                 |                 |                     |    g^(alpha*beta*omega)]
    // |                 |                 |                     | )                     |
    // |                 |                 |                     |                       |
    // |<----------------|-----------------|---------------------|                       |
    // | getPublicPoint() -> g^(beta*sigma*omega)                |                       |
    // |                 |                 |                     |                       |
    // |                 |<----------------|---------------------|                       |
    // |                 | getPublicPoint() -> g^(alpha*sigma*omega)                     |
    // |                 |                 |                     |                       |
    // |                 |                 |<--------------------|                       |
    // |                 |                 | getPublicPoint() -> g^(alpha*beta*omega)    |
    // |                 |                 |                     |                       |
    // Each participant can now derive the shared key: 
    // A with g^(beta*sigma*omega) derives g^(beta*sigma*omega*alpha)
    // B with g^(alpha*sigma*omega) derives g^(alpha*sigma*omega*beta) etc...


    // This is the core purpose of the contract: to let authorized participants share  
    // payloads encrypted with their shared keys, onto EIP-4844 sidecar blobs
    // the decryption of which is up to them, the revelance of which is also
    // up to them, and the structure of which is up to them. 
    // The timeout value is a UTC timestamp of when the combination of these sidecars for one pid
    // should be collected in an attempt to take over solving.
    function submitCheckpoints(bytes calldata blob, address solver, uint256 pid, uint64 timeout) public {
        require(blob.length > 0, "Blob must not be empty");
        require(isAddressAuthorized(solver), "Participant must be authorized.");
        
        // Notify Everyone
        emit UpdatedCheckpoints(solver, pid, block.number, timeout);
    }

}


