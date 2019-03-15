var HDWalletProvider = require("truffle-hdwallet-provider");

let mnemonic ="crater close lunar fitness uphold glue morning resemble suspect cigar front roast";

module.exports = {
  networks: {
    development: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "http://127.0.0.1:7545/", 0, 50);
      },
      network_id: '*',
      gas: 4712388,
      gasPrice: 100000000000
    }
  },
  rinkeby: {
    provider: function() {
        return new HDWalletProvider(mnemonic,"https://rinkeby.infura.io/v3/cd3a983e10ea4793bead76e564094738")
    },
    network_id: '4',
    gas: 4500000,
    gasPrice: 10000000000,
},
  compilers: {
    solc: {
      version: "^0.4.24"
    }
  }
};