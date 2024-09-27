// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

                
import { ERC721 } from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Counters } from "openzeppelin-contracts/contracts/utils/Counters.sol";
//import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";



/// @title NFT 市场智能合约
///     用户注册(废弃)：用户可以通过 register 函数注册，确保每个用户只能注册一次。  -- 废弃
///     NFT 创建和铸造：用户可以通过 createNFT 函数创建和铸造 NFT，设置其元数据和价格。
///     市场浏览：用户可以通过 getNFTsForSale 函数查看市场上所有待售的 NFT。
///     固定价格购买 NFT：用户可以通过 purchaseNFT 函数以固定价格购买 NFT，合约会处理所有权转移和资金转账。
///     个人拥有NFT列表：用户可以通过 getUserNFTs 函数查看自己拥有的 NFT。
contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct NFT {
        uint256 id;
        address owner;
        string tokenURI;
        uint256 price;
        bool forSale;
    }

    // 注册用户（废弃）
    //struct User {
    //    address wallet;
    //    bool registered;
    //}
    //mapping(address => User) public users;

    // 市场nfts tokenid => NFT
    mapping(uint256 => NFT) public nfts;
    // 用户nfts user_addr => tokenid
    mapping(address => uint256[]) public userNFTs;

    event NFTCreated(uint256 indexed tokenId, address indexed owner, string tokenURI, uint256 price);
    event NFTPurchased(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);

    constructor() ERC721("NFTMarket", "NFTM") {}
    

    // 用户注册 -- 废弃
    //function register() external {
    //    require(!users[msg.sender].registered, "User already registered");
    //    users[msg.sender] = User(msg.sender, true);
    //}
    

    // 创建和铸造 NFT
    function createNFT(string memory tokenURI, uint256 price) external {
        //require(users[msg.sender].registered, "User not registered");
        //
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();

        nfts[newTokenId] = NFT(newTokenId, msg.sender, tokenURI, price, true);
        _mint(msg.sender, newTokenId);  // 因为本合约已确保实现onERC721Received接口， 所以直接用_mint,而没有采用_safeMint；
        _setTokenURI(newTokenId, tokenURI);
        userNFTs[msg.sender].push(newTokenId);

        emit NFTCreated(newTokenId, msg.sender, tokenURI, price);
    }

    // nfts的getter函数接口
    function getNFT(uint256 tokenId) external view returns (NFT memory) {
        return nfts[tokenId];
    }

    // 浏览市场
    function getNFTsForSale() external view returns (NFT[] memory) {
        uint256 totalNFTs = _tokenIdCounter.current();
        NFT[] memory nftsForSale = new NFT[](totalNFTs);
        uint256 count = 0;

        for (uint256 i = 1; i <= totalNFTs; i++) {
            if (nfts[i].forSale) {  // 避免显示正在交易的nft...
                nftsForSale[count] = nfts[i];
                count++;
            }
        }

        // Resize the array to the actual number of NFTs for sale
        NFT[] memory result = new NFT[](count);
        for (uint256 j = 0; j < count; j++) {
            result[j] = nftsForSale[j];
        }

        return result;
    }

    // 固定价格购买 NFT
    function purchaseNFT(uint256 tokenId) external payable {
        NFT storage nft = nfts[tokenId];
        require(nft.forSale, "NFT not for sale");
        require(msg.value >= nft.price, "Insufficient funds");

        address seller = nft.owner;
        nft.owner = msg.sender;
        nft.forSale = false;

        // Transfer the NFT
        _transfer(seller, msg.sender, tokenId);

        // Transfer funds to the seller
        payable(seller).transfer(msg.value);

        
        // 更新 userNFTs 映射
        userNFTs[msg.sender].push(tokenId); // 将 NFT ID 添加到购买者的列表中

        // 从卖家的 userNFTs 中移除该 tokenId
        _removeNFTFromUser(seller, tokenId);

        emit NFTPurchased(tokenId, msg.sender, seller, nft.price);

    }

    // 辅助函数：从用户的 userNFTs 中移除指定的 tokenId
    function _removeNFTFromUser(address user, uint256 tokenId) internal {
        uint256[] storage userTokens = userNFTs[user];
        for (uint256 i = 0; i < userTokens.length; i++) {
            if (userTokens[i] == tokenId) {
                // 将要删除的元素替换为最后一个元素
                userTokens[i] = userTokens[userTokens.length - 1];
                userTokens.pop(); // 删除最后一个元素
                break;
            }
        }
    }

    // 重新上架NFT出售  
    function listNFTForSale(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can list the NFT for sale");
        require(price > 0, "Price must be greater than zero");

        nfts[tokenId].forSale = true;
        nfts[tokenId].price = price;
    }

    // 获取用户所拥有的 NFT 的 ID 列表
    function getUserNFTs(address user) external view returns (uint256[] memory) {
        return userNFTs[user];
    }
}