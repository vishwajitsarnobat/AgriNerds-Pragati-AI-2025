// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Marketplace {
    string public name;
    uint public contractCount = 0;
    mapping(uint => Contract) public contracts;

    struct Contract {
        uint id;
        uint status;
        // 0 -> expired
        // 1 -> initiated, but not accepted yet
        // 2 -> ongoing
        // 3 -> completed
        Crop crop;
        Owner owner;
        Promisee promisee;
        uint256 creationTime;
        string date;
        string insurance;
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

    event contractCreated (
        uint id,
        string crop,
        uint quantity,
        string unit,
        uint price,
        uint status,
        address owner,
        string ownerName,
        address promisee,
        string promiseeName,
        uint256 creationTime,
        string date,
        string insurance
    );


    constructor() public {
        name = "AgriNerds Marketplace";
    }

    struct ContractInputData {
        string crop;
        uint quantity;
        string unit;
        uint price;
        string ownerName;
        string date; // Expecting "DDMMYYYY"
        string insurance;
    }

    function createContract(ContractInputData memory _input) public {
        // check parameters first
        
        require(_input.quantity > 0, "Quantity must be greater than zero");
        require(_input.price > 0, "Price must be greater than zero");
        require(bytes(_input.date).length == 8, "Invalid date format: requires 8 chars (DDMMYYYY)");

        // create contract
        uint contractId = contractCount;
        uint256 currTime = block.timestamp;

        Contract memory newContract;

        newContract.id = contractId;
        newContract.crop = _input.crop;
        newContract.quantity = _input.quantity;
        newContract.unit = _input.unit;
        newContract.price = _input.price;
        newContract.status = 1;
        newContract.owner = msg.sender;
        newContract.ownerName = _input.ownerName;
        newContract.promisee = address(0);
        newContract.promiseeName = '';
        newContract.creationTime = currTime;
        newContract.date = _input.date;
        newContract.insurance = _input.insurance;

        contracts[contractId] = newContract;

        // increase contractCount
        contractCount++;

        // event
        emit contractCreated(contractCount, _input.crop, _input.quantity, _input.unit, _input.price, 1, msg.sender, _input.ownerName, address(0), 'null', currTime, _input.date, _input.insurance);
    }
}