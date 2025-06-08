import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/database/category_database.dart';
import 'package:todo_list/database/task_model.dart';
import 'package:todo_list/database/task_database.dart';
import 'package:todo_list/services/session_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

final FlutterLocalNotificationsPlugin flutterNotificationPlugin =
FlutterLocalNotificationsPlugin();

Future<void> addTodo(String title, String note, DateTime dueDate, String category) async {
  try {
    final uid = await SessionManager.getCurrentUserId();
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await FirebaseFirestore.instance.collection("todos").add({
      "title": title,
      "note": note,
      "dueDate": dueDate.toIso8601String(),
      "category": category,
      "userId": uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
  } catch (e) {
    throw Exception('Failed to add todo: $e');
  }
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterNotificationPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {},
  );

  // Request notification permission
  await flutterNotificationPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // Request exact alarm permission for Android 12+
  await flutterNotificationPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestExactAlarmsPermission();

  tz_init.initializeTimeZones();
}

Future<void> scheduleTaskReminder(
    int id,
    String title,
    String note,
    DateTime scheduleDate,
    ) async {
  try {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Channel for Task app reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterNotificationPlugin.zonedSchedule(
      id,
      'Nhắc nhở: $title',
      note.isEmpty ? 'Đã đến hạn hoàn thành nhiệm vụ này' : note,
      tz.TZDateTime.from(scheduleDate, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  } catch (e) {
    print('Lỗi khi đặt lịch nhắc nhở: $e');
    // Không throw error để không ảnh hưởng đến việc tạo task
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;
  String selectedDate = "Set due date";
  String selectedTime = "Set Time";
  String selectedReminder = "No reminder";
  bool reminderEnabled = false;
  bool isLoading = false;

  DateTime? dueDateTime;
  DateTime? reminderDateTime;
  String customReminderDate = "Select date";
  String customReminderTime = "Select time";

  @override
  void initState() {
    super.initState();
    initNotifications();
    loadCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    try {
      final data = await DatabaseHelper.instance.getCategories();
      setState(() {
        categories = data;
        if (categories.isNotEmpty) {
          selectedCategory = categories[0]['name'];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh mục: $e')),
        );
      }
    }
  }

  void _updateDueDateTime() {
    if (selectedDate != "Set due date" && selectedTime != "Set Time") {
      try {
        final dateComponents = selectedDate.split("-");
        final timeComponents = selectedTime.split(":");

        final year = int.parse(dateComponents[0]);
        final month = int.parse(dateComponents[1]);
        final day = int.parse(dateComponents[2]);
        final hour = int.parse(timeComponents[0]);
        final minute = int.parse(timeComponents[1]);

        dueDateTime = DateTime(year, month, day, hour, minute);
        _updateReminderDateTime();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Định dạng ngày giờ không hợp lệ')),
        );
      }
    }
  }

  void _updateReminderDateTime() {
    if (dueDateTime != null && reminderEnabled) {
      switch (selectedReminder) {
        case "10 minutes before":
          reminderDateTime = dueDateTime!.subtract(const Duration(minutes: 10));
          break;
        case "30 minutes before":
          reminderDateTime = dueDateTime!.subtract(const Duration(minutes: 30));
          break;
        case "1 hour before":
          reminderDateTime = dueDateTime!.subtract(const Duration(hours: 1));
          break;
        case "1 day before":
          reminderDateTime = dueDateTime!.subtract(const Duration(days: 1));
          break;
        default:
          if (selectedReminder.startsWith("Custom:")) {
            // reminderDateTime đã được set trong _setCustomReminder
            return;
          }
          reminderDateTime = null;
      }

      // Kiểm tra nếu reminder time đã qua
      if (reminderDateTime != null && reminderDateTime!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thời gian nhắc nhở đã qua, vui lòng chọn lại')),
        );
        setState(() {
          reminderEnabled = false;
          selectedReminder = "No reminder";
          reminderDateTime = null;
        });
      }
    } else {
      reminderDateTime = null;
    }
  }

  void _showCustomReminderDialog() {
    String tempDate = customReminderDate;
    String tempTime = customReminderTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Custom Reminder"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(tempDate),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: dueDateTime ?? DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        tempDate = picked.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(tempTime),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setDialogState(() {
                        tempTime = "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  _setCustomReminder(tempDate, tempTime);
                  Navigator.pop(context);
                },
                child: const Text("Set"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _setCustomReminder(String dateStr, String timeStr) {
    if (dateStr == "Select date" || timeStr == "Select time") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ ngày và giờ')),
      );
      return;
    }

    try {
      final dateComponents = dateStr.split("-");
      final timeComponents = timeStr.split(":");

      final year = int.parse(dateComponents[0]);
      final month = int.parse(dateComponents[1]);
      final day = int.parse(dateComponents[2]);
      final hour = int.parse(timeComponents[0]);
      final minute = int.parse(timeComponents[1]);

      final customDateTime = DateTime(year, month, day, hour, minute);

      // Kiểm tra thời gian không được ở quá khứ
      if (customDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thời gian nhắc nhở không thể ở quá khứ')),
        );
        return;
      }

      // Kiểm tra thời gian nhắc nhở phải trước thời hạn
      if (dueDateTime != null && customDateTime.isAfter(dueDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thời gian nhắc nhở phải trước thời hạn')),
        );
        return;
      }

      setState(() {
        reminderDateTime = customDateTime;
        selectedReminder = "Custom: $dateStr $timeStr";
        customReminderDate = dateStr;
        customReminderTime = timeStr;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Định dạng ngày giờ không hợp lệ')),
      );
    }
  }

  Future<void> _saveTask() async {
    if (isLoading) return;

    // Validation
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
      );
      return;
    }

    if (selectedDate == "Set due date" || selectedTime == "Set Time") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    // Đảm bảo dueDateTime được tạo
    _updateDueDateTime();

    if (dueDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể xác định thời gian')),
      );
      return;
    }

    // Kiểm tra thời gian không được ở quá khứ
    if (dueDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thời gian hoàn thành không thể ở quá khứ')),
      );
      return;
    }

    final userId = await SessionManager.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thêm task')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final newTask = Task(
        title: titleController.text.trim(),
        category: selectedCategory!,
        dueDate: selectedDate,
        time: selectedTime,
        reminder: reminderEnabled ? selectedReminder : "No reminder",
        notes: notesController.text.trim(),
        userId: userId,
      );

      // Lưu task vào database local
      final savedTask = await TaskDatabase.instance.create(newTask);

      // Lấy taskId từ saved task (giả sử Task model có id property)
      final taskId = savedTask.id ?? DateTime.now().millisecondsSinceEpoch;

      // Lưu vào Firestore
      await addTodo(
        titleController.text.trim(),
        notesController.text.trim(),
        dueDateTime!,
        selectedCategory!,
      );

      // Đặt lịch nhắc nhở nếu được bật
      if (reminderEnabled && reminderDateTime != null) {
        try {
          await scheduleTaskReminder(
            taskId,
            titleController.text.trim(),
            notesController.text.trim(),
            reminderDateTime!,
          );
        } catch (e) {
          // Hiển thị cảnh báo nhưng vẫn cho phép tạo task
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task đã được tạo nhưng không thể đặt nhắc nhở. Vui lòng cấp quyền notification.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task đã được thêm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Add task",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: isLoading ? Colors.grey : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: "Finish Report",
                  filled: true,
                  fillColor: Colors.lightBlueAccent,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Category", style: TextStyle(color: Colors.blue)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.lightBlueAccent,
                  border: InputBorder.none,
                ),
                hint: const Text("Select a category"),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text("Date", style: TextStyle(color: Colors.blue)),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.orange),
                title: Text(selectedDate),
                enabled: !isLoading,
                onTap: isLoading ? null : () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked.toLocal().toString().split(' ')[0];
                      _updateDueDateTime();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: Text(selectedTime),
                enabled: !isLoading,
                onTap: isLoading ? null : () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime =
                      "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                      _updateDueDateTime();
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Reminder", style: TextStyle(color: Colors.blue)),
                  const Spacer(),
                  Switch(
                    value: reminderEnabled,
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        reminderEnabled = value;
                        if (!value) {
                          selectedReminder = "No reminder";
                          reminderDateTime = null;
                        } else if (selectedReminder == "No reminder") {
                          selectedReminder = "10 minutes before";
                          _updateReminderDateTime();
                        }
                      });
                    },
                  ),
                ],
              ),
              if (reminderEnabled)
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.red),
                  title: Text(selectedReminder),
                  enabled: !isLoading,
                  onTap: isLoading ? null : () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Set Reminder"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("10 minutes before"),
                              onTap: () {
                                setState(() {
                                  selectedReminder = "10 minutes before";
                                  _updateReminderDateTime();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text("30 minutes before"),
                              onTap: () {
                                setState(() {
                                  selectedReminder = "30 minutes before";
                                  _updateReminderDateTime();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text("1 hour before"),
                              onTap: () {
                                setState(() {
                                  selectedReminder = "1 hour before";
                                  _updateReminderDateTime();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text("1 day before"),
                              onTap: () {
                                setState(() {
                                  selectedReminder = "1 day before";
                                  _updateReminderDateTime();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text("Custom time & date"),
                              trailing: const Icon(Icons.calendar_month),
                              onTap: () {
                                Navigator.pop(context);
                                customReminderDate = "Select date";
                                customReminderTime = "Select time";
                                _showCustomReminderDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              const Text("Notes", style: TextStyle(color: Colors.blue)),
              TextField(
                controller: notesController,
                enabled: !isLoading,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Make sure to research from internet",
                  filled: true,
                  fillColor: Colors.lightBlueAccent,
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _saveTask,
        backgroundColor: isLoading ? Colors.grey : Colors.blue,
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.check),
      ),
    );
  }
}