import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/contract.dart';
import 'services/contract_service.dart';
import 'widgets/contract_card.dart';
import 'widgets/contract_form.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContractService _contractService = ContractService();
  List<Contract> _myContracts = [];
  List<Contract> _availableContracts = [];
  bool _isLoading = true;
  final String _currentUserId = 'user1'; // This should come from your auth system

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContracts();
    _createSampleContracts();
  }

  Future<void> _createSampleContracts() async {
    final sampleContracts = [
      Contract(
        id: const Uuid().v4(),
        title: 'Wheat Harvest Contract',
        description: 'Looking for experienced farmers to harvest 100 acres of wheat. Must have own equipment.',
        cropType: 'Wheat',
        quantity: 100,
        unit: 'acres',
        pricePerUnit: 500,
        location: 'Punjab',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        createdBy: 'sample_user1',
        createdAt: DateTime.now(),
        applicants: [],
        isActive: true,
      ),
      Contract(
        id: const Uuid().v4(),
        title: 'Rice Cultivation Contract',
        description: 'Need farmers for organic rice cultivation. Experience in organic farming preferred.',
        cropType: 'Rice',
        quantity: 50,
        unit: 'acres',
        pricePerUnit: 800,
        location: 'West Bengal',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 120)),
        createdBy: 'sample_user2',
        createdAt: DateTime.now(),
        applicants: [],
        isActive: true,
      ),
      Contract(
        id: const Uuid().v4(),
        title: 'Cotton Farming Contract',
        description: 'Contract for cotton farming with guaranteed buyback. Technical support provided.',
        cropType: 'Cotton',
        quantity: 75,
        unit: 'acres',
        pricePerUnit: 600,
        location: 'Gujarat',
        startDate: DateTime.now().add(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 180)),
        createdBy: 'sample_user3',
        createdAt: DateTime.now(),
        applicants: [],
        isActive: true,
      ),
    ];

    for (final contract in sampleContracts) {
      try {
        await _contractService.insertContract(contract);
      } catch (e) {
        // Ignore errors for duplicate contracts
      }
    }
  }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);
    try {
      final myContracts = await _contractService.getMyContracts(_currentUserId);
      final availableContracts = await _contractService.getAvailableContracts(_currentUserId);
      if (!mounted) return;
      setState(() {
        _myContracts = myContracts;
        _availableContracts = availableContracts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contracts: $e')),
      );
    }
  }

  Future<void> _createContract(Contract contract) async {
    try {
      await _contractService.insertContract(contract);
      await _loadContracts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contract created successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating contract: $e')),
      );
    }
  }

  Future<void> _applyForContract(String contractId) async {
    try {
      await _contractService.applyForContract(contractId, _currentUserId);
      await _loadContracts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Applied for contract successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying for contract: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contracts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Contracts'),
            Tab(text: 'Available Contracts'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildContractsList(_myContracts, isMyContracts: true),
                _buildContractsList(_availableContracts, isMyContracts: false),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateContractDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContractsList(List<Contract> contracts, {required bool isMyContracts}) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isMyContracts
                  ? 'No contracts created yet'
                  : 'No available contracts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!isMyContracts) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createSampleContracts,
                child: const Text('Load Sample Contracts'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContracts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return Dismissible(
            key: Key(contract.id),
            direction: isMyContracts ? DismissDirection.endToStart : DismissDirection.none,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: isMyContracts ? (_) => _deleteContract(contract.id) : null,
            child: ContractCard(
              contract: contract,
              onApply: isMyContracts ? null : () => _applyForContract(contract.id),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateContractDialog() async {
    final result = await showDialog<Contract>(
      context: context,
      builder: (context) => Dialog(
        child: ContractForm(
          onSubmit: (contract) {
            Navigator.of(context).pop(contract);
          },
        ),
      ),
    );

    if (result != null) {
      final contract = result.copyWith(
        id: const Uuid().v4(),
        createdBy: _currentUserId,
        createdAt: DateTime.now(),
        isActive: true,
      );
      await _createContract(contract);
    }
  }

  Future<void> _deleteContract(String contractId) async {
    try {
      await _contractService.deleteContract(contractId);
      await _loadContracts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contract deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting contract: $e')),
      );
    }
  }
} 