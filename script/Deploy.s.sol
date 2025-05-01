// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Script.sol";
import {StoboxDID} from "src/StoboxDID.sol";

contract DeploySDIDScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PROD_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        StoboxDID sDID = new StoboxDID();
        console.log("StoboxDID is deployed to", address(sDID));

        vm.stopBroadcast();
    }
}
