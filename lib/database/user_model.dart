class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? avatarPath; // Thêm trường avatarPath

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.avatarPath,
  });

  // Convert object -> map (lưu vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'avatarPath': avatarPath, // Thêm avatarPath
    };
  }

  // Convert map -> object (lấy từ database)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      avatarPath: json['avatarPath'], // Thêm avatarPath
    );
  }

  // Copy để tạo phiên bản mới nếu cần thay đổi
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? avatarPath,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}