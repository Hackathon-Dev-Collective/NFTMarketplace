# NFTMarketplace

## 合约地址

- 合约名称: `NFTMarketplace`
- 地址: `0x78A52474AFcA2E9eaB20389f2D4eaFAD7ACA342f`

## 区块链浏览器
- 合约url: https://explorer.sepolia.linea.build/address/0x78A52474AFcA2E9eaB20389f2D4eaFAD7ACA342f?tab=contract_code
- 说明: 合约已开源，同时可查看abi

## 节点服务商
-- rpc-url: https://linea-sepolia.infura.io/v3/5e6d337523b147f197ccdc703cd60af0
-- ChainId: 59141


## 接口说明

### 1. 创建和铸造 NFT
- **函数**: `createNFT(string memory tokenURI, uint256 price) external returns (uint256) `
- **描述**: 用户可以通过此函数创建和铸造 NFT，设置其元数据和价格。
- **参数**:
  - `tokenURI`: NFT 的元数据 URI。
  - `price`: NFT 的售价。
- **返回值**: 返回一个新创建的 `NFT` 的tokenid。  
- **事件**: `NFTCreated(uint256 indexed tokenId, address indexed owner, string tokenURI, uint256 price)`

### 2. 获取单个 NFT 信息
- **函数**: `getNFT(uint256 tokenId) external view returns (NFT memory)`
- **描述**: 获取指定 tokenId 的 NFT 信息。
- **参数**:
  - `tokenId`: 要查询的 NFT 的 ID。
- **返回值**: 返回一个 `NFT` 结构体，包含 NFT 的详细信息。

### 3. 浏览市场上的 NFT
- **函数**: `getNFTsForSale() external view returns (NFT[] memory)`
- **描述**: 获取市场上所有待售的 NFT 列表。
- **返回值**: 返回一个 `NFT` 数组，包含所有待售 NFT 的信息。

### 4. 购买 NFT
- **函数**: `purchaseNFT(uint256 tokenId) external payable`
- **描述**: 用户可以通过此函数以固定价格购买 NFT。
- **参数**:
  - `tokenId`: 要购买的 NFT 的 ID。
- **要求**:
  - `msg.value` 必须大于或等于 NFT 的售价。
- **事件**: `NFTPurchased(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price)`

### 5. 重新上架 NFT 出售 （按需要使用）
- **函数**: `listNFTForSale(uint256 tokenId, uint256 price) external`
- **描述**: 将用户拥有的 NFT 重新上架出售。应用场景主要为用户在市场购买某个nft之后，如果希望再次出售，可以调用此接口重新上架出售。
- **参数**:
  - `tokenId`: 要上架的 NFT 的 ID。
  - `price`: 新的售价。
- **要求**: 只有 NFT 的拥有者可以调用此函数。

### 6. 获取用户拥有的 NFT 列表
- **函数**: `getUserNFTs(address user) external view returns (uint256[] memory)`
- **描述**: 获取指定用户拥有的 NFT 的 ID 列表。
- **参数**:
  - `user`: 要查询的用户地址。
- **返回值**: 返回一个包含用户拥有的 NFT ID 的数组。

## 示例用法

以下是与合约交互的示例代码，使用 ethers.js 库进行示范：

```javascript
const { ethers } = require("ethers");

// 假设您已经连接到以太坊网络并获取了合约实例
const contractAddress = "YOUR_CONTRACT_ADDRESS";
const abi = [ /* 合约 ABI */ ];

// 适用于不依赖于用户浏览器的环境（例如，后端服务或不需要用户钱包的应用）。它允许您直接与区块链进行交互，发送交易、查询状态等。注意，由于没有用户的私钥，您无法直接发送需要签名的交易。
//const provider = new ethers.providers.JsonRpcProvider("https://linea-sepolia.infura.io/v3/${INFURA_PROJECT_ID}");

// 适用于需要用户交互的前端应用，特别是需要用户签名交易的场景。同时注意，依赖于用户安装钱包扩展，且用户需要主动连接钱包。
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();

// 创建合约实例
const nftMarketplace = new ethers.Contract(contractAddress, abi, signer);

// 1. 创建和铸造 NFT
async function createNFT(tokenURI, price) {
    const tx = await nftMarketplace.createNFT(tokenURI, ethers.utils.parseEther(price.toString()));
    await tx.wait();
    console.log("NFT Created!");
}

// 2. 浏览市场上的 NFT
async function getNFTsForSale() {
    const nfts = await nftMarketplace.getNFTsForSale();
    console.log("NFTs for Sale:", nfts);
}

// 3. 获取单个 NFT 信息
async function getNFT(tokenId) {
    const nft = await nftMarketplace.getNFT(tokenId);
    console.log("NFT Info:", nft);
}

// 4. 购买 NFT
async function purchaseNFT(tokenId, price) {
    const tx = await nftMarketplace.purchaseNFT(tokenId, { value: ethers.utils.parseEther(price.toString()) });
    await tx.wait();
    console.log("NFT Purchased!");
}

// 5. 重新上架 NFT 出售
async function listNFTForSale(tokenId, price) {
    const tx = await nftMarketplace.listNFTForSale(tokenId, ethers.utils.parseEther(price.toString()));
    await tx.wait();
    console.log("NFT Listed for Sale!");
}

// 6. 获取用户拥有的 NFT 列表
async function getUserNFTs(userAddress) {
    const nftIds = await nftMarketplace.getUserNFTs(userAddress);
    console.log("User's NFT IDs:", nftIds);
}

// 示例调用
(async () => {
    await createNFT("https://example.com/metadata/1", 0.1);
    await getNFTsForSale();
    await getNFT(1);
    await purchaseNFT(1, 0.1);
    await listNFTForSale(1, 0.15);
    await getUserNFTs("USER_ADDRESS");
})();