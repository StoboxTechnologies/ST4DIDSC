// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Script.sol";
import {DIDProrotype} from "src/DIDProrotype.sol";
import {DIDValidator} from "src/DIDValidator.sol";

contract DeployDIDandValidatorScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string[] memory allowedCountries = new string[](2);
        allowedCountries[0] = "UA";
        allowedCountries[1] = "PL";

        vm.startBroadcast(deployerPrivateKey);

        //DIDProrotype dIDProrotype = new DIDProrotype();
        //console.log("DIDProrotype is deployed to", address(dIDProrotype));

        DIDValidator dIDValidator =
            new DIDValidator(address(0xbEe617dD97739304eA936d643Fc24106e64D3EEb), allowedCountries);
        console.log("DIDValidator is deployed to", address(dIDValidator));

        vm.stopBroadcast();
    }
}

// source .env
// forge script --chain 421614 script/Deploy.s.sol:DeployDIDandValidatorScript --rpc-url $ARB_SEPOLIA_RPC_URL
// forge script --chain 421614 script/Deploy.s.sol:DeployDIDandValidatorScript --rpc-url $ARB_SEPOLIA_RPC_URL --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvvv
