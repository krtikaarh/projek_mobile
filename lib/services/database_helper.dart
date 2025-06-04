import 'dart:convert';
import 'dart:io';
import 'package:projek/models/recipe_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE resep_lokal (
        id $idType,
        nama $textType,
        kategori $textType,
        area $textType,
        deskripsi $textType,
        bahan $textType,
        imagePath $textType,
        isFavorite $intType
      )
    ''');

    await db.execute('''
      CREATE TABLE favorit_api (
        idMeal $textType PRIMARY KEY,
        strMeal $textType,
        strMealThumb $textType,
        strCategory $textType,
        strArea $textType
      )
    ''');
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
      columns: [
        'id',
        'nama',
        'kategori',
        'area',
        'deskripsi',
        'bahan',
        'imagePath',
        'isFavorite',
      ],
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

  Future<int> toggleFavoritResepLokal(int id, int isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'resep_lokal',
      {'isFavorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD untuk Favorit API
  Future<int> addFavoritApi(Meal meal) async {
    final db = await instance.database;
    return await db.insert('favorit_api', {
      'idMeal': meal.idMeal,
      'strMeal': meal.strMeal,
      'strMealThumb': meal.strMealThumb,
      'strCategory': meal.strCategory,
      'strArea': meal.strArea,
    });
  }

  Future<int> removeFavoritApi(String idMeal) async {
    final db = await instance.database;
    return await db.delete(
      'favorit_api',
      where: 'idMeal = ?',
      whereArgs: [idMeal],
    );
  }

  Future<List<Map<String, dynamic>>> getFavoritApi() async {
    final db = await instance.database;
    return await db.query('favorit_api', orderBy: 'strMeal ASC');
  }

  Future<bool> isFavoritApi(String idMeal) async {
    final db = await instance.database;
    final result = await db.query(
      'favorit_api',
      where: 'idMeal = ?',
      whereArgs: [idMeal],
    );
    return result.isNotEmpty;
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
