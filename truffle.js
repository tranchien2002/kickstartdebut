const HDWalletProvider = require("truffle-hdwallet-provider");
MNENOMIC = "fatigue swarm odor helmet zone pattern obscure loud basic biology start wet"
INFURA_API_KEY = "53c708dd5cec4b94bf212dcac7a3490f"
module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: '*', // Match any network id
      gas: 470000
    },
    ropsten: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://ropsten.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 3,
      gas: 4612388
    },
    kovan: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://kovan.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 42,
      gas: 470000,
      gasPrice: 21
    },
    rinkeby: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://rinkeby.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 4,
      gas: 470000,
      gasPrice: 21
    },
    // main ethereum network(mainnet)
    main: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://mainnet.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 1,
      gas: 470000,
      gasPrice: 21
    }
  }
}