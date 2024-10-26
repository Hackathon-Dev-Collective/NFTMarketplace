## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### env 
```shell
$ source /Users/kylemao/.bashrc 
```

### Install
```shell
$ forge install OpenZeppelin/openzeppelin-contracts@v4.8.0
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```
### Deploy

```shell
$ forge script script/DeployNFTMarketplace.s.sol --rpc-url "https://linea-sepolia.infura.io/v3/${INFURA_PROJECT_ID}" --private-key "${PRIVATE_KEY}" --broadcast 
```

### Verify

```shell
$ forge verify-contract --rpc-url https://rpc.sepolia.linea.build --verifier blockscout   --verifier-url 'https://api-explorer.sepolia.linea.build/api/' --compiler-version 0.8.27  <ConstactID>  ./src/NFTMarketplace.sol:NFTMarketplace
```


## Other Usage

### Gas Snapshots

```shell
$ forge snapshot
$ forge snapshot revert <snapshot_id>
```

### Anvil

```shell
$ anvil
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
