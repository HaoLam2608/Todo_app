import 'package:flutter/material.dart';
import 'package:todo_list/all_task/Calender_task.dart';
import 'package:todo_list/all_task/add_task.dart';
import 'package:todo_list/all_task/task.dart';
import 'package:todo_list/database/task_database.dart';
import 'package:todo_list/database/task_model.dart';
import 'package:todo_list/database/user_model.dart';
import 'package:todo_list/user/user.dart'; 

class HomeScreen extends StatefulWidget {
  final UserModel user; // Add user parameter to HomeScreen
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize pages with the user passed to SettingsPage
    _pages = [
      HomeContent(), // Trang chính
      CalendarPage(), // Lịch
      AddTaskPage(), // Add (nếu cần)
      AllTasksPage(), // Danh sách tất cả task
      SettingsPage(user: widget.user), // Pass user to SettingsPage
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTaskPage()),
        ).then((refresh) {
          if (refresh == true) setState(() {});
        });
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 3
          ? null
          : SizedBox(
              height: 72,
              width: 72,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddTaskPage()),
                  ).then((refresh) {
                    if (refresh == true) setState(() {});
                  });
                },
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 36),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _selectedIndex == 3
                ? [
                    _buildNavIcon(Icons.home, 0),
                    _buildNavIcon(Icons.calendar_today, 1),
                    _buildNavIcon(Icons.insert_drive_file, 3),
                    _buildNavIcon(Icons.settings, 4),
                  ]
                : [
                    _buildNavIcon(Icons.home, 0),
                    _buildNavIcon(Icons.calendar_today, 1),
                    const SizedBox(width: 10), // Space for FAB
                    _buildNavIcon(Icons.insert_drive_file, 3),
                    _buildNavIcon(Icons.settings, 4),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon),
      color: _selectedIndex == index ? Colors.blue : Colors.grey,
      onPressed: () => setState(() => _selectedIndex = index),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Task> todaysTasks = [];

  @override
  void initState() {
    super.initState();
    loadTodayTasks();
  }

  List<Task> completedTasks = [];

  void loadTodayTasks() async {
    final todayStr = DateTime.now().toString().split(' ')[0];
    final tasks = await TaskDatabase.instance.getTasksByDate(todayStr);
    final completed = await TaskDatabase.instance.getCompletedTasksByDate(
      todayStr,
    );

    setState(() {
      todaysTasks = tasks.where((t) => t.isCompleted == 0).toList();
      completedTasks = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for Tasks, Events',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const Text(
              "Categories",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildCategory("Work", Icons.work, Colors.blue),
                _buildCategory("Personal", Icons.person, Colors.red),
                _buildCategory("Shopping", Icons.shopping_cart, Colors.orange),
                _buildCategory("Health", Icons.favorite, Colors.pink),
                _buildCategory("Add", Icons.add, Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
            _buildTaskSection(
              "Today's task",
              todaysTasks
                  .map((task) => _buildTaskItem(task.title, task.time, false))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _buildTaskSection(
              "Completed task",
              completedTasks
                  .map(
                    (task) =>
                        _buildTaskItem(task.title, task.time, true, task: task),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTaskSection(String title, List<Widget> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text("See all", style: TextStyle(color: Colors.blue.shade400)),
          ],
        ),
        const SizedBox(height: 10),
        ...tasks,
      ],
    );
  }

  Widget _buildTaskItem(
    String title,
    String time,
    bool completed, {
    Task? task,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            if (!completed) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Hoàn thành task này?"),
                  content: Text(
                    "Bạn có chắc chắn muốn đánh dấu '${title}' là hoàn thành?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Huỷ"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final updatedTask = Task(
                          id: task!.id,
                          title: task.title,
                          category: task.category,
                          dueDate: task.dueDate,
                          time: task.time,
                          reminder: task.reminder,
                          notes: task.notes,
                          isCompleted: 1,
                        );
                        await TaskDatabase.instance.update(updatedTask);
                        Navigator.pop(context);
                        loadTodayTasks(); // refresh
                      },
                      child: const Text("Xác nhận"),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        title: Text(title),
        trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}