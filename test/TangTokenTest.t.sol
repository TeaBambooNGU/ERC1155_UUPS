// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console, console2} from "forge-std/Test.sol";
import {ChainLinkEnum} from "src/ChainLinkEnum.sol";
import {TangProxy} from "script/TangProxy.s.sol";
import {TangToken} from "script/TangToken.s.sol";
import {TangTokenV2} from "script/TangTokenV2.s.sol";
import {VRFCoordinatorV2Mock} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {DeployTangContract} from "script/DeployTangContract.s.sol";
import {Vm} from "forge-std/Vm.sol";



contract TangTokenTest is Test {
    error OnlySimulatedBackend();

    TangProxy public proxyContract;
    address private user ;
    address private admin;
    VRFCoordinatorV2Mock private vrfCoordinatorV2Mock;
    TangTokenV2 public tangTokenV2;

    event VRF_RequestSent(uint256 indexed requestId, uint32 indexed numWords);
    event VRF_RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);
    event TangToken_Awarded(address indexed tangPeople);

    function setUp() public {
        (TangProxy tangProxy, address deployWallet,address _vrfCoordinatorV2Mock, TangTokenV2 _tangTokenV2) = new DeployTangContract().run();
        proxyContract = tangProxy;
        admin = deployWallet;
        user = makeAddr("user");
        vrfCoordinatorV2Mock = VRFCoordinatorV2Mock(_vrfCoordinatorV2Mock);
        tangTokenV2 = _tangTokenV2;
    }

    modifier OnlyAnvil() {
        if(block.chainid != 31337){
            return;
        }
        _;
    }

    function testBalanceOfTang() public {}

    function testMintTokens() public {
        (bool success,) =
            address(proxyContract).call(abi.encodeWithSignature("mint(address,uint256,uint256,bytes)", user, 1, 520,""));
        if (success) {
            (, bytes memory data) =
                address(proxyContract).call(abi.encodeWithSignature("balanceOf(address,uint256)", user, 1));
            assertEq(abi.decode(data, (uint256)), 520);
        }
    }
    //TODO: ProxyAdmin 合约 create2 部署合约
    function testBurnTokens() public {
        vm.startPrank(user);
        testMintTokens();
        (bool success,) =
            address(proxyContract).call(abi.encodeWithSignature("burn(address,uint256,uint256)", user, 1, 520));
        vm.stopPrank();
        assertEq(success, true);
    }

    function testFailBurnTokens() public {
        vm.prank(admin);
        (bool success,) =
            address(proxyContract).call(abi.encodeWithSignature("burn(address,uint256,uint256)", user, 1, 520));
        assertEq(success, true);
    }

    function testEnumSort() public {
        assertEqUint(uint256(ChainLinkEnum.dataFeedType.ETH_USD), 0);
        assertEqUint(uint256(ChainLinkEnum.dataFeedType.BTC_USD), 1);
    }

    function testawardPeopleTokens() public {
        vm.warp(7 days);
        vm.expectEmit(false,true,false,false);
        emit VRF_RequestSent(1, 3);
        (bool success,) = address(proxyContract).call(abi.encodeWithSignature("performUpkeep(bytes)",""));
        assertEq(success, true);
    }

    function testCheckUpkeep() public {
        // prank 第一个参数把msg.sender设置为0  第二个参数把tx.orgin设置为0
        vm.prank(address(0),address(0));
        (bool success, bytes memory data) = address(proxyContract).call(abi.encodeWithSignature("checkUpkeep(bytes)",""));
        if(success){
             (bool upkeepNeeded, bytes memory performData)= abi.decode(data, (bool,bytes));
             console.log("upkeepNeeded= %s performData= %s",upkeepNeeded,string(performData));
        }
        assertEq(success, true);
    }

    function testFailCheckUpkeep() public {
        (bool success, ) = address(proxyContract).call(abi.encodeWithSignature("checkUpkeep(bytes)",""));
        assertEq(success, true);
    }

    function testOnlySimulatedBackend() public {
        vm.expectRevert(OnlySimulatedBackend.selector);
        (bool success, ) = address(proxyContract).call(abi.encodeWithSignature("checkUpkeep(bytes)",""));
        console.log(success);
        assertEq(success, true);
    }

    function testFulfillRandomWords() public OnlyAnvil {
        //添加一个用户
        testMintTokens();
        // 捕获事件 获取requestId
        vm.recordLogs();
        testawardPeopleTokens();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        uint256 requestId = uint256(entries[0].topics[1]);

        vm.expectEmit(false,true,false,false);
        uint256[] memory ss;
        emit VRF_RequestFulfilled(1, ss);
        vm.expectEmit(false,false,false,false);
        emit TangToken_Awarded(address(this));
        vrfCoordinatorV2Mock.fulfillRandomWords(requestId, address(proxyContract));
    }

    function testUpgradeContract() public {
        vm.prank(admin);
        TangToken(address(proxyContract)).upgradeToAndCall(address(tangTokenV2),"");
        assertEq(2,TangTokenV2(address(proxyContract)).getVersion());
    }
}
