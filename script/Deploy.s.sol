// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Script.sol";
import {DIDPrototype} from "src/DIDPrototype.sol";
import {DIDValidator} from "src/DIDValidator.sol";

contract DeployDIDandValidatorScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory attr1 = "country";
        bytes4 countryActionSelector = 0x7c1d66f0;

        address userWallet1 = 0xd4ae3a70E7ad07554482008699bBf0e24469Dd9F;
        address userWallet2 = 0xB78565a3DEd20c1f338234355b208dc14A5D4685;
        address userWallet3 = 0x72Fb69858BF4Bc453Ee5B66Df6536B1c8255A8bd;
        uint256 validTo = 1765985317; //Wed Dec 17 2025 15:28:37 GMT+0000

        string[] memory attributeNames = new string[](1);
        attributeNames[0] = attr1;

        bytes32[] memory hashedAttributes1 = new bytes32[](1);
        hashedAttributes1[0] = 0x029f5d0bba1b4a42e243068d989ad3e9a5b19076bf1e0ff9789c2672b740df70; // userWallet1 + PL
        bytes32[] memory hashedAttributes2 = new bytes32[](1);
        hashedAttributes2[0] = 0xc175eb874d578eae99e190e8f26ac2c4086c9580bf8e1081fc5b7707cc55db62; // userWallet2 + UA
        bytes32[] memory hashedAttributes3 = new bytes32[](1);
        hashedAttributes3[0] = 0x9310f6ac0982a60de79ae8e3d1248590bf5730a0f3c829084f74de23d3aa7757; // userWallet3 + AF

        string[] memory allowedCountries = new string[](6);
        allowedCountries[0] = "UA";
        allowedCountries[1] = "PL";
        allowedCountries[2] = "SK";
        allowedCountries[3] = "EE";
        allowedCountries[4] = "MT";
        allowedCountries[5] = "ES";

        vm.startBroadcast(deployerPrivateKey);

        DIDPrototype dIDPrototype = new DIDPrototype();
        console.log("DIDPrototype is deployed to", address(dIDPrototype));

        dIDPrototype.addGlobalAttribute(attr1);

        dIDPrototype.updateOrCreateDID(userWallet1, validTo, false);
        dIDPrototype.updateOrCreateDID(userWallet2, validTo, false);
        dIDPrototype.updateOrCreateDID(userWallet3, validTo, false);

        dIDPrototype.updateOrAddDIDAttributeHashes(userWallet1, attributeNames, hashedAttributes1);
        dIDPrototype.updateOrAddDIDAttributeHashes(userWallet2, attributeNames, hashedAttributes2);
        dIDPrototype.updateOrAddDIDAttributeHashes(userWallet3, attributeNames, hashedAttributes3);

        DIDValidator dIDValidator = new DIDValidator(address(dIDPrototype), allowedCountries);
        console.log("DIDValidator is deployed to", address(dIDValidator));

        dIDValidator.addAttribute(attr1, countryActionSelector);

        vm.stopBroadcast();
    }
}

// source .env
// forge script --chain 421614 script/Deploy.s.sol:DeployDIDandValidatorScript --rpc-url $ARB_SEPOLIA_RPC_URL
// forge script --chain 421614 script/Deploy.s.sol:DeployDIDandValidatorScript --rpc-url $ARB_SEPOLIA_RPC_URL --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvvv
