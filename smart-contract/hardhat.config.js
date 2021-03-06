require("@nomiclabs/hardhat-waffle");
require("dotenv/config")

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log("address: " + account.address);
    console.log("balance: " + account.balance);

  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {},
    // ropsten: {
    //   url: process.env.INFURA_URL,
    //   accounts: [process.env.OWNER_ADDRESS]      
    // },
  },
  paths:{
    artifacts: '../client//src/artifacts'
  }  
};
