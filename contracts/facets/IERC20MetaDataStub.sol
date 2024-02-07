// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract IERC20MetaDataStub {
    // For some reason, MetaMask calls these functions, so I must deploy this stub to avoid errors.
    // 0x95d89b41 -> link_classic_internal(uint64,int64) or symbol()
    // 0x313ce567 -> decimals() or available_assert_time(uint16,uint64)
    function symbol() external pure returns (string memory) {
        console.log("symbol called.");
        return "ETH";
    }

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external pure returns (uint8) {
        console.log("symbol called.");
        return 18;
    }
}
