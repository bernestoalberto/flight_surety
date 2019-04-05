# FlightSurety

FlightSurety is a sample application project for Udacity's Blockchain course.

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`
`truffle migrate`
Using network 'rinkeby'.

Running migration: 1_initial_migration.js
  Deploying Migrations...
  ... 0x5e3e0d9a5c61523de32c364d0ecabe64a14a0dee8276e894af0653e8cce63ef7
  Migrations: 0x2608c14c219a1dfb69fcce05cdf5416e186fa777
Saving artifacts...
Running migration: 2_deploy_contracts.js
  Deploying FlightSuretyData...
  ... 0x11477729271f4f7569c24e50ce19c9d2a12133b83464307f58e5cf2afd6b8ecb
  FlightSuretyData: 0x7670599a0e9cc2c6a1c10a297b69237b9a1b87c1
  Deploying FlightSuretyApp...
  ... 0xd175e1ccc44a3343063732c98f1f5bd10a694b63eb8ae6fd8b3614185a316b88
  FlightSuretyApp: 0x4f9865e411d37134f99767dd2781d6c5ea2e32a8
Saving artifacts...




## Develop Client

To run truffle tests:

`truffle test ./test/flightSurety.js`
`truffle test ./test/oracles.js`

To use the dapp:

`truffle migrate`
`npm run dapp`

To view dapp:

`http://localhost:8000`

## Develop Server

`npm run server`
`truffle test ./test/oracles.js`

## Deploy

To build dapp for prod:
`npm run dapp:prod`

Deploy the contents of the ./dapp folder


## Resources

* [How does Ethereum work anyway?](https://medium.com/@preethikasireddy/how-does-ethereum-work-anyway-22d1df506369)
* [BIP39 Mnemonic Generator](https://iancoleman.io/bip39/)
* [Truffle Framework](http://truffleframework.com/)
* [Ganache Local Blockchain](http://truffleframework.com/ganache/)
* [Remix Solidity IDE](https://remix.ethereum.org/)
* [Solidity Language Reference](http://solidity.readthedocs.io/en/v0.4.24/)
* [Ethereum Blockchain Explorer](https://etherscan.io/)
* [Web3Js Reference](https://github.com/ethereum/wiki/wiki/JavaScript-API)