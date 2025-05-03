// Possible events:
// 1. Farmer creates a contract, company just accepts it and contract begins
// 2. Company creates contract, farmers apply committing to the quantity they can supply, 
// company reviews the applications and finalizes the farmer contracts by either accepting or 
// rejecting them

// Contract cancellations can be made only if it is not accepted

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Marketplace {

    string public name;
    uint public contractCounter;
    mapping(uint => Contract) public contracts;

    mapping(address => uint[]) public contractsAsSeller; // Farmer offering or committing
    mapping(address => uint[]) public contractsAsBuyer;  // Company requesting or accepting offer
    mapping(uint => uint[]) public commitmentsForRequest; // Track commitment IDs for a Request ID

    enum ContractType { Offer, Request, Commitment }
    // Offer: Farmer offers specific quantity/price. Awaits Company acceptance.
    // Request: Company requests total quantity/price. Awaits Farmer commitments.
    // Commitment: Farmer commits to fulfilling part of a Request. Awaits Company acceptance.

    enum ContractStatus {
        Pending,     // 0: Offer/Request created; Commitment submitted but not approved
        Agreed,      // 1: Offer accepted; Commitment approved. Awaiting delivery.
        DeliveryConfirmed, // 2: Buyer confirmed goods received (off-chain)
        PaymentConfirmed, // 3: Seller confirmed payment received (off-chain)
        Completed,   // 4: Both confirmations done.
        Cancelled,   // 5: Offer/Request/Commitment cancelled before agreement by creator or expired
        Rejected     // 6: Commitment rejected by Company
    }

    struct Contract {
        uint id;
        ContractType contractType;
        uint parentRequestId; // 0 if Offer or Request, >0 links Commitment by farmer to Request
        address seller; // Party supplying goods (Farmer in Offer/Commitment)
        string sellerName;
        address buyer;  // Party receiving goods (Company in Offer/Commitment, creator of Request)
        string buyerName;
        ContractStatus status;
        Crop crop; // quantity -> total for Request/Offer, specific for Commitment
        uint256 creationTimestamp;
        uint256 agreementTimestamp; // When status becomes Agreed
        uint256 deliveryDeadlineTimestamp;
        string insuranceDetails; // farmer mentions if he has insurance, company mentions if they are providing insurance
    }

    struct Crop {
        string name;
        uint quantity; // quantity in terms of specified unit
        string unit; // e.g. tonnes, kilos or any relevant unit
        uint pricePerUnit;
    }

    // --- Events ---
    event ContractCreated(uint indexed id, ContractType contractType, address indexed creator, uint parentRequestId);
    event CommitmentSubmitted(uint indexed commitmentId, uint indexed parentRequestId, address indexed farmer, uint quantity);
    event ContractAgreed(uint indexed id, address indexed seller, address indexed buyer); // For Offer acceptance or Commitment approval by company
    event DeliveryConfirmed(uint indexed id, address indexed confirmer);
    event PaymentConfirmed(uint indexed id, address indexed confirmer);
    event ContractCompleted(uint indexed id);
    event ContractCancelled(uint indexed id, address indexed canceller);
    event CommitmentRejected(uint indexed id, address indexed rejector);


    // --- Constructor ---
    constructor() {
        name = "AgriNerds Marketplace";
        contractCounter = 0;
    }

    // --- Modifiers ---
    modifier onlySeller(uint _contractId) {
        require(contracts[_contractId].seller == msg.sender, "Caller is not the seller");
        _;
    }

    modifier onlyBuyer(uint _contractId) {
        require(contracts[_contractId].buyer == msg.sender, "Caller is not the buyer");
        _;
    }

    modifier onlyParty(uint _contractId) {
        require(contracts[_contractId].seller == msg.sender || contracts[_contractId].buyer == msg.sender, "Caller not party to contract");
        _;
    }

    modifier onlyRequestOwner(uint _requestId) {
        require(contracts[_requestId].contractType == ContractType.Request, "Not a Request contract");
        require(contracts[_requestId].buyer == msg.sender, "Caller is not the owner of the Request");
        _;
    }

    modifier inStatus(uint _contractId, ContractStatus _expectedStatus) {
        require(contracts[_contractId].status == _expectedStatus, "Incorrect contract status");
        _;
    }

    // --- Functions ---

    // Scenario 1: Farmer creates a specific offer
    function createOffer(
        string calldata _sellerName,
        Crop calldata _crop,
        uint256 _deliveryDeadlineTimestamp,
        string calldata _insuranceDetails // farmer will specify if he has any insurance
    ) external returns (uint) {
        require(_crop.quantity > 0 && _crop.pricePerUnit > 0, "Invalid crop details");

        uint id = ++contractCounter;
        contracts[id] = Contract({
            id: id,
            contractType: ContractType.Offer,
            parentRequestId: 0,
            seller: msg.sender,
            sellerName: _sellerName,
            buyer: address(0),
            buyerName: "", // Set on acceptance
            status: ContractStatus.Pending, // Awaiting company acceptance
            crop: _crop,
            creationTimestamp: block.timestamp,
            agreementTimestamp: 0,
            deliveryDeadlineTimestamp: _deliveryDeadlineTimestamp,
            insuranceDetails: _insuranceDetails
        });

        contractsAsSeller[msg.sender].push(id); // push the contract in seller's contract list

        emit ContractCreated(id, ContractType.Offer, msg.sender, 0);
        return id;
    }

    // Scenario 1: Company accepts a Farmer's Offer
    function acceptOffer(uint _offerId, string calldata _buyerName)
        external
        inStatus(_offerId, ContractStatus.Pending)
    {
        require(contracts[_offerId].contractType == ContractType.Offer, "Not an Offer");

        Contract storage contractRef = contracts[_offerId];
        contractRef.status = ContractStatus.Agreed;
        contractRef.buyer = msg.sender;
        contractRef.buyerName = _buyerName;
        contractRef.agreementTimestamp = block.timestamp;

        contractsAsBuyer[msg.sender].push(_offerId); // push the agreed contract in buyer's contract list
        emit ContractAgreed(_offerId, contractRef.seller, contractRef.buyer);
    }


    // Scenario 2: Company creates a Request for a total quantity
    function createRequest(
        string calldata _buyerName, // Company Name
        Crop calldata _crop, // Total quantity needed, target price
        uint256 _deliveryDeadlineTimestamp,
        string calldata _insuranceDetails // company will specify if they have any insurance to offer
    ) external returns (uint) {
        require(_crop.quantity > 0 && _crop.pricePerUnit > 0, "Invalid crop details");

        uint id = ++contractCounter;
        // For a Request, the 'buyer' is the company creating it. 'seller' is initially empty.
        contracts[id] = Contract({
            id: id,
            contractType: ContractType.Request,
            parentRequestId: 0,
            seller: address(0), // No single seller for a request
            sellerName: "",
            buyer: msg.sender, // The company is the buyer
            buyerName: _buyerName,
            status: ContractStatus.Pending, // Open for commitments
            crop: _crop, // This holds the TOTAL requested quantity/price target
            creationTimestamp: block.timestamp,
            agreementTimestamp: 0,
            deliveryDeadlineTimestamp: _deliveryDeadlineTimestamp,
            insuranceDetails: _insuranceDetails
        });

        contractsAsBuyer[msg.sender].push(id); // Track request for the company

        emit ContractCreated(id, ContractType.Request, msg.sender, 0);
        return id;
    }

    // Scenario 2: Farmer commits to fulfilling part of a Company's Request
    function submitCommitment(
        uint _requestId,
        string calldata _farmerName,
        uint _quantityToSupply, // Quantity this farmer commits to
        string calldata _insuranceDetails
    ) external returns (uint) {
        Contract storage requestContract = contracts[_requestId];
        require(requestContract.id != 0, "Request does not exist"); // Basic check
        require(requestContract.contractType == ContractType.Request, "Parent ID is not a Request");
        require(requestContract.status == ContractStatus.Pending, "Request is not open for commitments"); // Ensure request is still active
        require(_quantityToSupply > 0, "Quantity must be positive");
        require(bytes(_farmerName).length > 0, "Farmer name required");

        uint id = ++contractCounter;
        // Create a new Commitment contract
        contracts[id] = Contract({
            id: id,
            contractType: ContractType.Commitment,
            parentRequestId: _requestId,
            seller: msg.sender, // The farmer committing
            sellerName: _farmerName,
            buyer: requestContract.buyer, // The company that made the request
            buyerName: requestContract.buyerName,
            status: ContractStatus.Pending, // Awaiting company approval
            crop: Crop({ // Use details from request, but specific quantity
                name: requestContract.crop.name,
                quantity: _quantityToSupply, // Farmer's specific quantity
                unit: requestContract.crop.unit,
                pricePerUnit: requestContract.crop.pricePerUnit
            }),
            creationTimestamp: block.timestamp,
            agreementTimestamp: 0,
            deliveryDeadlineTimestamp: requestContract.deliveryDeadlineTimestamp,
            insuranceDetails: _insuranceDetails // the farmer can choose to accept company offered insurance,
            // or specify the one he already has, or even include both (comma seperated)
        });

        contractsAsSeller[msg.sender].push(id);
        commitmentsForRequest[_requestId].push(id); // Link commitment to request, it is list of committed farmers
        // attached to the id of parent contract created by the company

        emit ContractCreated(id, ContractType.Commitment, msg.sender, _requestId);
        emit CommitmentSubmitted(id, _requestId, msg.sender, _quantityToSupply);
        return id;
    }

    // Scenario 2: Company accepts a specific Farmer's Commitment
    function acceptCommitment(uint _commitmentId)
        external
        onlyBuyer(_commitmentId) // The buyer here is the company who owns the parent request
        inStatus(_commitmentId, ContractStatus.Pending)
    {
        require(contracts[_commitmentId].contractType == ContractType.Commitment, "Not a Commitment");
        Contract storage commitment = contracts[_commitmentId];

        commitment.status = ContractStatus.Agreed;
        commitment.agreementTimestamp = block.timestamp;

        emit ContractAgreed(_commitmentId, commitment.seller, commitment.buyer);
    }

    // Scenario 2: Company rejects a specific Farmer's Commitment
    function rejectCommitment(uint _commitmentId)
        external
        onlyBuyer(_commitmentId)
        inStatus(_commitmentId, ContractStatus.Pending)
    {
        require(contracts[_commitmentId].contractType == ContractType.Commitment, "Not a Commitment");
        contracts[_commitmentId].status = ContractStatus.Rejected; // update the status to being rejected
        emit CommitmentRejected(_commitmentId, msg.sender);
    }

    // --- Status Updates (Triggered by Off-Chain Events via UI) ---

    // Buyer (Company) confirms delivery
    function confirmDelivery(uint _contractId)
        external
        onlyBuyer(_contractId) // Only the recipient of goods can confirm
        inStatus(_contractId, ContractStatus.Agreed)
    {
        // Ensure it's an agreed Offer or Commitment, not a pending Request
        require(contracts[_contractId].contractType == ContractType.Offer || contracts[_contractId].contractType == ContractType.Commitment, "Cannot confirm delivery for this type");

        contracts[_contractId].status = ContractStatus.DeliveryConfirmed;
        emit DeliveryConfirmed(_contractId, msg.sender);
    }

    // Seller (Farmer) confirms off-chain payment received
    function confirmPaymentReceived(uint _contractId)
        external
        onlySeller(_contractId) // Only the provider of goods confirms payment
        inStatus(_contractId, ContractStatus.DeliveryConfirmed)
    {
        // Ensure it's an agreed Offer or Commitment
        require(contracts[_contractId].contractType == ContractType.Offer || contracts[_contractId].contractType == ContractType.Commitment, "Cannot confirm payment for this type");

        contracts[_contractId].status = ContractStatus.PaymentConfirmed;
        contracts[_contractId].status = ContractStatus.Completed;
        emit PaymentConfirmed(_contractId, msg.sender);
        emit ContractCompleted(_contractId);
    }

    // Function to cancel before agreement
    function cancelContract(uint _contractId) external onlyParty(_contractId) {
        Contract storage contractRef = contracts[_contractId];
        // Allow cancellation only if Pending
        require(contractRef.status == ContractStatus.Pending, "Can only cancel pending contracts");

        if (contractRef.contractType == ContractType.Request && contractRef.buyer == msg.sender) {
            // Company cancels entire request
            contractRef.status = ContractStatus.Cancelled;
        } else if (contractRef.contractType == ContractType.Offer && (contractRef.seller == msg.sender)) {
            // Farmer cancels the offer
            contractRef.status = ContractStatus.Cancelled;
        } else if (contractRef.contractType == ContractType.Commitment && (contractRef.seller == msg.sender)) {
            // Farmer withdraws commitment
            contractRef.status = ContractStatus.Cancelled;
        } else {
            revert("Cancellation condition not met");
        }

        emit ContractCancelled(_contractId, msg.sender);
    }


    // --- View Functions ---
    function getContract(uint _contractId) external view returns (Contract memory) {
        require(contracts[_contractId].id != 0, "Contract does not exist");
        return contracts[_contractId];
    }
    
    // gets all the commitements for a contract issued by a company
    function getCommitmentsForRequest(uint _requestId) external view returns (uint[] memory) {
        require(contracts[_requestId].contractType == ContractType.Request, "Not a Request contract");
        return commitmentsForRequest[_requestId];
    }

    // returns all contracts linked to a farmer
    function getContractsForSeller(address _seller) external view returns (uint[] memory) {
        return contractsAsSeller[_seller];
    }

    // returns all contracts linked to a company
    function getContractsForBuyer(address _buyer) external view returns (uint[] memory) {
        return contractsAsBuyer[_buyer];
    }
}