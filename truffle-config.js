let HDWalletProvider = require("truffle-hdwallet-provider");

//let mnemonic ="crater close lunar fitness uphold glue morning resemble suspect cigar front roast";
let mnemonic ="room slow toddler allow accuse jelly left portion muscle pigeon post powder";
//let mnemonic ="alter witness issue include brave gasp neither young seminar affair noble skull";


// console.log(providerk);
// See <http://truffleframework.com/docs/advanced/configuration>
// to customize your Truffle configuration!
module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*", // Match any network id
            gas: 4712388,
            gasPrice: 100000000000
        },
        rinkeby: {
            provider: function() {
                return new HDWalletProvider(mnemonic,"https://rinkeby.infura.io/v3/cd3a983e10ea4793bead76e564094738")
            },
            network_id: '4',
            "gas":      6500000,
            "gasPrice": 100000000000
        },
  compilers: {
    solc: {
      version: '^0.4.25'
    }
  }
    }
};

