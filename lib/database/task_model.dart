class Task {
  final int? id;
  final String title;
  final String category;
  final String dueDate;
  final String time;
  final String reminder;
  final String notes;
  final int isCompleted; // 0 = chưa hoàn thành, 1 = đã hoàn thành

  Task({
    this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.time,
    required this.reminder,
    required this.notes,
    this.isCompleted = 0,

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
    );
  }
}
