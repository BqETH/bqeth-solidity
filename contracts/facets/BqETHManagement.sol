pragma solidity >=0.8.19;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "../libraries/LibBqETH.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/PietrzakVerifier.sol";

contract BqETHManagement is ReentrancyGuard {

    // ================================================================================================================================================
    // TODO: Remove this function, eventually, before throwing away the keys.
    // function sweepFunds() public {
    //     LibDiamond.enforceIsContractOwner();
    //     require(address(this).balance >= 0, "Insufficient Funds.");
    //     address bqethsvc = LibBqETH._getBqETHServicesAddress();
    //     // Contract Owner can Sweep funds to BqETH Services
    //     (bool success, ) = bqethsvc.call{value: address(this).balance}("");
    //     require(success, "Transfer failed.");
    // }

    function setRewardPerDay(uint128 gweiPerDay) external nonReentrant {
        LibDiamond.enforceIsContractOwner();
        LibBqETH._setRewardPerDay(gweiPerDay);
    }

    function getRewardPerDay() public view returns (uint128 gweiPerDay) {
        return LibBqETH._getRewardPerDay();
    }

    function setSecondsPer32Exp(uint128 secondsPer32Exp) external nonReentrant {
        LibDiamond.enforceIsContractOwner();
        LibBqETH._setSecondsPer32Exp(secondsPer32Exp);
    }

    function getSecondsPer32Exp() public view returns (uint128 secondsPer32Exp) {
        return LibBqETH._getSecondsPer32Exp();
    }

    function getBqETHServicesAddress() public view returns (address bqethServicesAddress) {
        return LibBqETH._getBqETHServicesAddress();
    }

    function setBqETHServicesAddress(address bqethServicesAddress) external nonReentrant {
        LibDiamond.enforceIsContractOwner();
        LibBqETH._setBqETHServicesAddress(bqethServicesAddress);
    }

// AUDIT : Use a two-step address change to _governance address separately using setter functions.  
// This mitigates risk because if an incorrect address is used in step (1) then it
// can be fixed by re-approving the correct address. Only after a correct
// address is used in step (1) can step (2) happen and complete the ownership change.
// BqETH will use a 3 step: 

    // 1) Approve a new address as a pendingOwner
    function setNewOwnerCandidate(address newOwner) external nonReentrant {
        LibDiamond.enforceIsContractOwner();
        LibBqETH._setNewOwnerCandidate(newOwner);
    }

    // 2) A transaction from the pendingOwner address claims the pending ownership change.
    function confirmNewOwnerCandidate() external nonReentrant {
        // Must be called BY the candidate
        address candidate = LibBqETH._getNewOwnerCandidate();
        require(msg.sender == candidate, "Only owner candidate");
        LibBqETH._setConfirmedCandidate();
    }

    // 3) Current owner must confirm the ownership transfer
    function finalizeOwnerTransfer() external nonReentrant() {
        // Only current owner can confirm transfer
        LibDiamond.enforceIsContractOwner();
        LibBqETH._finalizeNewOwner();
    }
}
