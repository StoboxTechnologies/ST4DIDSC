// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {AccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";

contract SDID is AccessControlEnumerable {
    struct Attribute {
        bytes32 value;
        string valueType; // STRING, UINT, BOOL, HASH, ADDRESS, INT, FLOAT
        uint256 createdAt;
        uint256 updatedAt;
        uint256 validTo; //=> may be zero(max uint)
        address updatedBy; //=> required
    }

    struct DID {
        string UUID; // unique number of DID from web2 data base
        uint256 validTo; // => ??? поки не знаємо що саме тут закладено
        uint256 updatedAt;
        bool blocked;
        address updatedBy;
        mapping(string => Attribute) attributes;
        string[] attributeList;
    }

    struct Linker {
        string UUID; // unique number of DID from web2 data base
        address[] linkedAddresses; // +address of userWallet => linker add this address => DID object in mapping by uID
    }

    //!!!!!!!!!!!!! TBD !!!!!!!!!!!!!! deactivate user address!!! or delete
    mapping(address => bool) deactivated; // maybe add UUID as nested mapping

    mapping(string UUID => DID) userDID;
    mapping(address => Linker) linker;

    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");
    bytes32 public constant ATTRIBUTE_READER_ROLE = keccak256("ATTRIBUTE_READER_ROLE");

    //!!!!!!!!!!!!! TBD !!!!!!!!!!!!!! indexed param is saved like hash
    event DIDCreated(string indexed UUID, address indexed createdBy);
    event DIDAddressesUpdated(string indexed UUID, address updatedBy);
    event DIDValidDataUpdated(
        string indexed UUID, uint256 oldValidTo, uint256 indexed newValidTo, address indexed updatedBy
    );
    event DIDBlockStatusUpdated(string indexed UUID, bool indexed blocked, address indexed updatedBy);

    error CantRevokeLastSuperAdmin();
    error DIDAlreadyExists();
    error DIDDoesNotExist();
    error ZeroAddressNotAllowed();
    error AddressAlredyLinkedToDID();
    error WrongDIDToUpdate();
    error NotAuthorizedForThisTransaction();
    error ValidToDataMustBeInFuture();
    error DIDIsAlreadyBlocked();
    error DIDIsNotBlocked();

    modifier dIDExsists(string calldata UUID) {
        require(userDID[UUID].updatedAt != 0, DIDDoesNotExist());
        _;
    }

    modifier canCreateDID(address addrToCheck) {
        require(addrToCheck != address(0), ZeroAddressNotAllowed());
        require(_empty(linker[addrToCheck].UUID), AddressAlredyLinkedToDID());
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createDID(string calldata uUID, address _userWallet, uint256 _validToDate, bool _blocked)
        external
        onlyRole(WRITER_ROLE)
        canCreateDID(_userWallet)
    {
        DID storage did = userDID[uUID];
        require(did.updatedAt == 0, DIDAlreadyExists());

        did.UUID = uUID;
        did.validTo = _validTo(_validToDate);
        did.blocked = _blocked;

        Linker storage link = linker[_userWallet];

        link.UUID = uUID;
        link.linkedAddresses.push(_userWallet);
        emit DIDAddressesUpdated(uUID, msg.sender);

        _updatedNow(did, msg.sender);

        emit DIDCreated(uUID, msg.sender);
    }

    function linkAddressToDID(string calldata uUID, address existingDIDAddress, address addressToLink)
        external
        dIDExsists(uUID)
        canCreateDID(addressToLink)
    {
        //!!!!!!!!!!!!! TBD !!!!!!!!!!!!!! user can???
        require(
            hasRole(WRITER_ROLE, msg.sender) || _equal(linker[msg.sender].UUID, uUID), NotAuthorizedForThisTransaction()
        );

        require(_equal(linker[existingDIDAddress].UUID, uUID), WrongDIDToUpdate());

        _linkAddressToDID(existingDIDAddress, addressToLink);
        _updatedNow(userDID[linker[addressToLink].UUID], msg.sender);
    }

    function blockDID(string calldata uUID) external dIDExsists(uUID) onlyRole(WRITER_ROLE) returns (bool) {
        DID storage did = userDID[uUID];

        require(!did.blocked, DIDIsAlreadyBlocked());
        did.blocked = true;

        emit DIDBlockStatusUpdated(uUID, did.blocked, msg.sender);
        _updatedNow(did, msg.sender);

        return true;
    }

    function unBlockDID(string calldata uUID) external dIDExsists(uUID) onlyRole(WRITER_ROLE) returns (bool) {
        DID storage did = userDID[uUID];

        require(did.blocked, DIDIsNotBlocked());
        did.blocked = false;

        emit DIDBlockStatusUpdated(uUID, did.blocked, msg.sender);
        _updatedNow(did, msg.sender);

        return true;
    }

    function updateDIDValidTo(string calldata uUID, uint256 newValidTo)
        external
        dIDExsists(uUID)
        onlyRole(WRITER_ROLE)
        returns (bool)
    {
        DID storage did = userDID[uUID];
        //!!!!!!!!!!!!! TBD !!!!!!!!!!!!!! if newValidTo = 0
        emit DIDValidDataUpdated(uUID, did.validTo, newValidTo, msg.sender);
        did.validTo = _validTo(newValidTo);

        _updatedNow(did, msg.sender);

        return true;
    }

    function _updatedNow(DID storage did, address updater) internal {
        did.updatedAt = block.timestamp;
        did.updatedBy = updater;
    }

    function _linkAddressToDID(address addrOld, address addrNew) internal {
        Linker storage link = linker[addrOld];

        link.linkedAddresses.push(addrNew);
        linker[addrNew].UUID = link.UUID;

        for (uint256 i = 0; i < link.linkedAddresses.length; i++) {
            if (link.linkedAddresses[i] != addrOld) {
                linker[link.linkedAddresses[i]] = link;
            }
        }
        emit DIDAddressesUpdated(link.UUID, msg.sender);
    }

    function _revokeRole(bytes32 role, address account) internal override returns (bool revoked) {
        if (role == DEFAULT_ADMIN_ROLE) {
            require(getRoleMemberCount(role) > 1, CantRevokeLastSuperAdmin());
        }
        revoked = super._revokeRole(role, account);
    }

    function _validTo(uint256 validTo) internal view returns (uint256 toSet) {
        //!!!!!!!!!!!!! TBD !!!!!!!!!!!!!! ValidToDataMustBeInFuture???
        require(validTo == 0 || validTo > block.timestamp, ValidToDataMustBeInFuture());
        toSet = validTo == 0 ? type(uint256).max : validTo;
    }

    function _empty(string storage str) internal view returns (bool) {
        return bytes(str).length == 0;
    }

    function _equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
