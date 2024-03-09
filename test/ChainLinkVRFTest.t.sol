// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {VRFCoordinatorV2Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {ChainLinkConfig,NetWorkingChainLinkVRF} from "script/ChainLinkConfig.s.sol";

contract ChainLinkVRFTest is Test {

    VRFCoordinatorV2Interface private vrfCoordinator;
    uint64 private subscriptionId;

    event SubscriptionConsumerAdded(uint64 indexed subId, address consumer);

    function setUp() public {
        ChainLinkConfig chainlinkConfig = new ChainLinkConfig();
        NetWorkingChainLinkVRF memory netWorkingChainLinkVRF = chainlinkConfig.getActiveChainlinkVRF();
        vrfCoordinator = VRFCoordinatorV2Interface(netWorkingChainLinkVRF.vrfCoordinator);
        subscriptionId = netWorkingChainLinkVRF.subscriptionId;
    }


    // function testAddConsumer() public {

    //     if(subscriptionId == 0){
    //         uint64 subId = vrfCoordinator.createSubscription();
    //         vm.expectEmit();
    //         emit SubscriptionConsumerAdded(subId,address(this));
    //         vrfCoordinator.addConsumer(subId, address(this));
    //     }else{
    //         vm.expectEmit();
    //         emit SubscriptionConsumerAdded(subscriptionId,address(this));
    //         vrfCoordinator.addConsumer(subscriptionId, address(this));
    //     }
        

    // }

    

}