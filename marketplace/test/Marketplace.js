const { assert } = require("chai")

const Marketplace = artifacts.require('./Marketplace.sol')

contract('Marketplace', (accounts) => {
    let marketplace

    before(async () => {
        marketplace = await Marketplace.deployed()
    })
    
    describe('deployment', async () => {
        it('deployment', async () => {
            const address = await marketplace.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })
    })

    it('has correct name', async () => {
        const name = await marketplace.name()
        assert.equal(name, "AgriNerds Marketplace") 
    })

    describe('contract', async () => {
        let testContract;

        const initContractCount = await marketplace.contractCount();

        before(async () => {
            testContract = await marketplace.createContract('potato', 23, 'tonnes', 34000, 'Pepsico', 12, 7, 2025, 'PM Fasal Vima Yojana');
        })

        it('is contractCount increased', async () => {
            const newContractCount = marketplace.contractCount();
            assert.notEqual(newContractCount - initContractCount, 0);
        })

        it('is contract created properly', async() => {
            assert.notEqual(testContract.crop(), '');
            assert(testContract.quantity() > 0);
            assert.notEqual(testContract.unit(), '');
            assert(testContract.price() > 0);
            assert(testContract.status() == 1);
            assert.notEqual(testContract.owner(), 0x0);
            assert.notEqual(ownerName, '');
            assert(creationTime > 0);
            assert.notEqual(testContract.date.day(), '');
            assert.notEqual(insurance, '');
        })
    })

    it('has correct name', async () => {
        const name = await marketplace.name()
        assert.equal(name, "AgriNerds Marketplace") 
    })
})