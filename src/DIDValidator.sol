// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface DIDProrotype {
    struct Attrs {
        string attrName;
        bytes32 attrHash;
    }

    function getUserDID(address wallet)
        external
        view
        returns (address, string memory, uint256, uint256, bool, Attrs[] memory);

    function getHashedAttribute(address wallet, string calldata attributeName) external view returns (bytes32);
}

contract DIDValidator is Ownable {
    DIDProrotype DID;

    string[] private attributesMustHave; // "InvestorType", "Country" ...
    mapping(string => bytes4) attributeAction; // function which will make validation of the specific attribute

    string[] private allowedCountries;

    event AttributesMustHaveUpdated(string action, string attributeName);

    error AttributeAlreadyExists(string attr);
    error UserDIDNotValid();
    error AttributeNotValid(string attribute);

    constructor(address didAddress, string[] memory _allowedCountries) Ownable(msg.sender) {
        DID = DIDProrotype(didAddress);
        allowedCountries = _allowedCountries;
    }

    function validateUser(address user) external {
        _validDID(user);
        _checkUserAttributes(user);
    }

    function addAttribute(string memory newAttr, bytes4 actionSelector) external onlyOwner {
        require(!_existsInMustHave(newAttr), AttributeAlreadyExists(newAttr));

        attributesMustHave.push(newAttr);
        attributeAction[newAttr] = actionSelector;

        emit AttributesMustHaveUpdated("Added", newAttr);
    }

    function deleteAttribute(string memory delAttr) external onlyOwner {
        string[] memory attrList = attributesMustHave;
        uint256 len = attributesMustHave.length;
        for (uint256 i = 0; i < len; i++) {
            if (_ifEqual(delAttr, attrList[i])) {
                delete attributeAction[delAttr];

                attributesMustHave[i] = attributesMustHave[len - 1];
                attributesMustHave.pop();
                break;
            }
        }
        emit AttributesMustHaveUpdated("Removed", delAttr);
    }

    function resetAllAttributes() external onlyOwner {
        uint256 len = attributesMustHave.length;
        for (uint256 i = 0; i < len; i++) {
            emit AttributesMustHaveUpdated("Removed", attributesMustHave[i]);

            delete attributeAction[attributesMustHave[i]];
            attributesMustHave[i] = attributesMustHave[attributesMustHave.length - 1];
            attributesMustHave.pop();
        }
    }

    function getAttributesMustHave() external view returns (string[] memory) {
        return attributesMustHave;
    }

    function getAllowedCountries() external view returns (string[] memory) {
        return allowedCountries;
    }

    function checkCountry(address user, bytes32 userAttributeHash) external view {
        string[] memory countryList = allowedCountries;
        uint256 counter = 0;
        for (uint256 i = 0; i < countryList.length; i++) {
            if (_getHash(user, countryList[i]) == userAttributeHash) {
                counter++;
                break;
            }
        }

        require(counter > 0, AttributeNotValid("Country"));
    }

    function checkInvestorType(address user, bytes32 userAttributeHash) external pure {
        require(userAttributeHash != bytes32(0), AttributeNotValid("InvestorType"));
    }

    function _checkUserAttributes(address user) internal returns (bool success) {
        for (uint256 i = 0; i < attributesMustHave.length; i++) {
            (success,) = address(this).call(
                abi.encodeWithSelector(
                    attributeAction[attributesMustHave[i]], user, DID.getHashedAttribute(user, attributesMustHave[i])
                )
            );
            require(success, AttributeNotValid(attributesMustHave[i]));
        }
    }

    function _validDID(address user) internal view {
        (,, uint256 validTo,, bool blocked,) = DID.getUserDID(user);
        require(validTo > block.timestamp && !blocked, UserDIDNotValid());
    }

    function _existsInMustHave(string memory element) internal view returns (bool inGlobal) {
        string[] memory attrList = attributesMustHave;
        for (uint256 i = 0; i < attrList.length; i++) {
            if (_ifEqual(element, attrList[i])) {
                inGlobal = true;
                break;
            }
        }
    }

    function _getHash(address wallet, string memory attrName) internal pure returns (bytes32 result) {
        result = keccak256(abi.encodePacked(wallet, attrName));
    }

    function _ifEqual(string memory str1, string memory str2) internal pure returns (bool isEqual) {
        isEqual = keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }
}
