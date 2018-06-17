module.exports = {
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
            gas: 6721975,
            gasPrice: 20000000000,
        }
    },
    rpc: {
        host: "localhost",
        port: 8545
    }
};