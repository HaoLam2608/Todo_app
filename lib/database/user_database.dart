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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  // Đăng ký tài khoản mới với kiểm tra định dạng email và mật khẩu mạnh
  Future<int> registerUser(UserModel user) async {
    final db = await instance.database;

    // Kiểm tra định dạng email hợp lệ
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(user.email)) {
      throw Exception('Email không hợp lệ.');
    }

    // Kiểm tra mật khẩu mạnh: ít nhất 8 ký tự, có chữ hoa, thường, số và ký tự đặc biệt
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
    );
    if (!passwordRegex.hasMatch(user.password)) {
      throw Exception(
        'Mật khẩu phải từ 8 ký tự trở lên, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.',
      );
    }

    // Chèn user nếu hợp lệ
    return await db.insert('users', user.toMap());
  }

  // Kiểm tra email đã tồn tại chưa
  Future<bool> isEmailExist(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Đăng nhập: lấy user theo email và password
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

  // Lấy danh sách tất cả user (không bắt buộc dùng)
  Future<List<UserModel>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((json) => UserModel.fromJson(json)).toList();
  }

  // Đóng database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
