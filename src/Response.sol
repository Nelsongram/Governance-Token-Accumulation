// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Response Contract
/// @notice This contract is called by the Drosera network when the GovernanceTokenTrap is triggered.
contract Response {
    event GovernanceTokenAccumulationDetected(
        address[] trackedAddresses,
        uint256[] balancesBefore,
        uint256[] balancesAfter
    );

    /// @notice This function is called by the Drosera network.
    /// It decodes the response data from the trap and emits an event.
    function onTrapTriggered(bytes calldata data) external {
        (address[] memory trackedAddresses, uint256[] memory balancesBefore, uint256[] memory balancesAfter) = abi.decode(data, (address[], uint256[], uint256[]));
        emit GovernanceTokenAccumulationDetected(trackedAddresses, balancesBefore, balancesAfter);
    }
}
