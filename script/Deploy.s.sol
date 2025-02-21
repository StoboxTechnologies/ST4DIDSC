// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Script.sol";
import {SDID} from "src/SDID.sol";

contract DeploySDIDScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        SDID sDID = new SDID();
        console.log("SDID is deployed to", address(sDID));

        vm.stopBroadcast();
    }
}
