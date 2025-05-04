import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  static Database? _database;
  static const String _tableName = 'images';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'images.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<String> storeImage(File imageFile) async {
    final db = await database;
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = join(appDir.path, 'images', fileName);
    
    // Create images directory if it doesn't exist
    await Directory(join(appDir.path, 'images')).create(recursive: true);
    
    // Copy the image to app directory
    await imageFile.copy(filePath);
    
    // Store the path in database
    await db.insert(_tableName, {
      'image_path': filePath,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    
    return filePath;
  }

  Future<String?> getImagePath(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return maps.first['image_path'] as String;
    }
    return null;
  }

  Future<void> deleteImage(int id) async {
    final db = await database;
    final String? imagePath = await getImagePath(id);
    
    if (imagePath != null) {
      // Delete file from storage
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Delete record from database
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
} 