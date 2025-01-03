import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Banco {
  static final Banco _instance = Banco._internal();
  factory Banco() => _instance;

  static Database? _database;
  static const String _tableName = 'tasks';

  Banco._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    print("Database Path: $path");
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      print("Criando a tabela $_tableName");
      await db.execute(''' 
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task TEXT,
          isChecked INTEGER
        )
      ''');

      print("Tabela $_tableName criada com sucesso!");
    });
  }

  String getTableName() {
    return _tableName;
  }

  Future<void> insertTask(String task, bool isChecked) async {
    final db = await database;
    print("Inserindo tarefa: $task, status: $isChecked");
    await db.insert(_tableName, {
      'task': task,
      'isChecked': isChecked ? 1 : 0,
    });
  }

  Future<void> updateTask(int id, bool isChecked) async {
    final db = await database;
    print("Atualizando tarefa ID: $id, status: $isChecked");
    await db.update(_tableName, {'isChecked': isChecked ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    print("Excluindo tarefa ID: $id");
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    final tasks = await db.query(_tableName);
    return tasks;
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final result = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }
}
