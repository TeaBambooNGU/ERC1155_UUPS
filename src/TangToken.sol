// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC1155Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC1155BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import {ERC1155SupplyUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract TangToken is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable {
    
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
    }
    
    uint256 public constant MAX_ID = 1314;
    // keccak256(abi.encode(uint256(keccak256("TangToken.storage.ERC1155")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TangTokenStorageLocation = 0xd5df3fb4fabe20fb0f8806b05333d8553d0a46d163f4eab210496b509d4b5e00;

    function _getTangTokenStorage() private pure returns (TangTokenStorage storage Tangstore) {
        assembly {
            Tangstore.slot := TangTokenStorageLocation
        }
    }
    
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __ERC1155_init("");
        __Ownable_init(initialOwner);
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
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
        // 在铸造的时候判断是不是NFT
        if (from == address(0)) {
            for(uint256 i = 0; i < ids.length; i++) {
                if(values[ids[i]] == 1) {
                    tangStore.s_NftIds.push(ids[i]);
                }
            }

        }

        super._update(from, to, ids, values);
    }
}
