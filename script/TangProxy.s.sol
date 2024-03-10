// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TangProxy} from "src/TangProxy.sol";
import {ChainLinkConfig, NetWorkingChainLinkPriceFeed, NetWorkingChainLinkVRF} from "./ChainLinkConfig.s.sol";
import {ChainLinkEnum} from "src/ChainLinkEnum.sol";
import {TangToken} from "src/TangToken.sol";

contract TangProxyScript is Script {

    string private constant wish = "Wish Tang Wan always happy, healthy, and everything goes well";

    /**
     * @notice chainlink dataFeed 货币交易对价格
     * 数组中的地址顺序为ChainLinkEnum枚举顺序 对应不同的token交易对
     * see src/ChainLinkEnum.sol
     * 0: ETH / USD
     * 1: BTC / USD
     */
    address[] public chainLinkDataFeeds = new address[](2);

    NetWorkingChainLinkVRF private chainLinkVRF;
    ChainLinkConfig private chainlinkConfig;

    // modifier init() {
    //     chainlinkConfig = new ChainLinkConfig();
    //     NetWorkingChainLinkPriceFeed memory feedStruct = chainlinkConfig.getActiveChainlinkPriceFeed();
    //     chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)] = feedStruct.priceFeedETH2USD;
    //     chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.BTC_USD)] = feedStruct.priceFeedBTC2USD;
    //     chainLinkVRF = chainlinkConfig.getActiveChainlinkVRF();
    //     _;
    // }

    function run(
        uint256 _privateKey, 
        string memory _url,
        address tangTokenAddress, 
        address _vrfCoordinator,
        bytes32 _keyHash, 
        uint64 _subscriptionId, 
        uint16 _requestConfirmations, 
        uint32 _callbackGasLimit
        ) public returns (TangProxy tangProxy){
            vm.startBroadcast(_privateKey);
            tangProxy = new TangProxy(tangTokenAddress,"");
            TangToken(address(tangProxy)).initialize(_url,msg.sender,_vrfCoordinator,_subscriptionId,_keyHash,_requestConfirmations,_callbackGasLimit);
            vm.stopBroadcast();

        
    }


}
