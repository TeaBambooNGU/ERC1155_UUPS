// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {TangToken} from "src/TangToken.sol";
import {ChainLinkConfig,NetWorkingChainLinkVRF} from "./ChainLinkConfig.s.sol";

contract TangTokenScript is Script {

    function run(uint256 privateKey) public returns (TangToken tangToken){
        vm.startBroadcast(privateKey);
        tangToken = new TangToken();
        vm.stopBroadcast();
    }


}
