// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {AccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import {ISDID} from "src/interfaces/ISDID.sol";

contract StoboxDID is ISDID, AccessControlEnumerable {
    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");
    bytes32 public constant ATTRIBUTE_READER_ROLE = keccak256("ATTRIBUTE_READER_ROLE");

    uint256 public MAX_DID_LINKED_ADDRESSES = 10;

    mapping(string UDID => DID) userDID;
    mapping(address => Linker) linker;

    modifier hasDID(address addrToCheck) {
        require(!_empty(linker[addrToCheck].UDID), AddressDoesNotLinkedToDID(addrToCheck));
        _;
    }

    modifier didExsists(string memory UDID) {
        require(userDID[UDID].updatedAt != 0, DIDDoesNotExist(UDID));
        _;
    }

    modifier canLinkToDID(address addrToLink) {
        require(addrToLink != address(0), ZeroAddressNotAllowed());
        require(_empty(linker[addrToLink].UDID), AddressAlreadyLinkedToDID(addrToLink, linker[addrToLink].UDID));
        _;
    }

    modifier writerOrDIDOwner(address referenceDIDAddress) {
        require(
            hasRole(WRITER_ROLE, msg.sender)
                || (_equal(linker[referenceDIDAddress].UDID, linker[msg.sender].UDID) && !linker[msg.sender].deactivated),
            NotAuthorizedForThisTransaction(msg.sender)
        );
        _;
    }

    modifier authorizedReader(string memory uDID) {
        require(canRead(uDID, msg.sender), NotAuthorizedForThisTransaction(msg.sender));
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createDID(string calldata uDID, address _userWallet, uint256 _validToDate, bool _blocked)
        external
        onlyRole(WRITER_ROLE)
        canLinkToDID(_userWallet)
    {
        DID storage did = userDID[uDID];
        require(did.updatedAt == 0, DIDAlreadyExists(uDID));

        did.UDID = uDID;
        did.validTo = _validTo(_validToDate);
        did.updatedAt = block.timestamp;
        did.blocked = _blocked;
        did.lastUpdatedBy = msg.sender;

        emit DIDCreated(uDID, uDID, msg.sender);

        Linker storage link = linker[_userWallet];

        link.UDID = uDID;
        link.joinDate = block.timestamp;
        link.updateDate = block.timestamp;
        link.linkedAddresses.push(_userWallet);

        emit DIDAddressLinked(uDID, uDID, _userWallet, msg.sender);
    }

    function linkAddressToDID(address existingDIDAddress, address addressToLink)
        external
        hasDID(existingDIDAddress)
        canLinkToDID(addressToLink)
        writerOrDIDOwner(existingDIDAddress)
    {
        uint256 len = linker[existingDIDAddress].linkedAddresses.length;
        require(
            len < MAX_DID_LINKED_ADDRESSES,
            MaxLinkedAddressesExceeded(linker[existingDIDAddress].UDID, MAX_DID_LINKED_ADDRESSES)
        );

        Linker storage newLink = linker[addressToLink];

        newLink.UDID = linker[existingDIDAddress].UDID;
        newLink.joinDate = block.timestamp;
        newLink.updateDate = block.timestamp;
        newLink.linkedAddresses.push(addressToLink);

        for (uint256 i = 0; i < len; i++) {
            address la = linker[existingDIDAddress].linkedAddresses[i];

            newLink.linkedAddresses.push(la);

            linker[la].updateDate = block.timestamp;
            linker[la].linkedAddresses.push(addressToLink);
        }

        emit DIDAddressLinked(newLink.UDID, newLink.UDID, addressToLink, msg.sender);

        _didUpdatedNow(userDID[newLink.UDID], msg.sender);
    }

    function addOrUpdateAttributes(ParamAttribute[] memory attributesToAdd) external onlyRole(WRITER_ROLE) {
        for (uint256 i = 0; i < attributesToAdd.length; i++) {
            ParamAttribute memory attr = attributesToAdd[i];
            _addOrUpdateAttributes(
                linker[attr.walletAddress].UDID, attr.attributeName, attr.value, attr.valueType, attr.validToData
            );
        }
    }

    function addOrUpdateAttributes(bytes[] memory attributesToAdd) external onlyRole(WRITER_ROLE) {
        for (uint256 i = 0; i < attributesToAdd.length; i++) {
            (
                address walletAddress_,
                string memory attributeName_,
                bytes memory value_,
                string memory valueType_,
                uint256 validToData_
            ) = abi.decode(attributesToAdd[i], (address, string, bytes, string, uint256));
            _addOrUpdateAttributes(linker[walletAddress_].UDID, attributeName_, value_, valueType_, validToData_);
        }
    }

    function addOrUpdateExternalReader(string memory uDID, address addressToAddOrUpd, uint256 expirationDate)
        external
        didExsists(uDID)
        onlyRole(WRITER_ROLE)
        returns (bool)
    {
        return _addOrUpdExternalReader(uDID, addressToAddOrUpd, expirationDate);
    }

    function addOrUpdateExternalReader(address addressToAddOrUpd, uint256 expirationDate) external returns (bool) {
        Linker memory link = linker[msg.sender];
        return _addOrUpdExternalReader(link.UDID, addressToAddOrUpd, expirationDate);
    }

    function deleteExternalReader(string memory uDID, address addressToDelete)
        external
        didExsists(uDID)
        onlyRole(WRITER_ROLE)
        returns (bool)
    {
        return _deleteExternalReader(uDID, addressToDelete);
    }

    function deleteExternalReader(address addressToDelete) external returns (bool) {
        Linker memory link = linker[msg.sender];

        return _deleteExternalReader(link.UDID, addressToDelete);
    }

    function prolongateDID(string memory uDID, uint256 newValidTo)
        external
        didExsists(uDID)
        onlyRole(WRITER_ROLE)
        returns (uint256)
    {
        DID storage did = userDID[uDID];
        emit DIDValidToDateUpdated(uDID, uDID, did.validTo, newValidTo, msg.sender);
        did.validTo = _validTo(newValidTo);

        _didUpdatedNow(did, msg.sender);

        return did.validTo;
    }

    function blockDID(string memory uDID, string calldata reasonToBlock)
        external
        didExsists(uDID)
        onlyRole(WRITER_ROLE)
        returns (bool)
    {
        DID storage did = userDID[uDID];

        require(!did.blocked, DIDIsBlocked(uDID));
        did.blocked = true;

        emit DIDBlockStatusUpdated(uDID, uDID, did.blocked, msg.sender, reasonToBlock);
        _didUpdatedNow(did, msg.sender);

        return true;
    }

    function unBlockDID(string memory uDID, string calldata reasonToUnblock)
        external
        didExsists(uDID)
        onlyRole(WRITER_ROLE)
        returns (bool)
    {
        DID storage did = userDID[uDID];

        require(did.blocked, DIDIsNotBlocked(uDID));
        did.blocked = false;

        emit DIDBlockStatusUpdated(uDID, uDID, did.blocked, msg.sender, reasonToUnblock);
        _didUpdatedNow(did, msg.sender);

        return true;
    }

    function removeLinkedAddress(address addressToDelete)
        external
        hasDID(addressToDelete)
        onlyRole(WRITER_ROLE)
        returns (bool)
    {
        Linker memory targetLinker = linker[addressToDelete];
        string memory did = targetLinker.UDID;

        uint256 len = targetLinker.linkedAddresses.length;
        require(len > 1, CantRemoveLastLinkedAddress());

        for (uint256 i = 0; i < len; i++) {
            address la = targetLinker.linkedAddresses[i];
            Linker storage link = linker[la];
            if (!_removeAddressFromLinkedAddresses(addressToDelete, link.linkedAddresses)) {
                emit UnexpectedBehavior(
                    did,
                    did,
                    addressToDelete,
                    "Address was not found in Linker of address",
                    targetLinker.linkedAddresses[i]
                );
            }
        }

        emit DIDAddressDeleted(did, did, addressToDelete, msg.sender);
        _didUpdatedNow(userDID[did], msg.sender);

        delete linker[addressToDelete];
        return true;
    }

    function deactivateDIDAttribute(string memory uDID, string calldata attributeName)
        external
        didExsists(uDID)
        onlyRole(WRITER_ROLE)
    {
        userDID[uDID].attributes[attributeName].validTo = 0;
        emit AttributeDeactivated(uDID, uDID, attributeName, msg.sender);

        _didUpdatedNow(userDID[uDID], msg.sender);
    }

    function deactivateAddressOfDID(address addressToDeactivate)
        external
        hasDID(addressToDeactivate)
        writerOrDIDOwner(addressToDeactivate)
        returns (bool)
    {
        Linker storage link = linker[addressToDeactivate];

        require(!link.deactivated, AddressAlreadyDeactivated(addressToDeactivate));

        link.deactivated = true;
        link.updateDate = block.timestamp;

        emit DIDAddressDeactivated(link.UDID, link.UDID, addressToDeactivate, msg.sender);

        _didUpdatedNow(userDID[link.UDID], msg.sender);
        return true;
    }

    function activateAddressOfDID(address addressToActivate)
        external
        hasDID(addressToActivate)
        writerOrDIDOwner(addressToActivate)
        returns (bool)
    {
        Linker storage link = linker[addressToActivate];

        require(link.deactivated, AddressAlreadyActivated(addressToActivate));

        link.deactivated = false;
        link.updateDate = block.timestamp;

        emit DIDAddressActivated(link.UDID, link.UDID, addressToActivate, msg.sender);

        _didUpdatedNow(userDID[link.UDID], msg.sender);
        return true;
    }

    function setMaxDIDLinkedAddresses(uint256 newMaxAllowed) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
        MAX_DID_LINKED_ADDRESSES = newMaxAllowed;
        return MAX_DID_LINKED_ADDRESSES;
    }

    function readAttributeList(address walletAddress)
        external
        hasDID(walletAddress)
        authorizedReader(linker[walletAddress].UDID)
        returns (string[] memory)
    {
        emit AttributeListWasRead(linker[walletAddress].UDID, linker[walletAddress].UDID, msg.sender);
        return userDID[linker[walletAddress].UDID].attributeList;
    }

    function readLinkedAddresses(address walletAddress)
        external
        hasDID(walletAddress)
        authorizedReader(linker[walletAddress].UDID)
        returns (address[] memory)
    {
        emit LinkedAddressesListWasRead(linker[walletAddress].UDID, linker[walletAddress].UDID, msg.sender);
        return linker[walletAddress].linkedAddresses;
    }

    function readFullDID(address didOwnerAddress)
        external
        hasDID(didOwnerAddress)
        authorizedReader(linker[didOwnerAddress].UDID)
        returns (
            string memory uDID,
            uint256 validTo,
            uint256 updatedAt,
            bool blocked,
            address lastUpdatedBy,
            address[] memory linkedDIDAddresses,
            Linker[] memory linkedDIDAddressesParams,
            string[] memory attributeList,
            Attribute[] memory attributesParams
        )
    {
        Linker memory link = linker[didOwnerAddress];
        DID storage did = userDID[link.UDID];

        uDID = link.UDID;
        validTo = did.validTo;
        updatedAt = did.updatedAt;
        blocked = did.blocked;
        lastUpdatedBy = did.lastUpdatedBy;
        linkedDIDAddresses = link.linkedAddresses;
        attributeList = did.attributeList;

        linkedDIDAddressesParams = new Linker[](linkedDIDAddresses.length);

        for (uint256 i = 0; i < linkedDIDAddresses.length; i++) {
            (string memory uDID_, uint256 joinDate_, uint256 updateDate_, bool deactivated_) =
                getLinker(linkedDIDAddresses[i]);

            linkedDIDAddressesParams[i] =
                Linker(uDID_, joinDate_, updateDate_, deactivated_, linker[linkedDIDAddresses[i]].linkedAddresses);
        }

        attributesParams = new Attribute[](did.attributeList.length);

        for (uint256 j = 0; j < attributeList.length; j++) {
            (
                bytes memory value_,
                string memory valueType_,
                uint256 createdAt_,
                uint256 updatedAt_,
                uint256 validTo_,
                address lastUpdatedBy_
            ) = getAttribute(didOwnerAddress, attributeList[j]);

            attributesParams[j] = Attribute(value_, valueType_, createdAt_, updatedAt_, validTo_, lastUpdatedBy_);
        }

        emit FullDIDWasRead(uDID, uDID, msg.sender);
    }

    function getUserDID(address walletAddress)
        public
        view
        hasDID(walletAddress)
        returns (string memory UDID, uint256 validTo, uint256 updatedAt, bool blocked, address lastUpdatedBy)
    {
        DID storage did = userDID[linker[walletAddress].UDID];

        UDID = did.UDID;
        validTo = did.validTo;
        updatedAt = did.updatedAt;
        blocked = did.blocked;
        lastUpdatedBy = did.lastUpdatedBy;
    }

    function getAttribute(address walletAddress, string memory attributeName)
        public
        view
        hasDID(walletAddress)
        returns (
            bytes memory value,
            string memory valueType,
            uint256 createdAt,
            uint256 updatedAt,
            uint256 validTo,
            address lastUpdatedBy
        )
    {
        Attribute memory attr = userDID[linker[walletAddress].UDID].attributes[attributeName];

        value = attr.value;
        valueType = attr.valueType;
        createdAt = attr.createdAt;
        updatedAt = attr.updatedAt;
        validTo = attr.validTo;
        lastUpdatedBy = attr.lastUpdatedBy;
    }

    function getLinker(address walletAddress)
        public
        view
        returns (string memory uDID, uint256 joinDate, uint256 updateDate, bool deactivated)
    {
        require(linker[walletAddress].joinDate != 0, AddressDoesNotHaveLinker(walletAddress));
        Linker memory link = linker[walletAddress];

        uDID = link.UDID;
        joinDate = link.joinDate;
        updateDate = link.updateDate;
        deactivated = link.deactivated;
    }

    function canRead(string memory uDIDToRead, address addressCanRead) public view returns (bool) {
        return hasRole(ATTRIBUTE_READER_ROLE, addressCanRead)
            || externalReaderExpirationDate(uDIDToRead, addressCanRead) > block.timestamp;
    }

    function externalReaderExpirationDate(string memory uDID, address walletAddress) public view returns (uint256) {
        return userDID[uDID].externalReader[walletAddress];
    }

    function _didUpdatedNow(DID storage did, address updater) internal {
        did.updatedAt = block.timestamp;
        did.lastUpdatedBy = updater;
    }

    function _addOrUpdateAttributes(
        string memory uDID,
        string memory attributeName,
        bytes memory _value,
        string memory _valueType,
        uint256 _validToData // if set zero - attribute does not expire (max.uint will be set by smart contract). Value "0" can be set ONLY by deactivateDIDAttribute()
    ) internal didExsists(uDID) {
        Attribute storage attr = userDID[uDID].attributes[attributeName];

        if (attr.createdAt == 0) {
            attr.value = _value;
            attr.valueType = _valueType;
            attr.createdAt = block.timestamp;
            attr.updatedAt = block.timestamp;
            attr.validTo = _validTo(_validToData);
            attr.lastUpdatedBy = msg.sender;

            userDID[uDID].attributeList.push(attributeName);

            emit AttributeCreated(uDID, uDID, attributeName, msg.sender);
        } else {
            attr.value = _value;
            attr.valueType = _valueType;
            attr.updatedAt = block.timestamp;
            attr.validTo = _validTo(_validToData);
            attr.lastUpdatedBy = msg.sender;

            emit AttributeUpdated(uDID, uDID, attributeName, msg.sender);
        }

        _didUpdatedNow(userDID[uDID], msg.sender);
    }

    function _addOrUpdExternalReader(string memory uDID, address addressToAddOrUpd, uint256 expirationDate)
        internal
        returns (bool)
    {
        require(addressToAddOrUpd != address(0), ZeroAddressNotAllowed());

        if (externalReaderExpirationDate(uDID, addressToAddOrUpd) == 0) {
            emit NewExternalReaderAdded(uDID, uDID, addressToAddOrUpd, expirationDate, msg.sender);
        } else {
            emit ExternalReaderUdated(uDID, uDID, addressToAddOrUpd, expirationDate, msg.sender);
        }

        userDID[uDID].externalReader[addressToAddOrUpd] = _validTo(expirationDate);

        _didUpdatedNow(userDID[uDID], msg.sender);
        return true;
    }

    function _deleteExternalReader(string memory uDID, address addressToDelete) internal returns (bool) {
        require(
            externalReaderExpirationDate(uDID, addressToDelete) != 0, AddressIsNotExternalReader(uDID, addressToDelete)
        );

        delete userDID[uDID].externalReader[addressToDelete];
        emit ExternalReaderDeleted(uDID, uDID, addressToDelete, msg.sender);

        _didUpdatedNow(userDID[uDID], msg.sender);
        return true;
    }

    function _removeAddressFromLinkedAddresses(address target, address[] storage addresses) internal returns (bool) {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] == target) {
                addresses[i] = addresses[addresses.length - 1];
                addresses.pop();
                return true;
            }
        }
        return false;
    }

    function _revokeRole(bytes32 role, address account) internal override returns (bool revoked) {
        if (role == DEFAULT_ADMIN_ROLE) {
            require(getRoleMemberCount(role) > 1, CantRevokeLastSuperAdmin());
        }
        revoked = super._revokeRole(role, account);
    }

    function _validTo(uint256 validTo) internal pure returns (uint256 toSet) {
        toSet = validTo == 0 ? type(uint256).max : validTo;
    }

    function _equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function _empty(string storage str) internal view returns (bool) {
        return bytes(str).length == 0;
    }
}
