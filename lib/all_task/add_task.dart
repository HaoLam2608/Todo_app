import 'package:flutter/material.dart';
import 'package:todo_list/all_task/task.dart';
import 'package:todo_list/database/task_model.dart';
import 'package:todo_list/database/task_database.dart';
import 'package:todo_list/main.dart'; // chứa TaskApp() hoặc AllTasksPage()

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
  String selectedReminder = "Set Reminder";

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
                children: const [
                  Text(
                    "Add task",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Spacer(),
                  Text("Cancel", style: TextStyle(color: Colors.red)),
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
                            child: Text(label),
                            value: label,
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
                      selectedTime = pickedTime.format(context);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text("Reminder", style: TextStyle(color: Colors.blue)),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.red),
                title: Text(selectedReminder),
                onTap: () {
                  // Optional: implement reminder picker here
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
          final newTask = Task(
            title: titleController.text,
            category: selectedCategory,
            dueDate: selectedDate,
            time: selectedTime,
            reminder: selectedReminder,
            notes: notesController.text,
            isCompleted: 0,
          );
          print("Saving new task: ${newTask.toMap()}"); // Thêm dòng này để log

          await TaskDatabase.instance.create(newTask);

          Navigator.pop(
            context,
            true,
          ); // 👉 quay lại mà vẫn giữ BottomNavigationBar
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check),
      ),
    );
  }
}
