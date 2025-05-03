const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace", function () {
    let marketplace;
    let owner;
    let farmer1;
    let farmer2;
    let company1;
    let company2;

    before(async function () {
        [owner, farmer1, farmer2, company1, company2] = await ethers.getSigners();
        const Marketplace = await ethers.getContractFactory("Marketplace");
        marketplace = await Marketplace.deploy();
        await marketplace.waitForDeployment();
    });

    describe("Contract Initialization", function () {
        it("should deploy successfully", async function () {
            expect(await marketplace.getAddress()).to.not.equal(ethers.ZeroAddress);
        });

        it("should have correct name", async function () {
            expect(await marketplace.name()).to.equal("AgriNerds Marketplace");
        });
    });

    describe("Farmer Offer Creation and Management", function () {
        let offerId;
        const cropDetails = {
            name: "Wheat",
            quantity: 100,
            unit: "tonnes",
            pricePerUnit: 500
        };

        it("should allow farmer to create an offer", async function () {
            const deliveryDeadline = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
            const tx = await marketplace.connect(farmer1).createOffer(
                "Farmer John",
                cropDetails,
                deliveryDeadline,
                "PM Fasal Bima Yojana"
            );

            const receipt = await tx.wait();
            const event = receipt.logs[0];
            offerId = event.args[0]; // First argument should be the ID
            
            const contract = await marketplace.getContract(offerId);
            expect(contract.contractType).to.equal(0); // ContractType.Offer
            expect(contract.seller).to.equal(await farmer1.getAddress());
            expect(contract.sellerName).to.equal("Farmer John");
            expect(contract.status).to.equal(0); // ContractStatus.Pending
            expect(contract.crop.name).to.equal(cropDetails.name);
            expect(contract.crop.quantity).to.equal(cropDetails.quantity);
            expect(contract.crop.unit).to.equal(cropDetails.unit);
            expect(contract.crop.pricePerUnit).to.equal(cropDetails.pricePerUnit);
        });

        it("should allow company to accept the offer", async function () {
            await marketplace.connect(company1).acceptOffer(offerId, "Company XYZ");
            const contract = await marketplace.getContract(offerId);
            
            expect(contract.status).to.equal(1); // ContractStatus.Agreed
            expect(contract.buyer).to.equal(await company1.getAddress());
            expect(contract.buyerName).to.equal("Company XYZ");
        });

        it("should not allow non-buyer to accept offer", async function () {
            // Create a new offer for this test
            const deliveryDeadline = Math.floor(Date.now() / 1000) + 86400;
            const tx = await marketplace.connect(farmer1).createOffer(
                "Farmer John",
                cropDetails,
                deliveryDeadline,
                "PM Fasal Bima Yojana"
            );
            const receipt = await tx.wait();
            const event = receipt.logs[0];
            const newOfferId = event.args[0];

            // First company accepts it
            await marketplace.connect(company1).acceptOffer(newOfferId, "Company XYZ");

            // Second company tries to accept it
            await expect(
                marketplace.connect(company2).acceptOffer(newOfferId, "Company ABC")
            ).to.be.revertedWith("Incorrect contract status");
        });
    });

    describe("Company Request Creation and Management", function () {
        let requestId;
        const cropDetails = {
            name: "Rice",
            quantity: 500,
            unit: "tonnes",
            pricePerUnit: 400
        };

        it("should allow company to create a request", async function () {
            const deliveryDeadline = Math.floor(Date.now() / 1000) + 86400;
            const tx = await marketplace.connect(company1).createRequest(
                "Company ABC",
                cropDetails,
                deliveryDeadline,
                "Private Insurance Coverage"
            );

            const receipt = await tx.wait();
            const event = receipt.logs[0];
            requestId = event.args[0]; // First argument should be the ID
            
            const contract = await marketplace.getContract(requestId);
            expect(contract.contractType).to.equal(1); // ContractType.Request
            expect(contract.buyer).to.equal(await company1.getAddress());
            expect(contract.buyerName).to.equal("Company ABC");
            expect(contract.status).to.equal(0); // ContractStatus.Pending
        });

        it("should allow farmer to submit commitment", async function () {
            const tx = await marketplace.connect(farmer2).submitCommitment(
                requestId,
                "Farmer Mike",
                200,
                "PM Fasal Bima Yojana"
            );

            const receipt = await tx.wait();
            const event = receipt.logs[0];
            const commitmentId = event.args[0]; // First argument should be the ID
            
            const contract = await marketplace.getContract(commitmentId);
            expect(contract.contractType).to.equal(2); // ContractType.Commitment
            expect(contract.seller).to.equal(await farmer2.getAddress());
            expect(contract.sellerName).to.equal("Farmer Mike");
            expect(contract.crop.quantity).to.equal(200);
            expect(contract.status).to.equal(0); // ContractStatus.Pending
        });

        it("should allow company to accept commitment", async function () {
            const commitments = await marketplace.getCommitmentsForRequest(requestId);
            const commitmentId = commitments[0];
            
            await marketplace.connect(company1).acceptCommitment(commitmentId);
            const contract = await marketplace.getContract(commitmentId);
            
            expect(contract.status).to.equal(1); // ContractStatus.Agreed
        });
    });

    describe("Contract Status Updates", function () {
        let contractId;

        beforeEach(async function () {
            const deliveryDeadline = Math.floor(Date.now() / 1000) + 86400;
            const tx = await marketplace.connect(farmer1).createOffer(
                "Farmer Test",
                { name: "Corn", quantity: 50, unit: "tonnes", pricePerUnit: 300 },
                deliveryDeadline,
                "Insurance"
            );

            const receipt = await tx.wait();
            const event = receipt.logs[0];
            contractId = event.args[0]; // First argument should be the ID
            
            await marketplace.connect(company1).acceptOffer(contractId, "Company Test");
        });

        it("should allow buyer to confirm delivery", async function () {
            await marketplace.connect(company1).confirmDelivery(contractId);
            const contract = await marketplace.getContract(contractId);
            expect(contract.status).to.equal(2); // ContractStatus.DeliveryConfirmed
        });

        it("should allow seller to confirm payment", async function () {
            await marketplace.connect(company1).confirmDelivery(contractId);
            await marketplace.connect(farmer1).confirmPaymentReceived(contractId);
            const contract = await marketplace.getContract(contractId);
            expect(contract.status).to.equal(4); // ContractStatus.Completed
        });
    });

    describe("Contract Cancellation", function () {
        let pendingOfferId;

        beforeEach(async function () {
            const deliveryDeadline = Math.floor(Date.now() / 1000) + 86400;
            const tx = await marketplace.connect(farmer1).createOffer(
                "Farmer Cancel",
                { name: "Soy", quantity: 30, unit: "tonnes", pricePerUnit: 200 },
                deliveryDeadline,
                "Insurance"
            );

            const receipt = await tx.wait();
            const event = receipt.logs[0];
            pendingOfferId = event.args[0]; // First argument should be the ID
        });

        it("should allow seller to cancel pending offer", async function () {
            await marketplace.connect(farmer1).cancelContract(pendingOfferId);
            const contract = await marketplace.getContract(pendingOfferId);
            expect(contract.status).to.equal(5); // ContractStatus.Cancelled
        });

        it("should not allow cancellation of accepted offer", async function () {
            await marketplace.connect(company1).acceptOffer(pendingOfferId, "Company Cancel");
            await expect(
                marketplace.connect(farmer1).cancelContract(pendingOfferId)
            ).to.be.revertedWith("Can only cancel pending contracts");
        });
    });

    describe("View Functions", function () {
        it("should return correct contracts for seller", async function () {
            const contracts = await marketplace.getContractsForSeller(await farmer1.getAddress());
            expect(Array.isArray(contracts)).to.be.true;
        });

        it("should return correct contracts for buyer", async function () {
            const contracts = await marketplace.getContractsForBuyer(await company1.getAddress());
            expect(Array.isArray(contracts)).to.be.true;
        });
    });
}); 