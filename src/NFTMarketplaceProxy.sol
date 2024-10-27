// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./NFTMarketplace.sol";

contract NFTMarketplaceProxy is ERC1967Proxy {
    constructor(NFTMarketplace _logic, bytes memory _data) 
        ERC1967Proxy(address(_logic), _data) {}
}