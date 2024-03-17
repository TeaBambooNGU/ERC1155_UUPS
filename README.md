## ERC1155_UUPS
### 项目概述
可升级的ERC1155 Demo
### 开发框架 Foundry
### 安装依赖库
#### chainLink 预言机依赖
```
 forge install smartcontractkit/chainlink-brownie-contracts  --no-commit
```
#### OpenZeppelin 三方库依赖
```
forge install Openzeppelin/openzeppelin-contracts-upgradeable --no-commit
```
### .env环境文件配置
```
SEPOLIA_RPC_URL=xxxx
SEPOLIA_WALLET_KEY=xxx
SEPOLIA_WALLET=xxx
ANVIL_WALLET_KEY=xxx
ANVIL_WALLET=xxx
ETHERSCAN_API_KEY=xxxx
```
### 完成单元测试 
#### 本地anvil环境
```
forge test
```
#### SEPOLIA环境
```
forge test --fork-url $SEPOLIA_RPC_URL
```
#### 获得测试覆盖率
```
forge coverage
```
