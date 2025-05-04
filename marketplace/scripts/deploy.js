const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy();
  
  await marketplace.waitForDeployment();
  const address = await marketplace.getAddress();
  
  console.log("Marketplace deployed to:", address);

  // Save the contract address to a JSON file
  const addressPath = path.join(__dirname, "../../agrinerds/assets/contracts/address.json");
  fs.writeFileSync(
    addressPath,
    JSON.stringify({ marketplace: address }, null, 2)
  );
  console.log("Contract address saved to:", addressPath);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 