class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? avatarPath;
  final String? themePreference;
  final String? language;
  final String? backgroundImagePath;
  final String? joinDate;
  final int? completedTasks;
  final bool? isNotificationsEnabled;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.avatarPath,
    this.themePreference,
    this.language,
    this.backgroundImagePath,
    this.joinDate,
    this.completedTasks,
    this.isNotificationsEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'avatarPath': avatarPath,
      'themePreference': themePreference,
      'language': language,
      'backgroundImagePath': backgroundImagePath,
      'joinDate': joinDate,
      'completedTasks': completedTasks,
      'isNotificationsEnabled': isNotificationsEnabled == true ? 1 : 0,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      avatarPath: json['avatarPath'],
      themePreference: json['themePreference'],
      language: json['language'],
      backgroundImagePath: json['backgroundImagePath'],
      joinDate: json['joinDate'],
      completedTasks: json['completedTasks'],
      isNotificationsEnabled:
          json['isNotificationsEnabled'] == 1, // Chuyển int sang bool
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? avatarPath,
    String? themePreference,
    String? language,
    String? backgroundImagePath,
    String? joinDate,
    int? completedTasks,
    bool? isNotificationsEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      avatarPath: avatarPath ?? this.avatarPath,
      themePreference: themePreference ?? this.themePreference,
      language: language ?? this.language,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      joinDate: joinDate ?? this.joinDate,
      completedTasks: completedTasks ?? this.completedTasks,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }
}
