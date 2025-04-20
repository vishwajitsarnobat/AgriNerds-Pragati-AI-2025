// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Marketplace {
    string public name;
    uint public ownerContractCount = 0;
    uint public promiseeContractCount = 0;
    mapping(uint => Contract) public ownerContracts;
    mapping(uint => Contract) public promiseeContracts; // this is because when company issues contract, it will be shared among multiple farmers
    // so promisee contracts will keep track of it through parentId parameter

    struct Contract {
        uint id;
        int parentId;
        uint status;
        // 0 -> expired
        // 1 -> initiated, but not accepted yet
        // 2 -> ongoing (will represent it is accepted)
        // 3 -> completed
        Crop crop;
        Owner owner;
        Promisee promisee;
        uint256 creationTime;
        Date date;
        string insurance; // company will include if they are providing any, farmers will include if they have any
    }

    struct Owner {
        address owner; // the one who initiates the contract
        string name;
    }

    struct Promisee {
        address promisee; // the one who accepts the contract
        string name;
    }

    struct Crop {
        string crop;
        uint quantity; // quantity in units
        string unit; // unit for quantity (tonnes, kilos, dozens, etc.)
        uint price; // price per defined unit
    }

    struct Date {
        uint day;
        uint month;
        uint year;
    }

    event contractCreated (
        uint id,
        string crop,
        address owner,
        string name,
        uint256 creationTime,
        Date date,
        string insurance
    );


    constructor() {
        name = "AgriNerds Marketplace";
    }

    // this can be created by either farmer or company
    function createContract(Crop memory _crop, string memory _ownerName, Date memory _date, string memory _insurance) external {
        // check parameters first
        require(_crop.price > 0 && (bytes(_crop.unit).length != 0 || bytes(_crop.crop).length != 0), "Invalid crop information");
        require(_date.day > 0 && _date.month > 0 && _date.year > 0, "Invalid date");

        // create owner
        Owner memory _owner = Owner({
            owner: msg.sender,
            name: _ownerName
        });

        // create contract
        uint contractId = ownerContractCount;
        uint256 currTime = block.timestamp;

        ownerContracts[contractId] = Contract(contractId, -1, 1, _crop, _owner, Promisee(address(0), ''), currTime, _date, _insurance);

        // increase ownerContractCount
        ownerContractCount++;

        // event
        emit contractCreated(contractId, _crop.crop, _owner.owner, _owner.name, currTime, _date, _insurance);
    }

    // farmer if he wants to accept the contract
    function farmerSignCompanyContract(string memory _promiseeName, uint _contractId, uint _cropQuantity) external {
        require(msg.sender == ownerContracts[_contractId].owner.owner, "Cannot sign own contract");
        require(msg.sender != address(0), "Invalid promisee address");
        require(_cropQuantity > 0, "Crop quantity cannot be negative");
        
        // create promisee
        Promisee memory _promisee = Promisee({
            promisee: msg.sender, 
            name: _promiseeName
        });

        uint currTime = block.timestamp;
        uint promiseeContractId = promiseeContractCount;
        promiseeContractCount++;

        // create contract
        Contract memory _contract = ownerContracts[_contractId];
        _contract.parentId = int(_contractId); // parent id will be id of owner contract
        _contract.id = promiseeContractId;
        _contract.promisee = _promisee;
        _contract.creationTime = currTime;
        _contract.crop.quantity = _cropQuantity; // farmer will choose how much of the quantity he can supply

        // insert the created contract in promisee contracts
        promiseeContracts[promiseeContractId] = _contract;
    }

    // company accepts a farmer created contract
    function companySignFarmerContract(string memory _promiseeName, uint _contractId) external {
        require(msg.sender != ownerContracts[_contractId].owner.owner, "Cannot sign own contract");
        require(msg.sender != address(0), "Invalid promisee address");

        // create promisee
        Promisee memory _promisee = Promisee({
            promisee: msg.sender, 
            name: _promiseeName
        });

        uint currTime = block.timestamp;
        uint promiseeContractId = promiseeContractCount;
        promiseeContractCount++;

        Contract memory _contract = ownerContracts[_contractId];
        _contract.parentId = int(_contractId); // parent id will be id of owner contract
        _contract.id = promiseeContractId;
        _contract.promisee = _promisee;
        _contract.creationTime = currTime;
        _contract.status = 2; // since both the parties have agreed, the contract is finalized and status changes

        // insert the created contract in promisee contracts
        promiseeContracts[promiseeContractId] = _contract;        
    }

    // company reviews and accepts application for their contract
    function companyAcceptFarmerApplication(uint _contractId) external {
        require(msg.sender == ownerContracts[_contractId].owner.owner, "Only owner company can accept the application");

        ownerContracts[_contractId].status = 2; // both parties agree and hence the contract begins
    }

    function companyRejectFarmerApplication(uint _contractId) external {
        require(msg.sender == ownerContracts[_contractId].owner.owner, "Only owner company can accept the application");

        ownerContracts[_contractId].status = 0; // since the company want to reject, the contract expires
    }
}