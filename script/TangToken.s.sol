// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {TangToken} from "src/TangToken.sol";
import {ChainLinkConfig,NetWorkingChainLinkVRF} from "./ChainLinkConfig.s.sol";

contract TangTokenScript is Script {
    address private admin = makeAddr("admin");
    NetWorkingChainLinkVRF private chainLinkVRF;

    modifier init() {
        ChainLinkConfig chainlinkConfig = new ChainLinkConfig();
        chainLinkVRF = chainlinkConfig.getActiveChainlinkVRF();
        _;
    }

    function run() public returns(TangToken) {

    }


}
