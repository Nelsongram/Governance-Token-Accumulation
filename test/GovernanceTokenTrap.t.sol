// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovernanceTokenTrap} from "../src/GovernanceTokenTrap.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract GovernanceTokenTrapTest is Test {
    GovernanceTokenTrap public trap;
    MockERC20 public governanceToken;

    address[] public trackedAddresses;

    function setUp() public {
        // Deploy the mock token
        governanceToken = new MockERC20("Mock Governance Token", "MGT", 18);

        // Deploy the trap
        trap = new GovernanceTokenTrap();
        trap.setGovernanceToken(address(governanceToken));

        trackedAddresses = new address[](2);
        trackedAddresses[0] = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;
        trackedAddresses[1] = 0x503828976d22510AAD0201aC7eC88293211D2383;

        // Mint some initial tokens to the tracked addresses
        for (uint i = 0; i < trackedAddresses.length; i++) {
            governanceToken.mint(trackedAddresses[i], 1000 * 1e18);
        }
    }

    function test_Collect() public view {
        bytes memory data = trap.collect();
        (address[] memory _trackedAddresses, uint256[] memory balances) = abi.decode(data, (address[], uint256[]));

        assertEq(_trackedAddresses.length, trackedAddresses.length);
        assertEq(balances.length, trackedAddresses.length);
        for (uint i = 0; i < balances.length; i++) {
            assertEq(_trackedAddresses[i], trackedAddresses[i]);
            assertEq(balances[i], 1000 * 1e18);
        }
    }

    function test_ShouldRespond_NoTrigger() public {
        bytes memory data0 = trap.collect();

        // Mint a small amount of tokens, below the threshold
        governanceToken.mint(trackedAddresses[0], 100 * 1e18);

        bytes memory data1 = trap.collect();

        bytes[] memory data = new bytes[](2);
        data[0] = data0;
        data[1] = data1;

        (bool should, ) = trap.shouldRespond(data);

        assertFalse(should);
    }

    function test_ShouldRespond_Trigger() public {
        bytes memory data0 = trap.collect();

        // Mint a large amount of tokens, above the threshold
        governanceToken.mint(trackedAddresses[0], 20000 * 1e18);

        bytes memory data1 = trap.collect();

        bytes[] memory data = new bytes[](2);
        data[0] = data0;
        data[1] = data1;

        (bool should, bytes memory response) = trap.shouldRespond(data);

        assertTrue(should);

        (address[] memory _trackedAddresses, uint256[] memory balancesBefore, uint256[] memory balancesAfter) = abi.decode(response, (address[], uint256[], uint256[]));

        assertEq(_trackedAddresses.length, trackedAddresses.length);
        assertEq(balancesBefore.length, trackedAddresses.length);
        assertEq(balancesAfter.length, trackedAddresses.length);

        assertEq(balancesBefore[0], 1000 * 1e18);
        assertEq(balancesAfter[0], 21000 * 1e18);
    }
}
