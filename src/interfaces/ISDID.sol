// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISDID {
    struct Attribute {
        bytes32 value;
        string valueType; // STRING, UINT, BOOL, HASH, ADDRESS, INT, FLOAT
        uint256 createdAt;
        uint256 updatedAt;
        uint256 validTo; //=> may be zero(max uint)
        address lastUpdatedBy; //=> required
    }

    //TBD what functionality is prohibited when DID is BLOCKED. Maybe its better to update to have the proper info when unblock?
    // - linkAddressToDID(writerOrDIDOwner) - YES
    // - removeLinkedAddress(writer) - ???
    // - deactivateAddressOfDID(writerOrDIDOwner) - ???
    // - activateAddressOfDID(writerOrDIDOwner) - ???
    // - addOrUpdateAttributes(writer) -???
    // - deactivateDIDAttribute(writer) - ???
    // - prolongateDID(writer) - ???
    // -
    struct DID {
        string UDID; // unique number of DID from web2 data base
        uint256 validTo; // => ??? поки не знаємо що саме тут закладено
        uint256 updatedAt;
        bool blocked;
        address lastUpdatedBy;
        string[] attributeList;
        mapping(string => Attribute) attributes;
        mapping(address => uint256 expirationData) externalReader; // can be blocked by set expirationData to zero!!! (or now.timestamp)
    }

    struct Linker {
        string UDID; // unique number of DID from web2 data base
        uint256 joinDate; // function join() only once
        uint256 updateDate; // on addToLinkredAddress & on deactivate => after deactivate join is NOT restricted
        bool deactivated; // default false
        address[] linkedAddresses; // +address of userWallet => linker add this address => DID object in mapping by uID
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

    error CantRevokeLastSuperAdmin();
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
