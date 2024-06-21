pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "../libraries/LibBqETH.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/PietrzakVerifier.sol";

contract BqETHManagement is ReentrancyGuard {
    bytes32 immutable salt = "BqETH";

    // ================================================================================================================================================
    // TODO: Remove this function. This is for testing purposes only. DO NOT RELEASE TO PRODUCTION
    // function sweepFunds() public {
    //     LibDiamond.enforceIsContractOwner();
    //     require(address(this).balance >= 0, "Insufficient Funds.");
    //     (bool success, ) = msg.sender.call{value: address(this).balance}("");
    //     require(success, "Transfer failed.");
    // }

    // // TODO Delete this function before releasing to Production
    // function setMeDead(address _user) public {
    //     LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
    //     ActivePolicy storage policy = bs.activePolicies[_user];
    //     emit PuzzleInactive(
    //         0,                  // Puzzle Hash
    //         policy.ritualId, // The verifying key
    //         policy.encryptedPayload,  // The secret
    //         policy.encryptedDelivery, // The delivery
    //         "",
    //         32400080000000
    //     );
    //     delete bs.activeChainHead[_user];
    // }

// AUDIT : Use a two-step
// address change to _governance address separately using setter functions: 1)
// Approve a new address as a pendingOwner 2) A transaction from the
// pendingOwner (TracerDAO) address claims the pending ownership change.
// This mitigates risk because if an incorrect address is used in step (1) then it
// can be fixed by re-approving the correct address. Only after a correct
// address is used in step (1) can step (2) happen and complete the
// address/ownership change.
}
