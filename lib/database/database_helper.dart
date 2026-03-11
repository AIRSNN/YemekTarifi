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
    // Veritabanı şeması değiştiği için v2'ye geçtik. Temiz bir DB oluşacak.
    _database = await _initDB('yemek_kitabi_v2.db');
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
        onCreate: _createDB,
      ),
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';

    await db.execute('''
    CREATE TABLE recipes (
      id $idType,
      title $textType,
      category $textType,
      ingredients $textType,
      instructions $textType,
      image_name $textNullable,
      created_at $textType
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