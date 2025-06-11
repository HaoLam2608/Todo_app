// lib/database/task_database.dart
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
      version: 3, // Tăng version lên 3 để thêm user_id
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE tasks ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0",
          );
        }
        if (oldVersion < 3) {
          // Thêm cột user_id
          await db.execute(
            "ALTER TABLE tasks ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0",
          );
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
    isCompleted INTEGER,
    user_id INTEGER NOT NULL,
    completionTime DateTime default NULL
  )
''');
  }

  // Tạo task mới - thêm user_id
  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copy(id: id);
  }

  // Lấy danh sách tất cả task của một user cụ thể
  Future<List<Task>> getTasksByUserId(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((json) => Task.fromJson(json)).toList();
  }

  // Các phương thức khác giữ nguyên
  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future<int> update(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Cập nhật để lọc theo user_id
  Future<List<Task>> getTasksByDate(String date, int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'dueDate = ? AND user_id = ?',
      whereArgs: [date, userId],
    );
    return result.map((json) => Task.fromJson(json)).toList();
  }

  // Cập nhật để lọc theo user_id
  Future<List<Task>> getCompletedTasksByDate(String date, int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'dueDate = ? AND isCompleted = 1 AND user_id = ?',
      whereArgs: [date, userId],
    );
    return result.map((json) => Task.fromJson(json)).toList();
  }

  // Trong task_database.dart
  Future<List<Task>> getTasksByUserIdAndDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND dueDate BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );
    return result.map((json) => Task.fromJson(json)).toList();
  }
}
