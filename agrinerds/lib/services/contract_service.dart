import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/contract.dart';

class ContractService {
  static final ContractService _instance = ContractService._internal();
  static Database? _database;
  static SharedPreferences? _prefs;

  factory ContractService() => _instance;

  ContractService._internal();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contracts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contracts(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        cropType TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        pricePerUnit REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        location TEXT NOT NULL,
        createdBy TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        applicants TEXT,
        selectedApplicant TEXT,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertContract(Contract contract) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final contracts = await _getContractsFromPrefs(prefs);
      contracts.add(contract);
      await _saveContractsToPrefs(prefs, contracts);
    } else {
      final db = await database;
      await db?.insert(
        'contracts',
        contract.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Contract>> getAllContracts() async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      return _getContractsFromPrefs(prefs);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db?.query('contracts') ?? [];
      return maps.map((map) => Contract.fromJson(map)).toList();
    }
  }

  Future<List<Contract>> getMyContracts(String userId) async {
    final allContracts = await getAllContracts();
    return allContracts.where((contract) => 
      contract.createdBy == userId || 
      contract.applicants.contains(userId)
    ).toList();
  }

  Future<List<Contract>> getAvailableContracts(String userId) async {
    final allContracts = await getAllContracts();
    return allContracts.where((contract) => 
      contract.createdBy != userId && 
      contract.isActive
    ).toList();
  }

  Future<void> applyForContract(String contractId, String userId) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final contracts = await _getContractsFromPrefs(prefs);
      final index = contracts.indexWhere((c) => c.id == contractId);
      if (index != -1 && !contracts[index].applicants.contains(userId)) {
        final updatedContract = contracts[index].copyWith(
          applicants: [...contracts[index].applicants, userId],
        );
        contracts[index] = updatedContract;
        await _saveContractsToPrefs(prefs, contracts);
      }
    } else {
      final db = await database;
      final contract = await getContractById(contractId);
      if (contract != null && !contract.applicants.contains(userId)) {
        final updatedContract = contract.copyWith(
          applicants: [...contract.applicants, userId],
        );
        await db?.update(
          'contracts',
          updatedContract.toJson(),
          where: 'id = ?',
          whereArgs: [contractId],
        );
      }
    }
  }

  Future<Contract?> getContractById(String id) async {
    final allContracts = await getAllContracts();
    try {
      return allContracts.firstWhere((contract) => contract.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateContract(Contract contract) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final contracts = await _getContractsFromPrefs(prefs);
      final index = contracts.indexWhere((c) => c.id == contract.id);
      if (index != -1) {
        contracts[index] = contract;
        await _saveContractsToPrefs(prefs, contracts);
      }
    } else {
      final db = await database;
      await db?.update(
        'contracts',
        contract.toJson(),
        where: 'id = ?',
        whereArgs: [contract.id],
      );
    }
  }

  Future<void> deleteContract(String id) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final contracts = await _getContractsFromPrefs(prefs);
      contracts.removeWhere((contract) => contract.id == id);
      await _saveContractsToPrefs(prefs, contracts);
    } else {
      final db = await database;
      await db?.delete(
        'contracts',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<Contract>> _getContractsFromPrefs(SharedPreferences prefs) async {
    final contractsJson = prefs.getStringList('contracts') ?? [];
    return contractsJson.map((json) => Contract.fromJson(Map<String, dynamic>.from(jsonDecode(json)))).toList();
  }

  Future<void> _saveContractsToPrefs(SharedPreferences prefs, List<Contract> contracts) async {
    final contractsJson = contracts.map((contract) => jsonEncode(contract.toJson())).toList();
    await prefs.setStringList('contracts', contractsJson);
  }
} 