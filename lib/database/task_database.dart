import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task_model.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);
  return await openDatabase(
    path,
    version: 2, // 👉 tăng version để trigger onUpgrade
    onCreate: _createDB,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute("ALTER TABLE tasks ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0");
      }
    },
  );
}


  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    category TEXT,
    dueDate TEXT,
    time TEXT,
    reminder TEXT,
    notes TEXT,
    isCompleted INTEGER
  )
''');
  }

  // Tạo task mới
 Future<Task> create(Task task) async {
  final db = await instance.database;

  final id = await db.insert('tasks', task.toMap());
  return task.copy(id: id); // Cập nhật id mới
}


  // Lấy danh sách tất cả task
  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => Task.fromJson(json)).toList();
  }

  // Cập nhật task
  Future<int> update(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Đóng database
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Xoá task theo ID
  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getTasksByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'dueDate = ?',
      whereArgs: [date],
    );

    return result.map((json) => Task.fromJson(json)).toList();
  }
  Future<List<Task>> getCompletedTasksByDate(String date) async {
  final db = await instance.database;
  final result = await db.query(
    'tasks',
    where: 'dueDate = ? AND isCompleted = 1',
    whereArgs: [date],
  );
  return result.map((json) => Task.fromJson(json)).toList();
}

}
