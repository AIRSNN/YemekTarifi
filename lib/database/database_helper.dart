import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/recipe_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const bool isLocalMode = true;
  static const String webBaseUrl = "https://www.sinankurtoglu.com/yemek_resimleri/";

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yemek_kitabi_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;

    final docDirPath = await getApplicationDocumentsDirectory();
    final dbPath = join(docDirPath.path, 'YemekKitabiApp', 'Database', fileName);

    final dbFolder = Directory(dirname(dbPath));
    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: _onConfigure,
        onCreate: _createDB,
      ),
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        short_description TEXT,
        category TEXT NOT NULL,
        ingredients TEXT,
        instructions TEXT,
        cover_image TEXT,
        prep_time INTEGER,
        cook_time INTEGER,
        servings INTEGER,
        difficulty TEXT,
        tags TEXT,
        is_favorite INTEGER DEFAULT 0,
        rating_score REAL,
        review_count INTEGER DEFAULT 0,
        calories INTEGER,
        protein TEXT,
        fat TEXT,
        carbs TEXT,
        is_daily_special INTEGER DEFAULT 0,
        view_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        step_number INTEGER,
        instruction_text TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_gallery (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        image_path TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sponsor_equipments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        equipment_name TEXT NOT NULL,
        equipment_image TEXT,
        purpose_description TEXT,
        affiliate_url TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> createRecipe(Recipe recipe) async {
    final db = await instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> readAllRecipes() async {
    final db = await instance.database;
    final result = await db.query('recipes', orderBy: 'created_at DESC');
    return result.map((json) => Recipe.fromMap(json)).toList();
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await instance.database;
    return db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await instance.database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> getImagePath(String imageName) async {
    if (isLocalMode) {
      final docDirPath = await getApplicationDocumentsDirectory();
      return join(docDirPath.path, 'YemekKitabiApp', 'Images', imageName);
    } else {
      return "$webBaseUrl$imageName";
    }
  }

  Future<String> saveImageLocally(File sourceFile) async {
    final docDirPath = await getApplicationDocumentsDirectory();
    final imageFolder = Directory(join(docDirPath.path, 'YemekKitabiApp', 'Images'));

    if (!await imageFolder.exists()) {
      await imageFolder.create(recursive: true);
    }

    final fileName = basename(sourceFile.path);
    final destinationPath = join(imageFolder.path, fileName);

    await sourceFile.copy(destinationPath);
    return fileName;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
