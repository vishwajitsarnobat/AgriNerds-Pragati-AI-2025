import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contract.dart';

class ContractService {
  static final ContractService _instance = ContractService._internal();
  static Database? _database;

  factory ContractService() => _instance;

  ContractService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
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
    final db = await database;
    await db.insert(
      'contracts',
      contract.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contract>> getAllContracts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contracts');
    return maps.map((map) => Contract.fromJson(map)).toList();
  }

  Future<List<Contract>> getMyContracts(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contracts',
      where: 'createdBy = ? OR applicants LIKE ?',
      whereArgs: [userId, '%$userId%'],
    );
    return maps.map((map) => Contract.fromJson(map)).toList();
  }

  Future<List<Contract>> getAvailableContracts(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contracts',
      where: 'createdBy != ? AND isActive = ?',
      whereArgs: [userId, 1],
    );
    return maps.map((map) => Contract.fromJson(map)).toList();
  }

  Future<void> applyForContract(String contractId, String userId) async {
    final db = await database;
    final contract = await getContractById(contractId);
    if (contract != null && !contract.applicants.contains(userId)) {
      final updatedContract = contract.copyWith(
        applicants: [...contract.applicants, userId],
      );
      await db.update(
        'contracts',
        updatedContract.toJson(),
        where: 'id = ?',
        whereArgs: [contractId],
      );
    }
  }

  Future<Contract?> getContractById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contracts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contract.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateContract(Contract contract) async {
    final db = await database;
    await db.update(
      'contracts',
      contract.toJson(),
      where: 'id = ?',
      whereArgs: [contract.id],
    );
  }

  Future<void> deleteContract(String id) async {
    final db = await database;
    await db.delete(
      'contracts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 