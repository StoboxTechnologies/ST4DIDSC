# Stobox DID Contract

### Arbitrum Sepolia

**[SDID v0.1](https://sepolia.arbiscan.io/address/0xa832662d1e11f2a6cef706ce54a993e7eeedc440#code) 0xA832662d1E11F2a6cEF706cE54A993E7eeEDC440**

## Overview
The **SDID** smart contract is an implementation of a decentralized identity (DID) system. It supports the creation, update, and revocation of various credentials. Compliance officers can introduce new attributes (e.g., “Accredited Investor”) or manage restrictions (e.g., “Blocked” status) on the fly, with changes automatically recognized by the STV3 contract and other integrated systems.

## Documentation 
A more detailed description of Stobox Decentralized ID can be found in the [Documentation](https://docs.stobox.io/products-and-services/stobox-did) 

## Key features
- **DID Management**
  - Create, update, and manage DIDs.
  - Link multiple addresses to a DID.
  - Control access to DID attributes.
  - Deactivate and activate DIDs and linked addresses.
  - Block and unblock DIDs.
  
- **Attribute Management**
  - Add and update attributes for a DID.
  - Set expiration dates for attributes.
  - Deactivate attributes when no longer needed.

- **Access Control**
  - Roles for managing access:
    - **DEFAULT_ADMIN_ROLE**: Full administrative control over the contract.
    - **WRITER_ROLE**: Can create and manage DIDs and attributes.
    - **ATTRIBUTE_READER_ROLE**: Can read attributes of a DID.
  - Add and update external readers with expiration control.
  - Grant read-only access to attributes for external readers.
  - Remove external reader access when needed.

- **Linked Addresses**
  - Limit the number of linked addresses per DID.
  - Link/unlink addresses to DIDs.
  - Deactivate/activate linked addresses, tracking their status.

## Some Smart Contract Details

## Events
The contract emits events for important actions, including:

- `DIDCreated`
- `DIDAddressLinked`
- `DIDAddressDeleted`
- `DIDAddressDeactivated`
- `DIDAddressActivated`
- `DIDValidToDateUpdated`
- `AttributeValidToDateUpdated`
- `DIDBlockStatusUpdated`
- `AttributeCreated`
- `AttributeUpdated`
- `AttributeDeactivated`
- `UnexpectedBehavior`
- `NewExternalReaderAdded`
- `ExternalReaderUpdated`
- `ExternalReaderDeleted`
- `AttributeListWasRead`
- `LinkedAddressesListWasRead`
- `FullDIDWasRead`

## Functions

### 1. DID Management
- `createDID()`
- `prolongateDID()`
- `blockDID()`
- `unBlockDID()`

### 2. Attribute Management
- `addOrUpdateAttributes()`
- `deactivateDIDAttribute()`

### 3. ExternalReader Management
- `addOrUpdateExternalReader()`
- `deleteExternalReader()`
- `externalReaderExpirationDate()`

### 4. LinkedAddresses Management
- `linkAddressToDID()`
- `removeLinkedAddress()`
- `deactivateAddressOfDID()`
- `activateAddressOfDID()`
- `setMaxDIDLinkedAddresses()`

### 5. Data Access
- `readAttributeList()`
- `readLinkedAddresses()`
- `readFullDID()`

### 6. Read-Only Methods
- `getUserDID()`
- `getAttribute()`
- `getLinker()`
- `canRead()`

## Error Handling
The contract includes custom errors for validation and security:
- `CantRevokeLastSuperAdmin()`
- `CantRemoveLastLinkedAddress()`
- `DIDAlreadyExists(string UDID)`
- `DIDDoesNotExist(string UDID)`
- `ZeroAddressNotAllowed()`
- `AddressAlreadyLinkedToDID(address alreadyLinkedAddress, string uDIDLinked)`
- `AddressDoesNotLinkedToDID(address notLinkedAddress)`
- `AddressDoesNotHaveLinker(address addressWithoutLinker)`
- `AddressAlreadyDeactivated(address alreadyDeactivatedAddress)`
- `AddressAlreadyActivated(address alreadyActivatedAddress)`
- `NotAuthorizedForThisTransaction(address caller)`
- `ValidToDataMustBeInFuture(uint256 existingDateTimestamp)`
- `DIDIsBlocked(string UDID)`
- `DIDIsNotBlocked(string UDID)`
- `MaxLinkedAddressesExceeded(string UDID, uint256 maxAllowed)`
- `AddressIsNotExternalReader(string UDID, address notReaderAddress)`

## Repository structure
```
/project-root
│
├── /src
│   ├── /interfaces
│   │   └── ISDID.sol
│   └── SDID.sol
│
├── /script
├── /test
│
├── remappings.txt
├── .env.example
└── foundry.toml
```

## License
This project is licensed under the **MIT License**.

