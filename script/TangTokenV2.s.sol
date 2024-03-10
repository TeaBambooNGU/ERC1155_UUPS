// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {TangTokenV2} from "src/TangTokenV2.sol";
import {ChainLinkConfig,NetWorkingChainLinkVRF} from "./ChainLinkConfig.s.sol";

contract TangTokenV2Script is Script {

    function run(uint256 privateKey) public returns (TangTokenV2 tangToken){
        vm.startBroadcast(privateKey);
        tangToken = new TangTokenV2();
        vm.stopBroadcast();
    }


}
