import 'package:flutter/material.dart';
import 'package:todo_list/all_task/task.dart';
import 'package:todo_list/database/task_model.dart';
import 'package:todo_list/database/task_database.dart';
import 'package:todo_list/homepage/homepage.dart';
import 'package:todo_list/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

final FlutterLocalNotificationsPlugin flutterNotificationPlugin =
    FlutterLocalNotificationsPlugin();

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

  tz_init.initializeTimeZones();
}

Future<void> scheduleTaskReminder(
  int id,
  String title,
  String note,
  DateTime scheduleDate,
) async {
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
}

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final notesController = TextEditingController();

  String selectedCategory = "Work";
  String selectedDate = "Set due date";
  String selectedTime = "Set Time";
  String selectedReminder = "No reminder";
  bool reminderEnabled = false;

  DateTime? dueDateTime;
  DateTime? reminderDateTime;

  // Các biến cho phần nhắc nhở tùy chỉnh
  String customReminderDate = "Select date";
  String customReminderTime = "Select time";

  @override
  void initState() {
    super.initState();
    initNotifications();
  }

  // Hàm cập nhật thời gian nhắc nhở dựa trên lựa chọn
  void _updateReminderDateTime() {
    if (dueDateTime != null) {
      // Tính thời gian nhắc nhở dựa trên lựa chọn của người dùng
      if (selectedReminder == "10 minutes before") {
        reminderDateTime = dueDateTime!.subtract(const Duration(minutes: 10));
      } else if (selectedReminder == "30 minutes before") {
        reminderDateTime = dueDateTime!.subtract(const Duration(minutes: 30));
      } else if (selectedReminder == "1 hour before") {
        reminderDateTime = dueDateTime!.subtract(const Duration(hours: 1));
      } else if (selectedReminder == "1 day before") {
        reminderDateTime = dueDateTime!.subtract(const Duration(days: 1));
      } else if (selectedReminder.startsWith("Custom:")) {
        // Thời gian đã được đặt trong _setCustomReminder
      } else {
        // "No reminder" hoặc các trường hợp khác
        reminderDateTime = null;
      }
    }
  }

  // Hàm hiển thị dialog chọn ngày giờ tùy chỉnh cho nhắc nhở
  void _showCustomReminderDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Custom Reminder"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(customReminderDate),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 1),
                          ),
                          lastDate:
                              dueDateTime != null
                                  ? dueDateTime!
                                  : DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            customReminderDate =
                                picked.toLocal().toString().split(' ')[0];
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(customReminderTime),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            customReminderTime =
                                "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      _setCustomReminder(
                        customReminderDate,
                        customReminderTime,
                      );
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

  // Hàm xử lý khi người dùng xác nhận nhắc nhở tùy chỉnh
  void _setCustomReminder(String dateStr, String timeStr) {
    if (dateStr != "Select date" && timeStr != "Select time") {
      try {
        final dateComponents = dateStr.split("-");
        final timeComponents = timeStr.split(":");

        final year = int.parse(dateComponents[0]);
        final month = int.parse(dateComponents[1]);
        final day = int.parse(dateComponents[2]);

        final hour = int.parse(timeComponents[0]);
        final minute = int.parse(timeComponents[1]);

        final customDateTime = DateTime(year, month, day, hour, minute);

        // Kiểm tra xem thời gian nhắc nhở có trước deadline không
        if (dueDateTime != null && customDateTime.isAfter(dueDateTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thời gian nhắc nhở phải trước thời hạn'),
            ),
          );
          return;
        }

        setState(() {
          reminderDateTime = customDateTime;
          selectedReminder = "Custom: $dateStr $timeStr";
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Định dạng ngày giờ không hợp lệ')),
        );
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
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
              DropdownButtonFormField(
                value: selectedCategory,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.lightBlueAccent,
                  border: InputBorder.none,
                ),
                items:
                    ['Work', 'Study', 'Personal']
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value.toString());
                },
              ),
              const SizedBox(height: 20),
              const Text("Date", style: TextStyle(color: Colors.blue)),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.orange),
                title: Text(selectedDate),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked.toLocal().toString().split(' ')[0];

                      // Cập nhật dueDateTime
                      if (selectedTime != "Set Time") {
                        final timeComponents = selectedTime.split(":");
                        final hour = int.parse(timeComponents[0]);
                        final minute = int.parse(timeComponents[1]);

                        dueDateTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          hour,
                          minute,
                        );

                        // Cập nhật reminderDateTime dựa trên dueDateTime mới
                        _updateReminderDateTime();
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: Text(selectedTime),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime =
                          "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";

                      // Cập nhật dueDateTime
                      if (selectedDate != "Set due date") {
                        final dateComponents = selectedDate.split("-");
                        final year = int.parse(dateComponents[0]);
                        final month = int.parse(dateComponents[1]);
                        final day = int.parse(dateComponents[2]);

                        dueDateTime = DateTime(
                          year,
                          month,
                          day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        // Cập nhật reminderDateTime dựa trên dueDateTime mới
                        _updateReminderDateTime();
                      }
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
                    onChanged: (value) {
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
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
                                    // Khởi tạo giá trị mặc định cho ngày giờ tùy chỉnh
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
        onPressed: () async {
          if (titleController.text.isEmpty) {
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

          final newTask = Task(
            title: titleController.text,
            category: selectedCategory,
            dueDate: selectedDate,
            time: selectedTime,
            reminder: reminderEnabled ? selectedReminder : "No reminder",
            notes: notesController.text,
          );

          final taskId = await TaskDatabase.instance.create(newTask);

          if (reminderEnabled && reminderDateTime != null) {
            await scheduleTaskReminder(
              taskId as int,
              titleController.text,
              notesController.text,
              reminderDateTime!,
            );
          }

          if (!mounted) return;

          Navigator.pop(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check),
      ),
    );
  }
}
