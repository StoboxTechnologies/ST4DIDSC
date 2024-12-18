# DID Hook & DID Prototype Smart Contracts

This repository contains two Solidity smart contracts: `DIDHook` and `DIDPrototype`. These contracts are designed to integrate with decentralized finance (DeFi) protocols, providing a decentralized identity (DID) system. The `DIDHook` contract is used to verify the user before performing actions like adding liquidity, removing liquidity, swapping, and donating. The `DIDPrototype` contract is a decentralized identity (DID) management contract, allowing the creation, modification, and management of users' DIDs, attributes, and blocklist statuses.

## Contracts

### 1. `DIDHook`

The `DIDHook` contract integrates with the pool manager of a decentralized exchange (DEX) or other liquidity-based systems. It validates user identities before allowing certain actions.

#### Key Features

- Verifies a user’s DID (Decentralized Identity) before executing specific actions.
- Performs checks on user status (e.g., blocked or not) via an external `IDIDValidator` contract.
- Supports operations like adding/removing liquidity, swapping tokens, and donating.

#### Functions

- `beforeAddLiquidity`: Verifies the user before adding liquidity.
- `beforeRemoveLiquidity`: Verifies the user before removing liquidity.
- `beforeSwap`: Verifies the user before performing a token swap.
- `beforeDonate`: Verifies the user before making a donation to the pool.
- `getHookPermissions`: Specifies which actions are allowed for the hook.

#### Constructor

The constructor initializes the contract by linking to an external pool manager and DID validator.

```solidity
constructor(IPoolManager _manager, address _validatorContract) BaseHook(_manager)
```

---

### 2. `DIDPrototype`

The `DIDPrototype` contract enables creating, updating, and managing decentralized identities (DIDs) for users. Each user’s DID is associated with a wallet, validity period, and other user attributes.

#### Key Features

- Create and update a user’s DID with wallet address, validity, and blocked status.
- Store and manage hashed attributes for users.
- Block or unblock users based on specific conditions.
- Add or remove global attributes from the system.
- Tracks updates on the user’s DID and logs events like DID creation, updates, and block/unblock actions.

#### Functions

- **DID Management:**
  - `updateOrCreateDID`: Creates or updates the DID of a user.
  - `updateOrAddDIDAttributeHashes`: Adds or updates hashed attributes for a user.
  - `deleteUserAttribute`: Deletes a specific attribute for a user.
  - `setUserValidTo`: Updates the validity period of a user's DID.

- **Blocking and Unblocking:**
  - `blockUser`: Blocks a user and marks them as blocked in the DID system.
  - `unblockUser`: Unblocks a previously blocked user.

- **Global Attributes:**
  - `addGlobalAttribute`: Adds a new global attribute to the system.
  - `deleteGlobalAttribute`: Deletes an existing global attribute.
  - `getGlobalAttributes`: Returns the list of global attributes.

- **Query Functions:**
  - `getUserDID`: Fetches the DID information for a specific user.
  - `getHashedAttribute`: Retrieves a hashed attribute for a specific user.

---

## Errors

- `AttributeAlreadyExists`: Thrown when trying to add an attribute that already exists.
- `UserDoesntHaveDID`: Thrown when attempting to modify or fetch a DID that doesn’t exist.
- `ArraysAreNotEqual`: Thrown when the array sizes of attribute names and hashed attributes do not match.
- `UserIsBlocked`: Thrown when a user is blocked and attempts to perform an action.
- `UserIsNotBlocked`: Thrown when a user is not blocked and an action is attempted on their block status.

---

## Modifiers

- `ifUserExist`: Ensures that the user has a DID before proceeding.
- `updatedNow`: Updates the `updatedAt` timestamp for the user when modifying their DID.

---

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/your-repository/did-smart-contracts.git
   cd did-smart-contracts
   ```

2. Install the dependencies (if any):

   ```bash
   npm install
   ```

3. Deploy the contracts using your preferred method (Truffle, Hardhat, etc.) and configure it for the Ethereum network or any other supported network.

---

## Usage

### DIDHook Contract

The `DIDHook` contract is typically used by a pool manager (e.g., a decentralized exchange) to validate users' DIDs before performing key actions. To deploy the contract, specify the following parameters:

- `IPoolManager _manager`: The address of the pool manager (e.g., the DEX contract).
- `address _validatorContract`: The address of the external DID validator contract.

### DIDPrototype Contract

The `DIDPrototype` contract allows for the management of user DIDs. It provides functions to create, update, block, unblock users, and manage their attributes.

---

## Events

- `UserBlocked`: Emitted when a user is blocked.
- `UserUnblocked`: Emitted when a user is unblocked.
- `UserDIDUpdated`: Emitted when a user's DID is created or updated.
- `GlobalAttributeListUpdated`: Emitted when a global attribute is added or removed.

---

## Security Considerations

- Ensure that the `DIDPrototype` contract is only interacted with by trusted parties (the owner), as sensitive operations like blocking users or adding attributes are restricted to the owner.
- When using the `DIDHook` contract, make sure that the validator contract is secure and properly handles user validation.

---

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

---

## License

This project is licensed under the MIT License.