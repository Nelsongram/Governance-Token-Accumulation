// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @title Governance Token Accumulation Trap
/// @notice This trap monitors the balance of a specific governance token for a list of addresses.
/// It triggers a response if the total balance of the monitored addresses increases by a certain threshold.
contract GovernanceTokenTrap is ITrap {
    IERC20 public GOVERNANCE_TOKEN = IERC20(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap V2 Router - Placeholder

    // List of addresses to monitor
    address[] public trackedAddresses = [
        0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B, // VB - Placeholder
        0x503828976d22510AAD0201aC7eC88293211D2383  // Placeholder
    ];

    // The threshold for the total balance increase
    uint256 public constant BALANCE_THRESHOLD = 10000 * 1e18;

    /// @notice (TEST ONLY) Sets the governance token address for testing purposes.
    function setGovernanceToken(address _tokenAddress) external {
        GOVERNANCE_TOKEN = IERC20(_tokenAddress);
    }

    /// @notice Collects the current balance of all tracked addresses.
    /// This function is called by a Drosera node.
    function collect() external view override returns (bytes memory) {
        uint256[] memory balances = new uint256[](trackedAddresses.length);
        for (uint256 i = 0; i < trackedAddresses.length; i++) {
            balances[i] = GOVERNANCE_TOKEN.balanceOf(trackedAddresses[i]);
        }
        return abi.encode(trackedAddresses, balances);
    }

    /// @notice Determines if a response should be triggered based on the collected data.
    /// This function is called by the Drosera network.
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, "");
        }

        (address[] memory _trackedAddresses, uint256[] memory balances0) = abi.decode(data[data.length - 2], (address[], uint256[]));
        (, uint256[] memory balances1) = abi.decode(data[data.length - 1], (address[], uint256[]));

        uint256 totalBalance0 = 0;
        for (uint256 i = 0; i < balances0.length; i++) {
            totalBalance0 += balances0[i];
        }

        uint256 totalBalance1 = 0;
        for (uint256 i = 0; i < balances1.length; i++) {
            totalBalance1 += balances1[i];
        }

        if (totalBalance1 > totalBalance0) {
            uint256 balanceIncrease = totalBalance1 - totalBalance0;
            if (balanceIncrease >= BALANCE_THRESHOLD) {
                return (true, abi.encode(_trackedAddresses, balances0, balances1));
            }
        }

        return (false, "");
    }
}
