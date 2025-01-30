# SDID Smart Contract

## Overview
The **SDID** (Self-Sovereign Decentralized Identity) smart contract is an implementation of a decentralized identity (DID) system on the Ethereum blockchain. It enables users to create, manage, and interact with decentralized identities while providing mechanisms for attribute management, linked addresses, access control, and security.

## Features
- **Decentralized Identity (DID) Management**
  - Create, update, and manage DIDs.
  - Link multiple addresses to a DID.
  - Control access to DID attributes.
  
- **Attribute Management**
  - Add, update, and deactivate attributes for a DID.
  - Set expiration dates for attributes.

- **Access Control**
  - Define roles such as WRITER_ROLE and ATTRIBUTE_READER_ROLE.
  - Assign external readers with expiration-based access.

- **Security Features**
  - DID blocking and unblocking.
  - Role-based access management.
  - Limit the number of linked addresses per DID.

## Smart Contract Details
### Prerequisites
- Solidity version: `0.8.26`
- Uses OpenZeppelin's `AccessControlEnumerable` for role management.

### Roles
- **DEFAULT_ADMIN_ROLE**: Full administrative control over the contract.
- **WRITER_ROLE**: Can create and manage DIDs and attributes.
- **ATTRIBUTE_READER_ROLE**: Can read attributes of a DID.

## Key Structures
### `DID`
Represents a decentralized identity.
```solidity
struct DID {
    string UDID; // Unique identifier
    uint256 validTo; // Expiry timestamp
    uint256 updatedAt;
    bool blocked;
    address lastUpdatedBy;
    string[] attributeList;
    mapping(string => Attribute) attributes;
    mapping(address => uint256) externalReader; // Access control
}
```

### `Attribute`
Represents an attribute associated with a DID.
```solidity
struct Attribute {
    bytes32 value;
    string valueType;
    uint256 createdAt;
    uint256 updatedAt;
    uint256 validTo;
    address lastUpdatedBy;
}
```

### `Linker`
Manages address linking to a DID.
```solidity
struct Linker {
    string UDID;
    uint256 joinDate;
    uint256 updateDate;
    bool deactivated;
    address[] linkedAddresses;
}
```

## Events
The contract emits events for important actions, including:
- `DIDCreated`
- `DIDAddressLinked`
- `DIDAddressDeleted`
- `DIDAddressDeactivated`
- `DIDAddressActivated`
- `DIDBlockStatusUpdated`
- `AttributeCreated`
- `AttributeUpdated`
- `AttributeDeactivated`
- `NewExternalReaderAdded`
- `ExternalReaderDeleted`

## Functions
### DID Management
- `createDID(string calldata uDID, address _userWallet, uint256 _validToDate, bool _blocked)`: Creates a new DID.
- `linkAddressToDID(address existingDIDAddress, address addressToLink)`: Links an address to an existing DID.
- `blockDID(string memory uDID, string calldata reasonToBlock)`: Blocks a DID.
- `unBlockDID(string memory uDID, string calldata reasonToUnblock)`: Unblocks a DID.

### Attribute Management
- `addOrUpdateAttributes(...)`: Adds or updates an attribute.
- `deactivateDIDAttribute(string memory uDID, string calldata attributeName)`: Deactivates an attribute.

### Access Control
- `addOrUpdateExternalReader(...)`: Grants external read access.
- `deleteExternalReader(...)`: Revokes external read access.

### Utility Functions
- `prolongateDID(...)`: Extends the validity of a DID.
- `readAttributeList(...)`: Reads the attribute list of a DID.
- `getUserDID(...)`: Retrieves DID details.
- `getAttribute(...)`: Fetches an attribute of a DID.

## Error Handling
The contract includes custom errors for validation and security:
- `DIDAlreadyExists(string UDID)`
- `DIDDoesNotExist(string UDID)`
- `ZeroAddressNotAllowed()`
- `AddressAlreadyLinkedToDID(address, string)`
- `NotAuthorizedForThisTransaction(address caller)`
- `DIDIsBlocked(string UDID)`
- `DIDIsNotBlocked(string UDID)`
- `MaxLinkedAddressesExceeded(string UDID, uint256 maxAllowed)`
- `AddressIsNotExternalReader(string UDID, address)`

## Deployment & Configuration
1. Deploy the contract on an Ethereum-compatible blockchain.
2. Assign `DEFAULT_ADMIN_ROLE` to the deploying address.
3. Grant `WRITER_ROLE` to authorized entities.
4. Configure `MAX_DID_LINKED_ADDRESSES` as required.

## Security Considerations
- Ensure WRITER_ROLE is only granted to trusted entities.
- Regularly audit access roles and external readers.
- Be cautious when blocking/unblocking DIDs, as it may affect user operations.

## License
This project is licensed under the **MIT License**.

