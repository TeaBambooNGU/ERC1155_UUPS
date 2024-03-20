## ERC1155_UUPS
### 项目概述
可升级的ERC1155 Demo
### 开发框架 Foundry
### SEPOLIA合约地址
- TangToken => 0xE15E5dC5647016b87a343b0b3c06Fa8b9541d150
- TangProxy => 0x2E2F9Acb1fC00487aD5ea9eB0917675ace179325
- TangTokenV2 => 0xdF0e37A66FD14c8bc7Aa89746e018D5F0cDeBA55
### 基本功能
1. 最大铸造ID 1314
2. 如果一个tokenID铸造的数量为1 则为NFT，大于1为ERC20类token
3. ID为1的token为ERC20类token，已被占用（有一个功能用chainLink的自动化隔2天随机奖励该合约的Token持有者，奖励Token的ID为1）
4. 每个持有者只会被奖励一次
5. URI的图片资源我用的矢量图，直接写死到合约会更省gas，为了测试全流程，写成了可赋值的形式
6. 所有人可自由mint，只有批量mint被设置了管理员权限
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
### .env环境文件配置（需要自己本地配置该文件）
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
```
### 一键Mint 100个ID为1的token给env中的SEPOLIA_WALLET
```
make mint
```
