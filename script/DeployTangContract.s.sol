// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {TangToken,TangTokenScript} from "./TangToken.s.sol";
import {TangProxy,TangProxyScript} from "./TangProxy.s.sol";
import {ChainLinkConfig,NetWorkingChainLinkVRF,NetWorkingChainLinkPriceFeed,VRFCoordinatorV2Mock} from "./ChainLinkConfig.s.sol";
import {NetWorkingConfig,NetWorking} from "./NetWorkingConfig.sol";
import {ChainLinkEnum} from "src/ChainLinkEnum.sol";

contract DeployTangContract is Script {

    string private constant NAME = "TANG1155";
    string private constant SYMBOL = "TANG";
    string private constant URL = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    string private constant wish = "Wish Tang Wan always happy, healthy, and everything goes well";
    ChainLinkConfig private chainlinkConfig;

    NetWorkingChainLinkVRF private chainLinkVRF;
    NetWorkingChainLinkPriceFeed private chainLinkDatafeedStruct;
    NetWorking private netWorking;
    
    /**
     * @notice chainlink dataFeed 货币交易对价格
     * 数组中的地址顺序为ChainLinkEnum枚举顺序 对应不同的token交易对
     * see src/ChainLinkEnum.sol
     * 0: ETH / USD
     * 1: BTC / USD
     */
    address[] public chainLinkDataFeeds = new address[](2);

    modifier init() {
        // 部署网络配置初始化
        netWorking = new NetWorkingConfig().getActiveNetWorking();
        // chainLink 配置初始化
        chainlinkConfig = new ChainLinkConfig();
        chainLinkVRF = chainlinkConfig.getActiveChainlinkVRF();
        chainLinkDatafeedStruct = chainlinkConfig.getActiveChainlinkPriceFeed();
        //配置chainlink货币对 价格数据源
        setTokensFeed();
        _;
    }

    function run() public init returns (TangProxy proxyContract,address deployWallet,address vrfCoordinatorV2Mock){

        // 先部署逻辑合约
        TangTokenScript tangtokenScript = new TangTokenScript();
        TangToken tangtoken = tangtokenScript.run(
            // netWorking.privateKey,
            // NAME,
            // SYMBOL,
            // URL,
            // chainLinkVRF.vrfCoordinator,
            // chainLinkVRF.numWords
            );

        //anvil链要重新创建订阅ID 充值代币
        if(chainLinkVRF.subscriptionId == 0){
            uint64 subId = chainlinkConfig.createSubscriptionId(netWorking.privateKey);
            chainLinkVRF.subscriptionId = subId;
            VRFCoordinatorV2Mock(chainLinkVRF.vrfCoordinator).fundSubscription(subId,100 ether);
        }
        
        // 再部署代理合约
        TangProxyScript tangProxyScript = new TangProxyScript();
        proxyContract = tangProxyScript.run(
            // netWorking.privateKey,
            // address(tangtoken),
            // "",
            // URL,
            // wish,
            // chainLinkDataFeeds,
            // chainLinkVRF.vrfCoordinator,
            // chainLinkVRF.keyHash,
            // chainLinkVRF.subscriptionId,
            // chainLinkVRF.requestConfirmations,
            // chainLinkVRF.callbackGasLimit,
            // chainLinkVRF.numWords
            );
        
        // 添加VRF消费者
        chainlinkConfig.addConsumer(netWorking.privateKey,address(proxyContract),chainLinkVRF.subscriptionId);
        deployWallet = netWorking.walletAddress;
        vrfCoordinatorV2Mock = chainLinkVRF.vrfCoordinator;
    }


    function setTokensFeed() private {
        chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)] = chainLinkDatafeedStruct.priceFeedETH2USD;
        chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.BTC_USD)] = chainLinkDatafeedStruct.priceFeedBTC2USD;
    }
}