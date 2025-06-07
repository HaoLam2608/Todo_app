import 'package:flutter/material.dart';
import 'package:todo_list/all_task/edit_task_page.dart';
import 'package:todo_list/user/user.dart'; // Chứa SettingsPage
import 'package:todo_list/all_task/add_task.dart'; // Import AddTaskPage
import 'package:todo_list/database/task_database.dart';
import 'package:todo_list/database/task_model.dart';
import 'package:todo_list/services/session_manager.dart';

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUserId = await SessionManager.getCurrentUserId();

      if (_currentUserId != null) {
        _tasks = await TaskDatabase.instance.getTasksByUserId(_currentUserId!);
      } else {
        _tasks = [];
      }
    } catch (e) {
      print('Lỗi khi tải task: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Task'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentUserId == null
              ? Center(child: Text('Vui lòng đăng nhập để xem task'))
              : _tasks.isEmpty
                  ? Center(child: Text('Không có task nào'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return buildTaskCard(task);
                      },
                    ),
      floatingActionButton: _currentUserId != null
          ? FloatingActionButton(
               onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddTaskPage()),
                  ).then((refresh) {
                    if (refresh == true) setState(() {});
                  });
                },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget buildTaskCard(Task task) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditTaskPage(task: task)),
        ).then((_) {
          _loadTasks(); // Reload danh sách sau khi edit
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.lightBlue[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_box_outline_blank, color: Colors.blue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.dueDate,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await SessionManager.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}