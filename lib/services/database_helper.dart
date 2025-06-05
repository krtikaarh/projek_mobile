import 'dart:convert';
import 'package:projek/models/recipe_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('resep_lokal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL DEFAULT 0';

    await db.execute('''
      CREATE TABLE resep_lokal (
        id $idType,
        nama $textType,
        kategori $textType,
        area $textType,
        deskripsi $textType,
        bahan $textType,
        isFavorite $intType
      )
    ''');

    await db.execute('''
      CREATE TABLE favorit_api (
        idMeal TEXT PRIMARY KEY,
        strMeal TEXT,
        strCategory TEXT,
        strArea TEXT,
        strMealThumb TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE resep_lokal ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorit_api (
          idMeal TEXT PRIMARY KEY,
          strMeal TEXT,
          strCategory TEXT,
          strArea TEXT,
          strMealThumb TEXT
        )
      ''');
    }
  }

  // CRUD untuk Resep Lokal
  Future<int> createResepLokal(ResepLokal resep) async {
    final db = await instance.database;
    return await db.insert('resep_lokal', resep.toMap());
  }

  Future<List<ResepLokal>> readAllResepLokal() async {
    final db = await instance.database;
    const orderBy = 'nama ASC';
    final result = await db.query('resep_lokal', orderBy: orderBy);

    return result.map((json) => ResepLokal.fromMap(json)).toList();
  }

  Future<ResepLokal?> readResepLokal(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'resep_lokal',
      columns: ['id', 'nama', 'kategori', 'area', 'deskripsi', 'bahan'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ResepLokal.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateResepLokal(ResepLokal resep) async {
    final db = await instance.database;
    return db.update(
      'resep_lokal',
      resep.toMap(),
      where: 'id = ?',
      whereArgs: [resep.id],
    );
  }

  Future<int> deleteResepLokal(int id) async {
    final db = await instance.database;
    return await db.delete('resep_lokal', where: 'id = ?', whereArgs: [id]);
  }

  // USER AUTH SECTION - SharedPreferences Only

  // Register user, return true jika sukses, false jika username sudah ada
  Future<bool> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    List users = [];
    if (usersJson != null) {
      users = jsonDecode(usersJson);
      if (users.any((u) => u['username'] == username)) {
        // Username sudah digunakan
        return false;
      }
    }
    users.add({'username': username, 'password': password});
    await prefs.setString('users', jsonEncode(users));
    return true;
  }

  // Login user, return true jika sukses, false jika gagal
  Future<bool> loginUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) return false;
    final users = jsonDecode(usersJson) as List;
    final user = users.firstWhere(
      (u) => u['username'] == username && u['password'] == password,
      orElse: () => null,
    );
    if (user != null) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUsername', username);
      return true;
    }
    return false;
  }

  // Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Ambil username yang sedang login
  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      return prefs.getString('loggedInUsername');
    }
    return null;
  }

  // Logout user
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('loggedInUsername');
  }

  // Hapus database (untuk development/testing)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resep_lokal.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Favorit API
  Future<void> addFavoritApi(Meal meal) async {
    final db = await instance.database;
    await db.insert(
      'favorit_api',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavoritApi(String idMeal) async {
    final db = await instance.database;
    await db.delete('favorit_api', where: 'idMeal = ?', whereArgs: [idMeal]);
  }

  Future<List<Map<String, dynamic>>> getFavoritApi() async {
    final db = await instance.database;
    return await db.query('favorit_api');
  }

  // Favorit Lokal
  Future<void> toggleFavoritResepLokal(int id, int isFavorite) async {
    final db = await instance.database;
    await db.update(
      'resep_lokal',
      {'isFavorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ResepLokal>> getFavoritResepLokal() async {
    final db = await instance.database;
    final result = await db.query(
      'resep_lokal',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'nama ASC',
    );
    return result.map((json) => ResepLokal.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
