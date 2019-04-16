# FlightSurety

FlightSurety is a sample application project for Udacity's Blockchain course.

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`
`truffle migrate`

  Deploying Migrations...
  ... 0x90f34751d3df8bf60259fc6f75e52bae6c9984833924bc9cc0a1207fecb6926c
  Migrations: 0xb34c2f24e8d6375b1ef38dd99d973d969981415b
Saving artifacts...
Running migration: 2_deploy_contracts.js
  Replacing FlightSuretyData...
  ... 0x381f812f3dd3a0f600f7a2af003801e7ba9bf1bc7b4b4ce3c4e5438554d3bd63
  FlightSuretyData: 0xabf5af6b3f25386a8b6e94512c5c038e157652b2
  Replacing FlightSuretyApp...
  ... 0x0f6e053671cc651fc7ad279eac349418bcf3e4386347367acadc01103d2e1c16
  FlightSuretyApp: 0x77e5bf0eccf0a450446e1db7ff7c824e697ef951
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