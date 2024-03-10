// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC1155Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC1155BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import {ERC1155SupplyUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AutomationCompatible} from "chainlink-brownie-contracts/contracts/src/v0.8/AutomationCompatible.sol";
import {VRFCoordinatorV2Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract TangToken is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable, AutomationCompatible {

    error MintTokenOverMaxId(uint256 tokenId);
    error OnlyCoordinatorCanFulfill(address have, address want);
    error TangToken_AwardedNotInTime(address sender, uint256 currentTimestamp);
    error RequestNotFound(uint256 requestId);
    
    struct TangTokenStorage {
        // 已铸造的NFT列表
        uint256[]  s_NftIds;
        // 持有者列表
        address[]  s_totalPeople;
        // 是否是小糖人
        mapping(address => bool) s_isTangPeople;
        // 上一次奖励时间
        uint256  s_lastAwardTime;
        // 是否已经奖励过
        mapping(address => bool) s_peopleAwarded;
        
        // VRFCoordinator合约地址
        VRFCoordinatorV2Interface s_vrfCoordinator;
        // ChainLink订阅ID
        uint64 s_subscriptionId;
        // ChainLink费率哈希
        bytes32 s_keyHash;
        // 请求被确认的区块数
        uint16 s_requestConfirmations;
        // 回调接口限制的最大Gas
        uint32 s_callbackGasLimit;
        // requestID 和 请求状态的映射
        mapping(uint256 => RequestStatus)  s_requests; /* requestId --> requestStatus */
        // past requests Id.
        uint256[]  s_requestIds;
        // 上一个请求ID
        uint256  s_lastRequestId;
    }

    struct RequestStatus {
            bool fulfilled; // whether the request has been successfully fulfilled
            bool exists; // whether a requestId exists
            uint256[] randomWords;
    }
    
    uint256 public constant MAX_ID = 1314;
    // keccak256(abi.encode(uint256(keccak256("TangToken.storage.ERC1155")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TangTokenStorageLocation = 0xd5df3fb4fabe20fb0f8806b05333d8553d0a46d163f4eab210496b509d4b5e00;
    uint32 public constant CHAINLINK_NUMWORDS = 3;
    uint48 public constant AWARD_INTERVAL = 2 days;

    event VRF_RequestSent(uint256 indexed requestId, uint32 indexed numWords);
    event VRF_RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);
    event TangToken_Awarded(address indexed tangPeople);


    function _getTangTokenStorage() private pure returns (TangTokenStorage storage Tangstore) {
        assembly {
            Tangstore.slot := TangTokenStorageLocation
        }
    }
    
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _uri,
        address _initialOwner, 
        address _vrfCoordinatorAddress, 
        uint64 _subscriptionId, 
        bytes32 _keyHash, 
        uint16 _requestConfirmations,
        uint32 _callbackGasLimit) initializer public {
        __ERC1155_init(_uri);
        __Ownable_init(_initialOwner);
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
        __ChainLinkVRF_init(_vrfCoordinatorAddress,  _subscriptionId, _keyHash, _requestConfirmations, _callbackGasLimit);
    }

    function __ChainLinkVRF_init(
        address _vrfCoordinatorAddress, 
        uint64 _subscriptionId, 
        bytes32 _keyHash, 
        uint16 _requestConfirmations,
        uint32 _callbackGasLimit
    ) internal onlyInitializing {
        __ChainLinkVRF_init_unchained(_vrfCoordinatorAddress, _subscriptionId, _keyHash, _requestConfirmations, _callbackGasLimit);
    }

    function __ChainLinkVRF_init_unchained(
        address _vrfCoordinatorAddress, 
        uint64 _subscriptionId, 
        bytes32 _keyHash, 
        uint16 _requestConfirmations,
        uint32 _callbackGasLimit
    ) internal onlyInitializing {
        TangTokenStorage storage tangStore = _getTangTokenStorage();
        tangStore.s_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddress);
        tangStore.s_subscriptionId = _subscriptionId;
        tangStore.s_keyHash = _keyHash;
        tangStore.s_requestConfirmations = _requestConfirmations;
        tangStore.s_callbackGasLimit = _callbackGasLimit;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        //onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function checkUpkeep(bytes calldata /*checkData8*/) external view override cannotExecute  returns (bool upkeepNeeded, bytes memory performData) {
        TangTokenStorage storage tangStore = _getTangTokenStorage();
        
        if(tangStore.s_lastAwardTime + AWARD_INTERVAL < block.timestamp){
            upkeepNeeded = true;
        }

        performData = "";
        
    }
    function performUpkeep(bytes calldata /*performData*/) external override{
        awardPeopleTokens();
    }


    function awardPeopleTokens() private {
        TangTokenStorage storage tangStore = _getTangTokenStorage();

        if(tangStore.s_lastAwardTime + AWARD_INTERVAL >= block.timestamp){
            revert TangToken_AwardedNotInTime(msg.sender, block.timestamp);
        }

       // Will revert if subscription is not set and funded.
        uint256 requestId = tangStore.s_vrfCoordinator.requestRandomWords(
            tangStore.s_keyHash,
            tangStore.s_subscriptionId,
            tangStore.s_requestConfirmations,
            tangStore.s_callbackGasLimit,
            CHAINLINK_NUMWORDS
        );
        tangStore.s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        tangStore.s_requestIds.push(requestId);
        tangStore.s_lastRequestId = requestId;
        emit VRF_RequestSent(requestId, CHAINLINK_NUMWORDS);
    }

    function rawFulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) external  {
        TangTokenStorage storage tangStore = _getTangTokenStorage();
        
        if(!tangStore.s_requests[_requestId].exists){
            revert RequestNotFound(_requestId);
        }
        if(msg.sender != address(tangStore.s_vrfCoordinator)){
            revert OnlyCoordinatorCanFulfill(msg.sender, address(tangStore.s_vrfCoordinator));
        }
        tangStore.s_requests[_requestId].fulfilled = true;
        tangStore.s_requests[_requestId].randomWords = _randomWords;
        emit VRF_RequestFulfilled(_requestId, _randomWords);

        address[] memory totalPeople = tangStore.s_totalPeople;
        for(uint i = 0; i < _randomWords.length; i++){
            uint awardIndex = _randomWords[i] % totalPeople.length;
            address awardPeople = totalPeople[awardIndex];
            if(!tangStore.s_peopleAwarded[awardPeople]){
                tangStore.s_peopleAwarded[awardPeople] = true;
                _mint(awardPeople, 1, 520,"");
                emit TangToken_Awarded(awardPeople);
            }
        }
        
    }



    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        // 更新持有者列表
        TangTokenStorage storage tangStore = _getTangTokenStorage();
        if(tangStore.s_isTangPeople[to] == false) {
            tangStore.s_isTangPeople[to] = true;
            tangStore.s_totalPeople.push(to);
        }
        // 在铸造的时候判断 ID是否超过最大值  是不是NFT
        if (from == address(0)) {
            for(uint256 i = 0; i < ids.length; i++) {
                uint256 id = ids[i];
                if(id > MAX_ID) {
                    revert MintTokenOverMaxId(id);
                }
                if(values[i] == 1) {
                    tangStore.s_NftIds.push(id);
                }
            }
        }
        super._update(from, to, ids, values);
    }


}
