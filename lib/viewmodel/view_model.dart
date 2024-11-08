
// view_model/item_view_model.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../model/itemModel.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ItemViewModel extends ChangeNotifier {
  List<Item> _items = [];
  Database? _database;
  final textEditingController = TextEditingController();
  final quantEditingController = TextEditingController();

  List<Item> get items => _items;

  Future<void> loadItems() async {
    if (_database == null) {
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      }
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'items.db');

      _database = await openDatabase(
        path,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT, quantity INTEGER, bought INTEGER)',
          );
        },
        version: 1,
      );
    }

    // Carregar itens do banco de dados
    final List<Map<String, dynamic>> maps = await _database!.query('items');
    _items = List.generate(maps.length, (i) => Item.fromMap(maps[i]));
    notifyListeners();
  }

  void addItem() async {
    if (textEditingController.text.isNotEmpty && quantEditingController.text.isNotEmpty) {
      int quantity = int.tryParse(quantEditingController.text) ?? 1;
      Item newItem = Item(name: textEditingController.text, quantity: quantity);
      if (_database != null) {
        newItem.id = await _database!.insert('items', newItem.toMap());
        _items.add(newItem);
        textEditingController.clear();
        quantEditingController.clear();
        notifyListeners();
      } else {
        throw Exception('Banco de dados não inicializado');
      }
    }
  }

  void updateItem(Item item) async {
    if (textEditingController.text.isNotEmpty && quantEditingController.text.isNotEmpty) {
      item.name = textEditingController.text;
      item.quantity = int.tryParse(quantEditingController.text) ?? 1;
      if (_database != null) {
        await _database!.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
        final index = _items.indexWhere((e) => e.id == item.id);
        if (index != -1) {
          _items[index] = item;
        }
        textEditingController.clear();
        quantEditingController.clear();
        notifyListeners();
      } else {
        throw Exception('Banco de dados não inicializado');
      }
    }
  }

  void deleteItem(Item item) async {
    if (_database != null) {
      await _database!.delete('items', where: 'id = ?', whereArgs: [item.id]);
      _items.removeWhere((e) => e.id == item.id);
      notifyListeners();
    } else {
      throw Exception('Banco de dados não inicializado');
    }
  }

  void toggleBoughtStatus(Item item) async {
    if (_database != null) {
      item.bought = !item.bought;
      await _database!.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
      notifyListeners();
    } else {
      throw Exception('Banco de dados não inicializado');
    }
  }

  void generatePDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.TableHelper.fromTextArray(
            headers: ['Item', 'Quantidade', 'Comprado'],
            data: _items.map((item) => [
              item.name,
              item.quantity.toString(),
              item.bought ? 'SIM' : 'NÃO'
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            cellStyle: pw.TextStyle(fontSize: 12),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
            },
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}