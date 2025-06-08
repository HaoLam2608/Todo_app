import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    ); // Tăng version lên 7
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        avatarPath TEXT,
        themePreference TEXT,
        language TEXT,
        backgroundImagePath TEXT,
        joinDate TEXT,
        completedTasks INTEGER,
        isNotificationsEnabled INTEGER DEFAULT 1 -- Thêm cột mới, mặc định là true (1)
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE users ADD COLUMN avatarPath TEXT');
      }
      if (oldVersion < 3) {
        await db.execute('ALTER TABLE users ADD COLUMN themePreference TEXT');
      }
      if (oldVersion < 4) {
        await db.execute('ALTER TABLE users ADD COLUMN language TEXT');
      }
      if (oldVersion < 5) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN backgroundImagePath TEXT',
        );
      }
      if (oldVersion < 6) {
        await db.execute('ALTER TABLE users ADD COLUMN joinDate TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN completedTasks INTEGER');
      }
      if (oldVersion < 7) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN isNotificationsEnabled INTEGER DEFAULT 1',
        ); // Thêm cột mới
      }
    } catch (e) {
      if (e.toString().contains('duplicate column')) {
        print('Duplicate column ignored: $e');
      } else {
        rethrow;
      }
    }
  }

  Future<int> registerUser(UserModel user) async {
    final db = await instance.database;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(user.email)) {
      throw Exception('Invalid email format.');
    }
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
    );
    if (!passwordRegex.hasMatch(user.password)) {
      throw Exception(
        'Password must be at least 8 characters, including uppercase, lowercase, numbers, and special characters.',
      );
    }
    final userMap = user.toMap();
    userMap['joinDate'] = DateTime.now().toIso8601String();
    userMap['completedTasks'] = 0;
    return await db.insert('users', userMap);
  }

  Future<bool> isEmailExist(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<UserModel?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromJson(result.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<int> updateUser(
    int id,
    String username,
    String email,
    String password,
    String? avatarPath,
    String? backgroundImagePath,
    String? themePreference,
    String? language,
    String? joinDate,
    int? completedTasks,
    bool? isNotificationsEnabled, // Thêm tham số
  ) async {
    final db = await instance.database;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Invalid email format.');
    }
    if (password.isNotEmpty) {
      final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
      );
      if (!passwordRegex.hasMatch(password)) {
        throw Exception(
          'Password must be at least 8 characters, including uppercase, lowercase, numbers, and special characters.',
        );
      }
    }
    final existingEmail = await db.query(
      'users',
      where: 'email = ? AND id != ?',
      whereArgs: [email, id],
    );
    if (existingEmail.isNotEmpty) {
      throw Exception('Email is already in use.');
    }
    return await db.update(
      'users',
      {
        'username': username,
        'email': email,
        'password': password,
        'avatarPath': avatarPath,
        'backgroundImagePath': backgroundImagePath,
        'themePreference': themePreference,
        'language': language,
        'joinDate': joinDate,
        'completedTasks': completedTasks,
        'isNotificationsEnabled':
            isNotificationsEnabled == true
                ? 1
                : 0, // Chuyển boolean sang INTEGER (1/0)
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserAvatar(int id, String avatarPath) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'avatarPath': avatarPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserBackground(int id, String backgroundImagePath) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'backgroundImagePath': backgroundImagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserTheme(int id, String themePreference) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'themePreference': themePreference},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserLanguage(int id, String language) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'language': language},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserTasks(int id, int completedTasks) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'completedTasks': completedTasks},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
