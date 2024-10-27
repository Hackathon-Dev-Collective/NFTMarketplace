// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/NFTMarketplace.sol"; // 确保路径正确
import "../src/NFTMarketplaceProxy.sol"; // 确保路径正确

contract DeployNFTMarketplace is Script {
    // 可选函数，在每个函数运行之前被调用
    function setUp() public {}

    // 部署合约时会调用run()函数
    function run() external {
        // 开始广播交易
        vm.startBroadcast();

        // 部署 NFTMarketplace 合约
        //NFTMarketplace marketplace = new NFTMarketplace();
        // 这里可以添加其他逻辑，例如初始化合约状态,例如注册用户等
        // marketplace.register();

        // 直接部署合约而不保存实例
        //new NFTMarketplace();

        // 部署逻辑合约
        NFTMarketplace nftMarketplace = new NFTMarketplace();
        nftMarketplace.initialize();

        // 直接部署代理合约而不保存实例子
        new NFTMarketplaceProxy(nftMarketplace, "");        
        //NFTMarketplaceProxy proxy = new NFTMarketplaceProxy(nftMarketplace, "");        

        // 停止广播交易
        vm.stopBroadcast();
    }

}