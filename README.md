## ERC1155_UUPS
### 项目概述
可升级的ERC1155 Demo
### 开发框架 Foundry
### SEPOLIA合约地址
- TangToken => 0x4c1d42392F708b823d616F6C4FD140e8b3576Dc6
- TangProxy => 0x9A76cEbac21565991e963880139645BE52373C80
- TangTokenV2 => 0x9578288ACfDd13e37150f71d7aAbeACa8EF4013D
### 基本功能
1. 最大铸造数 1314
2. 如果一个tokenID铸造的数量为1 则为NFT，大于1为ERC20类token
3. ID为1的token为ERC20类token，已被占用（有一个功能用chainLink的自动化隔2天随机奖励该合约的Token持有者，奖励Token的ID为1）
### 安装依赖库
#### 一键安装所需依赖（chainLink，OpenZeppelin，forge-std）
```
make install
```
#### chainLink 预言机依赖
```
forge install smartcontractkit/chainlink-brownie-contracts  --no-commit
```
#### OpenZeppelin 三方库依赖
```
forge install Openzeppelin/openzeppelin-contracts-upgradeable --no-commit
```
#### forge-std 依赖
```
forge install foundry-rs/forge-std --no-commit
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
### 一键部署到SEPOLIA
```
make deploy ARGS="--network sepolia"