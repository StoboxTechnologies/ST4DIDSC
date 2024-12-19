# DID Hook & DID Prototype Smart Contracts

This repository contains three Solidity smart contracts: `DIDHook`, `DIDPrototype`and `DIDValidator`. These contracts are designed to integrate with decentralized finance (DeFi) protocols, providing a decentralized identity (DID) system. The `DIDHook` contract is used to verify the user before performing actions like adding liquidity, removing liquidity, swapping, and donating. The `DIDPrototype` contract is a decentralized identity (DID) management contract, allowing the creation, modification, and management of users' DIDs, attributes, and blocklist statuses. The `DIDValidator` contract ensures that user DIDs are valid and that specific attributes meet predefined criteria. It works in tandem with the DIDPrototype contract to validate user data and enforce system rules.

### **Test Smart Contracts. Arbitrum Sepolia Testnet**
[DIDPrototype](https://sepolia.arbiscan.io/address/0xd0586379734431a34b09b50396cb35ee956b8ccd#code) 0xD0586379734431A34b09b50396cb35Ee956b8CCD

[DIDValidator](https://sepolia.arbiscan.io/address/0x4aa5ec1e40d621278a5d875fab943cfa1b2efb7a#code) 0x4AA5EC1E40D621278A5D875fAb943CFA1b2eFB7a

```
/project-root
│
├── /src
│   ├── DIDHook.sol
│   ├── DIDPrototype.sol
│   └── DIDValidator.sol
│
├── /script
│   └── Deploy.s.sol
│        └── DeployDIDandValidatorScript.sol
│
├── remappings.txt
├── .env.example
└── foundry.toml
```

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
### 3. `DIDValidator`

The `DIDValidator` contract ensures that user DIDs are valid and that specific attributes meet predefined criteria. It works in tandem with the `DIDPrototype` contract to validate user data and enforce system rules.

#### Key Features

- Validate a user’s DID by checking its validity period, blocked status, and required attributes.
- Define required attributes that all users must have to pass validation.
- Dynamically assign validation logic to specific attributes using function selectors.
- Support for restricting users based on allowed countries.
- Update, remove, or reset the list of required attributes and allowed countries.

#### Functions

- **Validation:**
  - `validateUser`: Validates a user's DID and required attributes.
  - `_validDID`: Internal function to ensure the user's DID is valid and not blocked.
  - `_checkUserAttributes`: Internal function to validate required attributes using their associated actions.

- **Attribute Management:**
  - `addAttribute`: Adds a new required attribute with a custom validation function selector.
  - `deleteAttribute`: Removes a specific required attribute.
  - `resetAllAttributes`: Clears all required attributes from the system.
  - `getAttributesMustHave`: Fetches the list of all required attributes.

- **Country Restriction:**
  - `checkCountry`: Verifies if a user's attribute (e.g., "Country") matches the allowed list.
  - `getAllowedCountries`: Retrieves the list of allowed countries.

- **Utilities:**
  - `_existsInMustHave`: Internal function to check if an attribute exists in the required list.
  - `_getHash`: Computes the hash of a user's wallet and attribute name.
  - `_ifEqual`: Compares two strings for equality.

---

### Events

- `AttributesMustHaveUpdated`: Emitted when a required attribute is added, removed, or reset.

---

### Errors

- `AttributeAlreadyExists`: Thrown when trying to add an attribute that already exists in the required list.
- `UserDIDNotValid`: Thrown when a user’s DID is invalid or blocked.
- `AttributeNotValid`: Thrown when a specific attribute fails validation.

---

### Modifiers

- **None:** The contract relies on `onlyOwner` from OpenZeppelin's `Ownable` for owner-restricted actions.

---

### Validation Workflow

1. A user’s DID is fetched using the `DIDPrototype` interface.
2. The contract verifies that the DID is not expired and the user is not blocked.
3. Each required attribute is validated using its associated custom logic, defined by function selectors.
4. Attributes like "Country" are further validated against a list of allowed values.

This contract provides a modular and flexible approach to enforcing rules and validating user identities in decentralized systems.

---

## Installation Steps

1. Clone the repository:
```
git clone git@github.com:StoboxTechnologies/ST4DIDSC.git
```
2. Install dependencies:
```
forge install
```
3. Set Environment Variables: You need to set up the necessary environment variables in the `.env` file. A sample `.env.example` file is provided in this repository. Fill in the required values for the following variables:
```
   - `PRIVATE_KEY`: Your private key for the deployer's wallet.
   - `ARB_SEPOLIA_RPC_URL`: RPC URL for the Arbitrum Sepolia network.
   - `ARBISCAN_API_KEY`: API key for interacting with the blockchain explorer.
```
4. Compile the contracts:
```
forge build
```
5. Deploy the contract (we use Arbitrum Sepolia):
```
source .env
```
```
forge script --chain 421614 script/Deploy.s.sol:DeployDIDandValidatorScript --rpc-url $ARB_SEPOLIA_RPC_URL --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvvv
```

## License

This project is licensed under the MIT License.