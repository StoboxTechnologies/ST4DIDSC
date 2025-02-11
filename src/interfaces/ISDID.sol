// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISDID {
    struct Attribute {
        bytes32 value;
        string valueType;
        uint256 createdAt;
        uint256 updatedAt;
        uint256 validTo;
        address lastUpdatedBy;
    }

    struct DID {
        string UDID; // Unique Decentralised ID
        uint256 validTo;
        uint256 updatedAt;
        bool blocked;
        address lastUpdatedBy;
        string[] attributeList;
        mapping(string => Attribute) attributes;
        mapping(address => uint256 expirationData) externalReader;
    }

    struct Linker {
        string UDID; // Unique Decentralised ID
        uint256 joinDate;
        uint256 updateDate;
        bool deactivated;
        address[] linkedAddresses;
    }

    struct ParamAttribute {
        string uDID;
        string attributeName;
        bytes32 value;
        string valueType;
        uint256 validToData;
    }

    struct ParamLinker {
        uint256 joinDate;
        uint256 updateDate;
        bool deactivated;
    }

    struct ParamFullDID {
        string uDID;
        uint256 validTo;
        uint256 updatedAt;
        bool blocked;
        address lastUpdatedBy;
        address[] linkedDIDAddresses;
        ParamLinker[] linkedDIDAddressesInfo;
        string[] attributeList;
        Attribute[] fullAttributeData;
    }

    event DIDCreated(string indexed UDID, string UDID_, address indexed createdBy);
    event DIDAddressLinked(string indexed UDID, string UDID_, address indexed addedAddress, address indexed updatedBy);
    event DIDAddressDeleted(
        string indexed UDID, string UDID_, address indexed deletedAddress, address indexed updatedBy
    );
    event DIDAddressDeactivated(
        string indexed UDID, string UDID_, address indexed deactivatedAddress, address indexed updatedBy
    );
    event DIDAddressActivated(
        string indexed UDID, string UDID_, address indexed activatedAddress, address indexed updatedBy
    );
    event DIDValidToDateUpdated(
        string indexed UDID, string UDID_, uint256 oldValidTo, uint256 indexed newValidTo, address indexed updatedBy
    );
    event AttributeValidToDateUpdated(
        string indexed UDID,
        string UDID_,
        string indexed attributeName,
        uint256 oldValidTo,
        uint256 newValidTo,
        address indexed updatedBy
    );
    event DIDBlockStatusUpdated(
        string indexed UDID,
        string UDID_,
        bool indexed newBlockStatus,
        address indexed updatedBy,
        string reasonDescription
    );

    event AttributeCreated(string indexed UDID, string UDID_, string indexed attributeName, address indexed createdBy);
    event AttributeUpdated(string indexed UDID, string UDID_, string indexed attributeName, address indexed updatedBy);
    event AttributeDeactivated(
        string indexed UDID, string UDID_, string indexed attributeName, address indexed deactivatedBy
    );
    event UnexpectedBehavior(
        string indexed UDID,
        string UDID_,
        address indexed addressToDelete,
        string message,
        address indexed addressOfBrokenLinker
    );
    event NewExternalReaderAdded(
        string indexed UDID,
        string UDID_,
        address indexed newExternalReader,
        uint256 accessExpirationDate,
        address indexed addedBy
    );
    event ExternalReaderUdated(
        string indexed UDID,
        string UDID_,
        address indexed newExternalReader,
        uint256 accessExpirationDate,
        address indexed updatedBy
    );
    event ExternalReaderDeleted(
        string indexed UDID, string UDID_, address indexed deletedExternalReader, address indexed updatedBy
    );

    event AttributeListWasRead(string indexed UDID, string UDID_, address whoRead);
    event LinkedAddressesListWasRead(string indexed UDID, string UDID_, address whoRead);
    event FullDIDWasRead(string indexed UDID, string UDID_, address whoRead);

    error CantRevokeLastSuperAdmin();
    error CantRemoveLastLinkedAddress();
    error DIDAlreadyExists(string UDID);
    error DIDDoesNotExist(string UDID);
    error ZeroAddressNotAllowed();
    error AddressAlreadyLinkedToDID(address alreadyLinkedAddress, string uDIDLinked);
    error AddressDoesNotLinkedToDID(address notLinkedAddress);
    error AddressDoesNotHaveLinker(address addressWithoutLinker);
    error AddressAlreadyDeactivated(address alreadyDeactivatedAddress);
    error AddressAlreadyActivated(address alreadyActivatedAddress);
    error NotAuthorizedForThisTransaction(address caller);
    error ValidToDataMustBeInFuture(uint256 existingDateTimestamp);
    error DIDIsBlocked(string UDID);
    error DIDIsNotBlocked(string UDID);
    error MaxLinkedAddressesExceeded(string UDID, uint256 maxAllowed);
    error AddressIsNotExternalReader(string UDID, address notReaderAddress);
}
