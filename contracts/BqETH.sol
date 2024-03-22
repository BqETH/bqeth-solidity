//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";


import "./libraries/LibBqETH.sol";

import { LibDiamond } from "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

/// @title BqETH Contract
contract BqETH is ReentrancyGuard {
    address owner;

    constructor() {
        console.log("Deploying BqETH Contract with version:", LibBqETH.version);
    }

    function version() public pure returns (string memory) {
        return LibBqETH.version;
    }

    // Some unique key for each puzzle  
    // Same function as in LbBqETH but avoids delegateCall
    function puzzleKey(
        bytes memory _N,
        bytes memory _x,
        uint256 _t
    ) public pure returns (uint256) {
        return LibBqETH._puzzleKey(_N, _x, _t);
    }

    function getActiveChain(
        address _user
    )
        public
        view
        returns (
            Puzzle[] memory chain // The Puzzle chain
        )
    {
        // This is now always the first puzzle of a chain
        return LibBqETH._getActiveChain(_user);
    }

    function getActivePuzzle(
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
        return LibBqETH._getActivePuzzle(_user);
    }

    /// @notice Performs a formal request for all of a puzzle's data
    /// @param _pid uint256 The puzzle hash
    function getPuzzle(
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
        return LibBqETH._getPuzzle(_pid);
    }

    /// @notice Performs a check that the User has No active Puzzle
    /// @notice Returns 0 is the user has an active puzzle
    /// @notice Otherwise returns non-zero hash matching contition of the decryptable secret
    /// @param  user address The user address
    function hasNoActivePuzzle(address user)
        public view returns (bytes32 hash)
    {
        // This is now always the first puzzle of a chain as long as the chain is active
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        uint256 ph = bs.activeChainHead[user];
        ActivePolicy memory policy = bs.activePolicies[user];
        if (ph != 0)
            return 0;           // Return False, address has an active puzzle
        else {
            return policy.mkh;  // Return True, address has NO active puzzle
        }
    }

    function getActivePolicy(address _user) public view returns (
        string memory ritualId,
        bytes32 mkh)
    {
        LibBqETH.BqETHStorage storage bs = LibBqETH.bqethStorage();
        // Look up the active policy object and just change the treasuremap
        ActivePolicy memory policy = bs.activePolicies[_user];

        return (
            policy.ritualId,
            policy.mkh
        );
    }

    function setRewardPerDay(uint128 gweiPerDay) public {
        LibDiamond.enforceIsContractOwner();
        LibBqETH._setRewardPerDay(gweiPerDay);
    }

    function getRewardPerDay() public view returns (uint128 gweiPerDay) {
        return LibBqETH._getRewardPerDay();
    }

    function setSecondsPer32Exp(uint128 secondsPer32Exp) public {
        LibDiamond.enforceIsContractOwner();
        LibBqETH._setSecondsPer32Exp(secondsPer32Exp);
    }

    function getSecondsPer32Exp() public view returns (uint128 secondsPer32Exp) {
        return LibBqETH._getSecondsPer32Exp();
    }

    // To support receiving ETH by default
    receive() external payable {}

    fallback() external payable {}
}
