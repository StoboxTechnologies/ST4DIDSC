// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DIDPrototype is Ownable {
    struct DID {
        address userWallet;
        uint256 validTo;
        uint256 updatedAt;
        bool blocked;
        mapping(string => bytes32) hashedAttributes;
    }

    mapping(address => DID) userDID;
    string[] globalAttributeList;

    event UserBlocked(address user, uint256 blockedAtTimestamp);
    event UserUnblocked(address user, uint256 blockedAtTimestamp);
    event UserDIDUpdated(address user, string descriptionOfChanges);
    event UserDIDUpdated(address user, string descriptionOfChanges, string data);
    event UserDIDUpdated(address user, string descriptionOfChanges, uint256 paramChanged);
    event UserDIDUpdated(address user, string descriptionOfChanges, string[] paramChanged);
    event GlobalAttributeListUpdated(string action, string attributeName);

    error AttributeAlreadyExists(string attr);
    error UserDoesntHaveDID(address user);
    error ArraysAreNotEqual();
    error UserIsBlocked(address user);
    error UserIsNotBlocked(address user);

    modifier ifUserExist(address user) {
        require(userDID[user].userWallet == user, UserDoesntHaveDID(user));
        _;
    }

    modifier updatedNow(address user) {
        _;
        userDID[user].updatedAt = block.timestamp;
    }

    constructor() Ownable(msg.sender) {}

    function updateOrCreateDID(address _userWallet, uint256 _validTo, bool _blocked)
        external
        onlyOwner
        updatedNow(_userWallet)
    {
        if (userDID[_userWallet].userWallet == address(0)) {
            DID storage did = userDID[_userWallet];

            did.userWallet = _userWallet;
            did.validTo = _validTo;
            did.blocked = _blocked;

            emit UserDIDUpdated(_userWallet, "DID created");
        } else {
            _updateDID(_userWallet, _validTo, _blocked);
        }
    }

    function updateOrAddDIDAttributeHashes(address wallet, string[] calldata names, bytes32[] calldata hashedAttrs)
        external
        ifUserExist(wallet)
        updatedNow(wallet)
        onlyOwner
    {
        require(names.length == hashedAttrs.length, ArraysAreNotEqual());

        for (uint256 i = 0; i < names.length; i++) {
            userDID[wallet].hashedAttributes[names[i]] = hashedAttrs[i];
        }

        emit UserDIDUpdated(wallet, "HashAttributes added to DID", names);
    }

    function deleteUserAttribute(address wallet, string calldata delAttribute)
        external
        ifUserExist(wallet)
        updatedNow(wallet)
        onlyOwner
    {
        delete userDID[wallet].hashedAttributes[delAttribute];

        emit UserDIDUpdated(wallet, "Attribute hash deleted", delAttribute);
    }

    function blockUser(address wallet) external ifUserExist(wallet) updatedNow(wallet) onlyOwner {
        require(!_ifUserBlocked(wallet), UserIsBlocked(wallet));
        userDID[wallet].blocked = true;

        emit UserBlocked(wallet, block.timestamp);
    }

    function unblockUser(address wallet) external ifUserExist(wallet) updatedNow(wallet) onlyOwner {
        require(_ifUserBlocked(wallet), UserIsNotBlocked(wallet));
        userDID[wallet].blocked = false;

        emit UserUnblocked(wallet, block.timestamp);
    }

    function setUserValidTo(address wallet, uint256 newValidTo)
        external
        ifUserExist(wallet)
        updatedNow(wallet)
        onlyOwner
    {
        userDID[wallet].validTo = newValidTo;

        emit UserDIDUpdated(wallet, "Data valid to updated", newValidTo);
    }

    function addGlobalAttribute(string memory newAttr) external onlyOwner {
        require(!_existsInGlobal(newAttr), AttributeAlreadyExists(newAttr));

        globalAttributeList.push(newAttr);

        emit GlobalAttributeListUpdated("Added", newAttr);
    }

    function deleteGlobalAttribute(string memory delAttr) external onlyOwner {
        string[] memory attrList = globalAttributeList;
        uint256 len = globalAttributeList.length;
        for (uint256 i = 0; i < len; i++) {
            if (_ifEqual(delAttr, attrList[i])) {
                globalAttributeList[i] = globalAttributeList[len - 1];
                globalAttributeList.pop();
                break;
            }
        }
        emit GlobalAttributeListUpdated("Removed", delAttr);
    }

    function getGlobalAttributes() external view returns (string[] memory) {
        return globalAttributeList;
    }

    function getUserDID(address wallet) external view ifUserExist(wallet) returns (address, uint256, uint256, bool) {
        return (userDID[wallet].userWallet, userDID[wallet].validTo, userDID[wallet].updatedAt, userDID[wallet].blocked);
    }

    function getHashedAttribute(address user, string calldata attributeName)
        external
        view
        ifUserExist(user)
        returns (bytes32)
    {
        return userDID[user].hashedAttributes[attributeName];
    }

    function _updateDID(address _userWallet, uint256 _validTo, bool _blocked) internal {
        userDID[_userWallet].userWallet = _userWallet;
        userDID[_userWallet].validTo = _validTo;
        userDID[_userWallet].updatedAt = block.timestamp;
        userDID[_userWallet].blocked = _blocked;

        emit UserDIDUpdated(_userWallet, "DID all parameters updated");
    }

    function _existsInGlobal(string memory element) internal view returns (bool inGlobal) {
        string[] memory attrList = globalAttributeList;
        for (uint256 i = 0; i < attrList.length; i++) {
            if (_ifEqual(element, attrList[i])) {
                inGlobal = true;
                break;
            }
        }
    }

    function _ifUserBlocked(address wallet) internal view returns (bool) {
        return userDID[wallet].blocked;
    }

    function _ifEqual(string memory str1, string memory str2) internal pure returns (bool isEqual) {
        isEqual = keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }
}
