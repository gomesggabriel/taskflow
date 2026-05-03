import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taskflow.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        data_prevista TEXT NOT NULL,
        importante INTEGER NOT NULL DEFAULT 0,
        realizada INTEGER NOT NULL DEFAULT 0,
        prioridade TEXT NOT NULL DEFAULT 'media'
      )
    ''');
  }

  Future<Task> create(Task task) async {
    final db = await database;
    final id = await db.insert('tarefas', task.toMap());
    return task.copyWith(id: id);
  }

  Future<Task?> readTask(int id) async {
    final db = await database;
    final maps = await db.query(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Task.fromMap(maps.first);
    return null;
  }

  Future<List<Task>> readAllTasks() async {
    final db = await database;
    final result = await db.query('tarefas', orderBy: 'data_prevista ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> update(Task task) async {
    final db = await database;
    return db.update(
      'tarefas',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
