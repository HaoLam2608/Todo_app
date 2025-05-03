import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_model.dart';

class SessionManager {
  static const String USER_ID_KEY = 'user_id';
  static const String USERNAME_KEY = 'username';
  static const String EMAIL_KEY = 'email';
  static const String AVATAR_PATH_KEY = 'avatar_path';

  // Lưu thông tin người dùng đăng nhập
  static Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(USER_ID_KEY, user.id!);
    await prefs.setString(USERNAME_KEY, user.username);
    await prefs.setString(EMAIL_KEY, user.email);
    if (user.avatarPath != null) {
      await prefs.setString(AVATAR_PATH_KEY, user.avatarPath!);
    }
  }

  // Lấy ID của người dùng hiện tại
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(USER_ID_KEY);
  }

  // Lấy thông tin đầy đủ của người dùng hiện tại
  static Future<Map<String, dynamic>> getCurrentUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(USER_ID_KEY),
      'username': prefs.getString(USERNAME_KEY),
      'email': prefs.getString(EMAIL_KEY),
      'avatarPath': prefs.getString(AVATAR_PATH_KEY),
    };
  }

  // Kiểm tra xem người dùng đã đăng nhập chưa
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(USER_ID_KEY);
  }

  // Đăng xuất, xóa thông tin người dùng
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_ID_KEY);
    await prefs.remove(USERNAME_KEY);
    await prefs.remove(EMAIL_KEY);
    await prefs.remove(AVATAR_PATH_KEY);
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(
      'user',
    ); // Assuming you save user data as a JSON string
    if (userData != null) {
      return json.decode(userData); // Decode the JSON to a Map
    }
    return null; // Return null if no user data is found
  }
}
