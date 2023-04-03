import { HardhatUserConfig } from "hardhat/config";
import { config as dotenvConfig } from "dotenv";
import { resolve } from "path";
import "@nomicfoundation/hardhat-toolbox";

const dotenvConfigPath: string = process.env.DOTENV_CONFIG_PATH || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

const {
  DEFAULT_NETWORK,
  MNEMONIC,
  MOONBEAM_API_KEY,
} = process.env;

const accounts = {
  mnemonic: MNEMONIC,
  path: "m/44'/60'/0'/0",
  initialIndex: 0,
  count: 11,
  passphrase: "",
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  defaultNetwork: DEFAULT_NETWORK,
  networks: {
    moonbaseAlpha: {
      url: 'https://rpc.testnet.moonbeam.network',
      chainId: 1287,
      accounts: accounts
    },
    mumbai: {
      url: 'https://rpc.ankr.com/polygon_mumbai',
      chainId: 80001,
      accounts: accounts
    }
  },
  etherscan: {
    apiKey: {
      moonbaseAlpha: MOONBEAM_API_KEY!
    }
  }
};

export default config;