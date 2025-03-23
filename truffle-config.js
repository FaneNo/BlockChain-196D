// truffle-config.js
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,       // using the default ganache GUI
      network_id: "*",  
    },
    
  },
  compilers: {
    solc: {
      version: "0.8.19",    // need to match the version in the contract
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  },
  // Directory structure setup
  contracts_directory: './contracts',
  contracts_build_directory: './build/contracts',
  migrations_directory: './migrations',
};
