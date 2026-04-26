import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../../core/utils/constants.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.productsTable} (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        discountPercentage REAL DEFAULT 0,
        rating REAL DEFAULT 0,
        stock INTEGER DEFAULT 0,
        brand TEXT,
        category TEXT,
        thumbnail TEXT,
        images TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.cartTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        discountPercentage REAL DEFAULT 0,
        thumbnail TEXT,
        quantity INTEGER NOT NULL DEFAULT 1,
        brand TEXT,
        category TEXT,
        description TEXT,
        rating REAL DEFAULT 0,
        stock INTEGER DEFAULT 0,
        images TEXT
      )
    ''');
  }
}
