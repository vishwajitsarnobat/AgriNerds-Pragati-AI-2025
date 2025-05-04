const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy();
  await marketplace.waitForDeployment();

  console.log("Marketplace deployed to:", await marketplace.getAddress());

  // Create some sample company contracts
  const companies = [
    {
      name: "AgriCorp",
      crop: {
        name: "Wheat",
        quantity: 1000,
        unit: "tonnes",
        pricePerUnit: 2000,
      },
      deliveryDeadline: Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60, // 30 days from now
      insuranceDetails: "Standard crop insurance",
    },
    {
      name: "FarmTech",
      crop: {
        name: "Rice",
        quantity: 500,
        unit: "tonnes",
        pricePerUnit: 2500,
      },
      deliveryDeadline: Math.floor(Date.now() / 1000) + 45 * 24 * 60 * 60, // 45 days from now
      insuranceDetails: "Premium crop insurance",
    },
    {
      name: "GreenHarvest",
      crop: {
        name: "Corn",
        quantity: 800,
        unit: "tonnes",
        pricePerUnit: 1800,
      },
      deliveryDeadline: Math.floor(Date.now() / 1000) + 60 * 24 * 60 * 60, // 60 days from now
      insuranceDetails: "Basic crop insurance",
    },
  ];

  for (const company of companies) {
    const tx = await marketplace.createRequest(
      company.name,
      [
        company.crop.name,
        company.crop.quantity,
        company.crop.unit,
        company.crop.pricePerUnit,
      ],
      company.deliveryDeadline,
      company.insuranceDetails
    );
    await tx.wait();
    console.log(`Created request for ${company.name}`);
  }

  // Save the contract address
  const fs = require('fs');
  const path = require('path');
  const addressFile = path.join(__dirname, '../../agrinerds/assets/contracts/address.json');
  fs.writeFileSync(
    addressFile,
    JSON.stringify({ marketplace: await marketplace.getAddress() }, null, 2)
  );
  console.log("Contract address saved to:", addressFile);

  console.log("Pre-population completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 