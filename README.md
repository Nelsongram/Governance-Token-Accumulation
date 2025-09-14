# Governance Token Accumulation Trap

This project is a proof-of-concept (PoC) for a Drosera trap designed to detect the rapid accumulation of a specific governance token by a group of large holders (whales). I built this as part of my exploration into the Drosera Network and its capabilities for on-chain security.

## How it Works

The system is composed of two main contracts:

1.  **`GovernanceTokenTrap.sol`**: This is the main trap contract. It's designed to be deployed by the Drosera network. It monitors a hardcoded list of "whale" addresses and the total balance of a specific governance token they hold.

    -   The `collect()` function is called periodically by Drosera nodes. It reads the balance of the governance token for each of the tracked whale addresses and returns this data.

    -   The `shouldRespond()` function is a `pure` function that is called by the Drosera network. It receives a history of the data collected by the `collect()` function. It compares the total token balance of the whales from the last two data points. If the balance has increased by a predefined `BALANCE_THRESHOLD`, it triggers a response.

2.  **`Response.sol`**: This contract is responsible for handling the response when the trap is triggered. It's a simple contract that emits an event with the details of the token accumulation.

    -   The `onTrapTriggered()` function is called by the Drosera network when the `shouldRespond()` function of the trap returns `true`. It receives the data from the trap, decodes it, and emits a `GovernanceTokenAccumulationDetected` event.

## Testing

I've included a test suite for the `GovernanceTokenTrap` contract. The tests are written using Foundry.

To run the tests, you can use the following command:

```bash
~/.foundry/bin/forge test
```

The tests ensure that:

-   The `collect()` function correctly gathers the balances of the tracked addresses.
-   The `shouldRespond()` function correctly identifies when the accumulation threshold is crossed and when it is not.

This project demonstrates a simple yet effective way to monitor on-chain activity and react to potential threats using the Drosera Network.