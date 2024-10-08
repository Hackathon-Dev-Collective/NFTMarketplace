// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/NFTMarketplace.sol";

contract NFTMarketplaceTest is Test {
    NFTMarketplace marketplace;
    address user1;
    address user2;

    function setUp() public {
        // 部署合约
        marketplace = new NFTMarketplace();

        // 创建两个测试用户
        user1 = address(0x1);
        user2 = address(0x2);        
    }

    function testCreateNFT() public {
        // User 1 创建 NFT
        //vm.prank(user1);  
        vm.startPrank(user1); // 模拟 user1 的操作
        marketplace.createNFT("https://example.com/nft1", 1 ether);

        // 验证 NFT 是否创建成功
        NFTMarketplace.NFT memory nft = marketplace.getNFT(1); // 使用 getter 函数
        assertEq(nft.id, 1, "NFT id should be 1");
        assertEq(nft.owner, user1, "NFT owner should be user1");
        assertEq(nft.tokenURI, "https://example.com/nft1", "NFT tokenURI should match");
        assertEq(nft.price, 1 ether, "NFT price should match");
        assertTrue(nft.forSale, "NFT should be for sale");      

        vm.stopPrank();        
    }

    function testGetNFTsForSale() public {
        // User 1 创建 NFT
        vm.prank(user1);  // prank用于单次调用
        marketplace.createNFT("https://example.com/nft1", 1 ether);

        // User 2 创建 NFT
        vm.prank(user2);
        marketplace.createNFT("https://example.com/nft2", 2 ether);

        // 获取市场上的 NFT
        NFTMarketplace.NFT[] memory nftsForSale = marketplace.getNFTsForSale();
        assertEq(nftsForSale.length, 2, "There should be 2 NFTs for sale");
    }

    function testPurchaseNFT() public {
        // User1 创建 NFT
        vm.prank(user1);
        marketplace.createNFT("https://example.com/nft1", 1 ether);
        

        // User2  确保 user2 有足够的以太币
        vm.prank(user2);
        vm.deal(user2, 2 ether); // 给 user2 2 ether

        // 检查 NFT 是否可出售
        NFTMarketplace.NFT memory nft = marketplace.getNFT(1);
        assertTrue(nft.forSale, "NFT should be for sale");

        // User 2 购买 NFT
        vm.prank(user2);
        marketplace.purchaseNFT{value: 1 ether}(1); // 这句会导致报错： EvmError: Revert； 原因未明；

        // 验证 NFT 所有权转移
        nft = marketplace.getNFT(1);
        assertEq(nft.owner, user2, "NFT owner should be user2");
        assertFalse(nft.forSale, "NFT should no longer be for sale");

        // 验证 User 2 的 NFT 交易历史
        uint256[] memory userNFTs = marketplace.getUserNFTs(user2);
        assertEq(userNFTs.length, 1, "User 2 should own 1 NFT");
        assertEq(userNFTs[0], 1, "User 2's NFT ID should be 1");
    }

    function testListNFTForSale() public {
        vm.startPrank(user1);  // 模拟 user1 的操作， startPrank用于开始一个模拟的上下文，直到调用 vm.stopPrank()。
        marketplace.createNFT("https://example.com/nft1", 1 ether);
        marketplace.listNFTForSale(1, 2 ether);
        
        // 验证 NFT 的价格和出售状态
        NFTMarketplace.NFT memory nft = marketplace.getNFT(1);
        assertEq(nft.price, 2 ether);
        assertTrue(nft.forSale);
        
        vm.stopPrank();
    }

    function testGetUserNFTs() public {
        vm.startPrank(user1);
        marketplace.createNFT("https://example.com/nft1", 1 ether);
        marketplace.createNFT("https://example.com/nft2", 2 ether);
        vm.stopPrank();

        uint256[] memory userNFTs = marketplace.getUserNFTs(user1);
        assertEq(userNFTs.length, 2);
        assertEq(userNFTs[0], 1);
        assertEq(userNFTs[1], 2);
    }


    function testFailPurchaseNFTInsufficientFunds() public {
        vm.startPrank(user1);
        marketplace.createNFT("https://example.com/nft1", 1 ether);
        vm.stopPrank();

        // user2 尝试以不足的金额购买 NFT
        vm.startPrank(user2);
        vm.deal(user2, 0.5 ether); // 给 user2 发送 0.5 ether
console.log("User2 balance before purchase:", user2.balance);
        vm.expectRevert("Insufficient funds"); // 预期 revert
NFTMarketplace.NFT memory nft = marketplace.getNFT(1);  // 假设有一个获取 NFT 信息的函数
console.log("NFT price:", nft.price);        
        marketplace.purchaseNFT{value: 0.5 ether}(1); // 尝试以 0.5 ether 购买 NFT
        vm.stopPrank();
    }    
}

