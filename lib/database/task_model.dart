class Task {
  final int? id;
  final String title;
  final String category;
  final String dueDate;
  final String time;
  final String reminder;
  final String notes;
  final int isCompleted; // 0 = chưa hoàn thành, 1 = đã hoàn thành
  final int userId; // Thêm userId để liên kết với người dùng

  Task({
    this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.time,
    required this.reminder,
    required this.notes,
    this.isCompleted = 0,
    required this.userId, // Thêm userId vào constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dueDate': dueDate,
      'time': time,
      'reminder': reminder,
      'notes': notes,
      'isCompleted': isCompleted,
      'user_id': userId, // Thêm user_id vào map
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      dueDate: json['dueDate'],
      time: json['time'],
      reminder: json['reminder'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] as int,
      userId: json['user_id'] as int, // Đọc user_id từ json
    );
  }

  Task copy({
    int? id,
    String? title,
    String? category,
    String? dueDate,
    String? time,
    String? reminder,
    String? notes,
    int? isCompleted,
    int? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      time: time ?? this.time,
      reminder: reminder ?? this.reminder,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId, // Thêm userId vào copy
    );
  }
}
