// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {TangToken,TangTokenScript} from "./TangToken.s.sol";
import {TangProxy,TangProxyScript} from "./TangProxy.s.sol";
import {TangTokenV2,TangTokenV2Script} from "./TangTokenV2.s.sol";
import {ChainLinkConfig,NetWorkingChainLinkVRF,NetWorkingChainLinkPriceFeed,VRFCoordinatorV2Mock} from "./ChainLinkConfig.s.sol";
import {NetWorkingConfig,NetWorking} from "./NetWorkingConfig.sol";
import {ChainLinkEnum} from "src/ChainLinkEnum.sol";

contract DeployTangContract is Script {

    ChainLinkConfig private chainlinkConfig;

    NetWorkingChainLinkVRF private chainLinkVRF;
    NetWorkingChainLinkPriceFeed private chainLinkDatafeedStruct;
    NetWorking private netWorking;

    string private constant tangSvg = '<svg t="1708785304688" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="4940" xmlns:xlink="http://www.w3.org/1999/xlink" width="200" height="200"><path d="M647.68 291.84l76.8-132.096c6.144-9.728 20.48-12.288 24.064-3.584l39.424 83.968c2.56 6.144 9.728 9.216 17.92 7.68l96.768-19.456c9.728-2.048 15.36 6.144 10.24 14.848l-62.976 102.4c-5.12 8.192-4.096 16.384 1.536 20.992l62.464 48.128c8.192 6.656-1.536 22.016-13.824 22.528l-137.728 21.504c-15.36 0-4.096-30.208-3.584-44.032 1.536-27.136-9.728-71.168-83.456-101.888-10.752-4.608-34.304-9.728-27.648-20.992z" fill="#EA5150" p-id="4941"></path><path d="M761.344 485.376c-10.752 0-19.968-4.096-26.624-12.288-12.288-14.848-8.704-34.816-5.632-50.688 0.512-3.584 1.536-8.192 1.536-9.728 1.536-30.208-21.504-56.32-67.072-75.264-1.536-0.512-3.072-1.024-5.12-2.048-12.288-4.096-31.232-10.752-37.376-28.672-3.584-9.728-2.56-19.968 3.072-28.672l76.288-132.096c9.216-14.848 26.112-24.064 42.496-22.528 13.312 1.024 24.576 9.216 30.208 20.992l35.328 74.24 89.088-17.92c15.36-3.072 30.208 2.56 38.4 14.336 8.704 12.288 8.704 28.16 0 41.472l-58.368 94.72 52.736 40.96c12.288 9.216 16.896 25.088 11.776 40.448-5.632 16.896-22.016 29.696-39.424 30.72l-141.312 22.016c0.512 0 0 0 0 0z m-78.848-199.168c1.024 0.512 1.536 0.512 2.56 1.024 91.136 37.888 101.888 96.768 100.352 128.512 0 3.584-0.512 7.68-1.536 11.776l84.992-13.312-34.304-26.112c-16.896-12.8-20.48-36.864-8.192-56.832l41.984-68.608-57.344 11.776c-20.992 4.096-40.96-5.12-48.64-23.552l-27.136-56.832-52.736 92.16z" fill="#262626" p-id="4942"></path><path d="M271.872 564.224l-151.04 32.256c-11.264 2.56-17.408 16.384-9.728 22.528l72.704 66.56c5.632 4.608 6.656 12.8 3.072 20.48l-44.544 89.088c-4.608 9.216 2.048 17.408 12.288 14.848l117.76-28.672c9.216-2.048 17.408 1.024 20.48 8.192l31.232 77.824c4.096 10.24 22.528 5.632 25.6-6.656l57.856-129.536c4.096-14.848-28.672-14.336-43.008-17.92-27.136-7.68-67.584-32.768-78.848-116.224-2.048-10.752-1.024-35.84-13.824-32.768z" fill="#EA5150" p-id="4943"></path><path d="M332.288 900.608c-15.36 0-29.184-8.704-34.816-23.04l-27.648-68.096-110.592 26.624c-15.36 3.584-30.208-1.024-39.424-12.8-9.216-11.264-10.24-27.136-3.584-40.96l41.472-82.944-66.048-60.928c-10.24-8.704-14.848-22.528-11.776-36.352 3.584-16.384 16.896-29.184 33.28-33.28l151.552-32.256c9.728-2.048 19.968-0.512 27.648 5.632 15.36 11.264 16.896 30.72 17.92 45.056 0 2.048 0.512 4.096 0.512 5.632 7.168 52.736 27.648 84.992 58.88 93.696 2.048 0.512 6.656 1.024 10.24 1.536 16.384 2.048 36.352 5.12 47.104 21.504 5.632 8.192 7.168 18.432 4.096 28.672l-1.536 4.096-56.832 128c-5.632 16.896-21.504 28.672-39.424 29.696 0.512 0.512 0 0.512-1.024 0.512zM276.48 753.664c17.92 0 33.792 9.728 40.448 26.112l18.432 45.056 36.864-81.92c-5.632-0.512-10.752-1.536-15.36-3.072-31.232-8.704-84.992-38.4-98.304-139.264 0-1.536-0.512-3.584-0.512-5.632l-107.52 23.04 51.2 47.104c14.848 12.8 18.432 34.304 9.216 53.248l-28.672 56.832 82.944-19.968c3.584-1.024 7.68-1.536 11.264-1.536z" fill="#262626" p-id="4944"></path><path d="M624.128 670.208c-123.904 92.16-246.784 69.12-314.368-22.016s-54.784-215.04 68.608-307.2 269.312-86.016 337.408 5.12 31.744 231.936-91.648 324.096z" fill="#EA5150" p-id="4945"></path><path d="M656.384 684.032c-128-108.544-109.056-336.896-96.768-422.4 2.56-18.432 13.312-12.8 31.744-10.24l32.768 6.144c17.408 2.56 30.208-2.56 28.672 15.36-6.144 66.048-9.216 220.672 62.464 311.296 17.92 22.528 0.512 41.984-21.504 59.904l-20.992 16.384c-5.632 8.704-8.704 29.696-16.384 23.552z" fill="#F4EF6F" p-id="4946"></path><path d="M658.944 701.44c-4.608 0-9.216-1.536-13.312-5.12-133.12-113.152-116.224-343.552-102.4-437.248 0.512-3.584 2.048-15.36 11.776-22.016 9.728-7.168 20.992-5.12 30.72-3.072l7.68 1.536 33.28 6.656c2.56 0.512 6.144 0.512 9.216 0.512 8.704 0.512 19.456 1.024 26.624 9.216 7.168 8.704 6.144 19.456 6.144 23.04-3.072 33.28-15.36 205.312 59.392 299.52 29.696 37.888-9.216 70.656-23.552 82.944l-18.944 14.848c-1.024 1.536-2.048 4.096-2.56 6.144-3.584 8.704-7.68 19.968-18.944 22.528-1.536 0-3.072 0.512-5.12 0.512z m8.192-30.208z m-91.648-406.016c-12.288 86.016-27.136 288.768 79.36 394.752 1.536-3.072 3.072-6.144 4.608-8.704l1.536-2.048 22.528-17.92c28.672-24.064 23.552-31.232 18.944-37.376-78.336-99.328-71.168-265.216-66.56-319.488h-1.536c-4.096 0-8.192-0.512-13.312-1.024l-33.28-6.656c-2.56-0.512-5.12-1.024-8.192-1.536-1.024 0.512-2.56 0.512-4.096 0z" fill="#262626" p-id="4947"></path><path d="M473.6 764.928C336.384 657.92 358.4 406.016 374.272 316.928c3.072-17.408 19.968-29.184 37.376-26.624l58.88-15.872c-14.336 91.648-23.552 372.224 90.624 454.656L486.4 765.952c-4.096 2.048-9.216 2.048-12.8-1.024z" fill="#F4EF6F" p-id="4948"></path><path d="M480.768 783.872c-6.144 0-11.776-2.048-16.896-5.632C302.08 652.288 351.744 348.16 358.4 313.856c4.608-25.088 27.136-41.984 52.224-40.448l79.872-21.504-4.096 25.088c-16.384 106.496-17.92 365.056 83.968 438.784l22.016 15.872-98.304 48.64c-4.096 2.048-8.704 3.584-13.312 3.584zM406.528 306.176c-7.68 0-14.848 5.632-16.384 13.312C384.512 351.744 337.92 634.88 481.28 750.08l50.176-24.576c-95.232-97.28-90.112-332.288-80.384-428.544l-38.4 10.24-3.584-0.512c-1.024-0.512-1.536-0.512-2.56-0.512z" fill="#262626" p-id="4949"></path><path d="M562.688 274.432c62.464 0 118.272 24.576 153.088 71.168 67.584 91.136 31.744 232.448-91.648 324.608-54.272 40.448-108.544 58.88-158.208 58.88-62.976 0-118.272-29.696-156.16-80.896C242.176 557.056 254.976 432.64 378.88 340.48c59.392-44.544 124.928-66.048 183.808-66.048m0-54.272c-73.216 0-150.016 27.136-216.576 76.8-70.144 52.224-114.176 117.248-127.488 187.904-12.8 68.096 3.584 137.728 47.104 196.096 49.152 66.048 120.32 102.4 200.192 102.4 63.488 0 129.536-24.064 190.464-69.632 69.12-51.2 117.76-119.296 137.728-192 20.992-76.288 8.704-150.528-34.816-208.896-44.032-58.88-115.712-92.672-196.608-92.672z" fill="#262626" p-id="4950"></path><path d="M550.912 642.048c-9.216 0-17.92-6.144-20.992-15.36-3.584-11.264 3.072-23.552 14.336-27.136 110.592-33.792 129.536-126.464 130.048-130.048 2.048-11.776 13.824-19.456 25.6-17.408 11.776 2.048 19.456 13.312 17.408 25.088-1.024 5.12-24.064 122.368-160.256 163.84-2.048 0.512-4.096 1.024-6.144 1.024z" fill="#FFFFFF" p-id="4951"></path><path d="M483.328 642.048m-22.016 0a22.016 22.016 0 1 0 44.032 0 22.016 22.016 0 1 0-44.032 0Z" fill="#FFFFFF" p-id="4952"></path></svg>';
    
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

    function run() public init returns (TangProxy proxyContract,address deployWallet,address vrfCoordinatorV2Mock, TangTokenV2 tangTokenV2){

        // 先部署逻辑合约
        TangTokenScript tangtokenScript = new TangTokenScript();
        TangToken tangtoken = tangtokenScript.run(netWorking.privateKey);

        //anvil链要重新创建订阅ID 充值代币
        if(chainLinkVRF.subscriptionId == 0){
            uint64 subId = chainlinkConfig.createSubscriptionId(netWorking.privateKey);
            chainLinkVRF.subscriptionId = subId;
            VRFCoordinatorV2Mock(chainLinkVRF.vrfCoordinator).fundSubscription(subId,100 ether);
        }
        
        // 再部署代理合约
        TangProxyScript tangProxyScript = new TangProxyScript();
        proxyContract = tangProxyScript.run(
            netWorking.privateKey,
            netWorking.walletAddress,
            tangSvg,
            address(tangtoken),
            chainLinkVRF.vrfCoordinator,
            chainLinkVRF.keyHash,
            chainLinkVRF.subscriptionId,
            chainLinkVRF.requestConfirmations,
            chainLinkVRF.callbackGasLimit
            );
        
        // 添加VRF消费者
        chainlinkConfig.addConsumer(netWorking.privateKey,address(proxyContract),chainLinkVRF.subscriptionId);
        deployWallet = netWorking.walletAddress;
        vrfCoordinatorV2Mock = chainLinkVRF.vrfCoordinator;

        tangTokenV2 = new TangTokenV2Script().run(netWorking.privateKey);
    }


    function setTokensFeed() private {
        chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)] = chainLinkDatafeedStruct.priceFeedETH2USD;
        chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.BTC_USD)] = chainLinkDatafeedStruct.priceFeedBTC2USD;
    }
}