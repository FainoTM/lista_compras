import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/itemModel.dart';

class ItemRepository {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'shopping_list.db');
    print('Initializing database at path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        print('Creating items table');
        return db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT, quantity INTEGER, isPurchased INTEGER)',
        );
      },
    );
  }

  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    print('Item inserido: ${item.toMap()}');
  }

  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    print('Itens obtidos: ${maps.length}');
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    print('Item atualizado: ${item.toMap()}');
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    print('Item deletado com id: $id');
  }
}
