const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require('fs');

module.exports = function(deployer) {

  
    deployer.deploy(FlightSuretyData,0x5bc48db28704Cd80c5604E52Fb19f2b405689AE7)
    .then(() => {
        return deployer.deploy(FlightSuretyApp,0x8c036f2813b8eca2ef72a6b52642100ae24d8179)
                .then(() => {
                    let config = {
                        localhost: {
                            url: 'http://localhost:7545',
                            dataAddress: FlightSuretyData.address,
                            appAddress: FlightSuretyApp.address
                        }
                    }
                    fs.writeFileSync(__dirname + '/../src/dapp/config.json',JSON.stringify(config, null, '\t'), 'utf-8');
                    fs.writeFileSync(__dirname + '/../src/server/config.json',JSON.stringify(config, null, '\t'), 'utf-8');
                });
    });
}