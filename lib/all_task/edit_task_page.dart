import 'package:flutter/material.dart';
import 'package:todo_list/database/task_database.dart';
import 'package:todo_list/database/task_model.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  String _selectedCategory = "Work";
  String _selectedDate = "";
  String _selectedTime = "";
  String _selectedReminder = "None";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes);
    _selectedCategory = widget.task.category;
    _selectedDate = widget.task.dueDate;
    _selectedTime = widget.task.time;
    _selectedReminder = widget.task.reminder;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked.format(context);
      });
    }
  }

  void _confirmDeleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xoá công việc"),
            content: const Text(
              "Bạn có chắc chắn muốn xoá công việc này không?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Huỷ"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Xoá", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      if (widget.task.id != null) {
        await TaskDatabase.instance.delete(widget.task.id!);
        Navigator.of(context).pop(); // Quay lại AllTasksPage
      }
    }
  }

  void _saveTask() async {
    final updatedTask = widget.task.copy(
      title: _titleController.text,
      notes: _notesController.text,
      category: _selectedCategory,
      dueDate: _selectedDate,
      time: _selectedTime,
      reminder: _selectedReminder,
    );

    await TaskDatabase.instance.update(updatedTask);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Chỉnh sửa công việc'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTask),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tiêu đề", style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Nhập tiêu đề...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Loại công việc", style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: _selectedCategory,
              items:
                  ['Work', 'Study', 'Personal']
                      .map(
                        (label) =>
                            DropdownMenuItem(child: Text(label), value: label),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Ngày đến hạn", style: TextStyle(color: Colors.blue)),
            ListTile(
              title: Text(_selectedDate.isEmpty ? "Chọn ngày" : _selectedDate),
              leading: const Icon(Icons.calendar_today),
              onTap: _pickDate,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Giờ", style: TextStyle(color: Colors.blue)),
            ListTile(
              title: Text(_selectedTime.isEmpty ? "Chọn giờ" : _selectedTime),
              leading: const Icon(Icons.access_time),
              onTap: _pickTime,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Nhắc nhở", style: TextStyle(color: Colors.blue)),
            TextField(
              decoration: InputDecoration(
                hintText: "Nhập nhắc nhở...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _selectedReminder = value,
            ),
            const SizedBox(height: 20),
            const Text("Ghi chú", style: TextStyle(color: Colors.blue)),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Thêm ghi chú...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
