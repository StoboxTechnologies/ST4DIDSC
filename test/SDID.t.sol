// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Test} from "forge-std/Test.sol";
import {StoboxDID} from "src/StoboxDID.sol";
import {ISDID} from "src/interfaces/ISDID.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

// forge coverage --ir-minimum

contract SDIDTest is Test {
    StoboxDID did;

    address FOUNDRY_DEPLOYER = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
    //address FOUNDRY_DEPLOYER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    bytes32 DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 WRITER_ROLE = keccak256("WRITER_ROLE");
    bytes32 ATTRIBUTE_READER_ROLE = keccak256("ATTRIBUTE_READER_ROLE");

    string DEFAULT_DID = "DEFAULT_DID";
    uint256 ZERO_UINT = 0;
    address ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    address DEFAULT_USER = makeAddr("DEFAULT_USER");
    uint256 DEFAULT_TIMESTAMP = 1903185605; //Tue Apr 23 2030 14:40:05 GMT+0000

    ISDID.ParamAttribute DEFAULT_ATTRIBUTE = ISDID.ParamAttribute({
        walletAddress: DEFAULT_USER,
        attributeName: "FIRST_ATTRIBUTE",
        value: "0x0",
        valueType: "STRING",
        validToData: ZERO_UINT
    });

    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    function beforeTestSetup(bytes4 testSelector) public pure returns (bytes[] memory beforeTestCalldata) {
        if (testSelector == this.test_RevertCreateDIDIf_AddressAlreadyHasDID.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_RevertCreateDIDIf_DIDAlreadyExists.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositivelinkAddressToDID.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositiveAddOrUpdateAttributesByParams.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositiveAddOrUpdateAttributesByBytes.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositiveAddOrUpdateExternalReaderByWriter.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositiveAddOrUpdateExternalReaderByDIDOwner.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositiveDeleteExternalReaderByWriter.selector) {
            beforeTestCalldata = new bytes[](2);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
            beforeTestCalldata[1] = abi.encodePacked(this.test_PositiveAddOrUpdateExternalReaderByDIDOwner.selector);
        }

        if (testSelector == this.test_PositiveDeleteExternalReaderByOwner.selector) {
            beforeTestCalldata = new bytes[](2);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
            beforeTestCalldata[1] = abi.encodePacked(this.test_PositiveAddOrUpdateExternalReaderByDIDOwner.selector);
        }

        if (testSelector == this.test_PositiveProlongateDID.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositiveBlockDID.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
        }

        if (testSelector == this.test_PositiveUnBlockDID.selector) {
            beforeTestCalldata = new bytes[](2);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
            beforeTestCalldata[1] = abi.encodePacked(this.test_PositiveBlockDID.selector);
        }

        if (testSelector == this.test_PositiveRemoveLinkedAddress.selector) {
            beforeTestCalldata = new bytes[](2);
            beforeTestCalldata[0] = abi.encodePacked(this.test_PositiveCreateDid.selector);
            beforeTestCalldata[1] = abi.encodePacked(this.test_PositivelinkAddressToDID.selector);
        }
    }

    function setUp() public {
        did = new StoboxDID();
    }

    function test_AdminWasSetDuringDeploy() public view {
        assertTrue(did.hasRole(DEFAULT_ADMIN_ROLE, FOUNDRY_DEPLOYER));
    }

    function test_PositiveCreateDid() public {
        address writer = makeAddr("writer");
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, writer);
        did.grantRole(ATTRIBUTE_READER_ROLE, writer);
        vm.stopPrank();

        vm.startPrank(writer);
        did.createDID(DEFAULT_DID, DEFAULT_USER, DEFAULT_TIMESTAMP, false);

        (string memory UDID, uint256 validTo, uint256 updatedAt, bool blocked, address lastUpdatedBy) =
            did.getUserDID(DEFAULT_USER);

        assertEq(UDID, DEFAULT_DID);
        assertEq(validTo, DEFAULT_TIMESTAMP);
        assertEq(updatedAt, block.timestamp);
        assertEq(blocked, false);
        assertEq(lastUpdatedBy, writer);

        (string memory uDID, uint256 joinDate, uint256 updateDate, bool deactivated) = did.getLinker(DEFAULT_USER);

        assertEq(uDID, DEFAULT_DID);
        assertEq(joinDate, block.timestamp);
        assertEq(updateDate, block.timestamp);
        assertEq(deactivated, false);

        string[] memory list = did.readAttributeList(DEFAULT_USER);

        assertEq(list.length, ZERO_UINT);

        vm.stopPrank();
    }

    function test_RevertCreateDIDIf_NotWriter() public {
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);
        did.createDID(DEFAULT_DID, DEFAULT_USER, DEFAULT_TIMESTAMP, false);
    }

    function test_RevertCreateDIDIf_ZeroAddressTryToLink() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);
        vm.expectPartialRevert(ISDID.ZeroAddressNotAllowed.selector);
        did.createDID(DEFAULT_DID, ZERO_ADDRESS, DEFAULT_TIMESTAMP, false);

        vm.stopPrank();
    }

    function test_RevertCreateDIDIf_AddressAlreadyHasDID() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);
        vm.expectPartialRevert(ISDID.AddressAlreadyLinkedToDID.selector);
        did.createDID(DEFAULT_DID, DEFAULT_USER, DEFAULT_TIMESTAMP, false);

        vm.stopPrank();
    }

    function test_RevertCreateDIDIf_DIDAlreadyExists() public {
        address newUser = makeAddr("newUser");
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);
        vm.expectPartialRevert(ISDID.DIDAlreadyExists.selector);
        did.createDID(DEFAULT_DID, newUser, DEFAULT_TIMESTAMP, false);

        vm.stopPrank();
    }

    function test_PositivelinkAddressToDID() public {
        vm.prank(FOUNDRY_DEPLOYER);
        did.grantRole(ATTRIBUTE_READER_ROLE, DEFAULT_USER);

        address addressToLink = makeAddr("addressToLink");
        vm.startPrank(DEFAULT_USER);
        did.linkAddressToDID(DEFAULT_USER, addressToLink);

        (string memory uDID, uint256 joinDate, uint256 updateDate, bool deactivated) = did.getLinker(addressToLink);

        assertEq(keccak256(abi.encodePacked(uDID)), keccak256(abi.encodePacked(DEFAULT_DID)));
        assertEq(joinDate, block.timestamp);
        assertEq(updateDate, block.timestamp);
        assertFalse(deactivated);

        (,, uint256 updatedAt,, address lastUpdatedBy) = did.getUserDID(addressToLink);

        assertEq(updatedAt, block.timestamp);
        assertEq(lastUpdatedBy, DEFAULT_USER);

        address[] memory list = did.readLinkedAddresses(addressToLink);
        assertEq(list.length, 2);

        vm.stopPrank();
    }

    function test_PositiveAddOrUpdateAttributesByParams() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);
        did.grantRole(ATTRIBUTE_READER_ROLE, FOUNDRY_DEPLOYER);

        ISDID.ParamAttribute[] memory attributesToAdd = new ISDID.ParamAttribute[](1);
        attributesToAdd[0] = DEFAULT_ATTRIBUTE;

        did.addOrUpdateAttributes(attributesToAdd);

        uint256 len = did.readAttributeList(DEFAULT_USER).length;
        assertEq(len, 1);

        (
            bytes memory value,
            string memory valueType,
            uint256 createdAt,
            uint256 updatedAt,
            uint256 validTo,
            address lastUpdatedBy
        ) = did.getAttribute(DEFAULT_USER, "FIRST_ATTRIBUTE");

        assertEq(value, "0x0");
        assertEq(valueType, "STRING");
        assertEq(createdAt, block.timestamp);
        assertEq(updatedAt, block.timestamp);
        assertEq(validTo, type(uint256).max);
        assertEq(lastUpdatedBy, FOUNDRY_DEPLOYER);

        vm.stopPrank();
    }

    function test_PositiveAddOrUpdateAttributesByBytes() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);
        did.grantRole(ATTRIBUTE_READER_ROLE, FOUNDRY_DEPLOYER);

        bytes[] memory attributesToAdd = new bytes[](1);
        attributesToAdd[0] = abi.encode(
            DEFAULT_ATTRIBUTE.walletAddress,
            DEFAULT_ATTRIBUTE.attributeName,
            DEFAULT_ATTRIBUTE.value,
            DEFAULT_ATTRIBUTE.valueType,
            DEFAULT_ATTRIBUTE.validToData
        );

        did.addOrUpdateAttributes(attributesToAdd);

        uint256 len = did.readAttributeList(DEFAULT_USER).length;
        assertEq(len, 1);

        (
            bytes memory value,
            string memory valueType,
            uint256 createdAt,
            uint256 updatedAt,
            uint256 validTo,
            address lastUpdatedBy
        ) = did.getAttribute(DEFAULT_USER, "FIRST_ATTRIBUTE");

        assertEq(value, "0x0");
        assertEq(valueType, "STRING");
        assertEq(createdAt, block.timestamp);
        assertEq(updatedAt, block.timestamp);
        assertEq(validTo, type(uint256).max);
        assertEq(lastUpdatedBy, FOUNDRY_DEPLOYER);

        vm.stopPrank();
    }

    function test_PositiveAddOrUpdateExternalReaderByWriter() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);

        address addressToAddOrUpd = makeAddr("addressToAddOrUpd");

        did.addOrUpdateExternalReader(DEFAULT_DID, addressToAddOrUpd, DEFAULT_TIMESTAMP);
        assertEq(DEFAULT_TIMESTAMP, did.externalReaderExpirationDate(DEFAULT_DID, addressToAddOrUpd));

        vm.stopPrank();
    }

    function test_PositiveAddOrUpdateExternalReaderByDIDOwner() public {
        vm.startPrank(DEFAULT_USER);

        did.addOrUpdateExternalReader(DEFAULT_USER, DEFAULT_TIMESTAMP);
        assertEq(DEFAULT_TIMESTAMP, did.externalReaderExpirationDate(DEFAULT_DID, DEFAULT_USER));

        vm.stopPrank();
    }

    function test_PositiveDeleteExternalReaderByWriter() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);

        did.deleteExternalReader(DEFAULT_DID, DEFAULT_USER);
        assertEq(ZERO_UINT, did.externalReaderExpirationDate(DEFAULT_DID, DEFAULT_USER));

        vm.stopPrank();
    }

    function test_PositiveDeleteExternalReaderByOwner() public {
        vm.prank(DEFAULT_USER);

        did.deleteExternalReader(DEFAULT_USER);
        assertEq(ZERO_UINT, did.externalReaderExpirationDate(DEFAULT_DID, DEFAULT_USER));
    }

    function test_PositiveProlongateDID() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);

        did.prolongateDID(DEFAULT_DID, 9999999999);
        (, uint256 validTo, uint256 updatedAt,,) = did.getUserDID(DEFAULT_USER);

        assertEq(validTo, 9999999999);
        assertEq(updatedAt, block.timestamp);

        vm.stopPrank();
    }

    function test_PositiveBlockDID() public {
        vm.startPrank(FOUNDRY_DEPLOYER);
        did.grantRole(WRITER_ROLE, FOUNDRY_DEPLOYER);

        did.blockDID(DEFAULT_DID, "Block to test");
        (,,, bool blocked,) = did.getUserDID(DEFAULT_USER);

        assertTrue(blocked);

        vm.stopPrank();
    }

    function test_PositiveUnBlockDID() public {
        vm.prank(FOUNDRY_DEPLOYER);

        did.unBlockDID(DEFAULT_DID, "Unblock to test");
        (,,, bool blocked,) = did.getUserDID(DEFAULT_USER);

        assertFalse(blocked);

        vm.stopPrank();
    }

    function test_PositiveRemoveLinkedAddress() public {}
}
