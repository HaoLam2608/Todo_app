import 'package:flutter/material.dart';
import 'package:todo_list/database/task_database.dart';
import 'package:todo_list/database/task_model.dart';
import 'package:todo_list/database/user_model.dart';
import 'package:fl_chart/fl_chart.dart';

class UserStatsPage extends StatefulWidget {
  final UserModel user;

  const UserStatsPage({required this.user, super.key});

  @override
  _UserStatsPageState createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _filter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Not Completed'];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(Duration(days: 7));
    _endDate = DateTime.now();
  }

  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Stats'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username: ${widget.user.username}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'Email: ${widget.user.email}',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        Text(
                          'Join Date: ${widget.user.joinDate ?? 'Unknown'}',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Start Date: ${_startDate?.toLocal().toString().split(' ')[0] ?? ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder:
                                      (context, child) => Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: Colors.blue,
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.blue,
                                          ),
                                          buttonTheme: ButtonThemeData(
                                            textTheme: ButtonTextTheme.primary,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                );
                                if (picked != null)
                                  setState(() => _startDate = picked);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder:
                                      (context, child) => Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: Colors.blue,
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.blue,
                                          ),
                                          buttonTheme: ButtonThemeData(
                                            textTheme: ButtonTextTheme.primary,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                );
                                if (picked != null)
                                  setState(() => _endDate = picked);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: _filter,
                          items:
                              _filters
                                  .map(
                                    (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null)
                              setState(() => _filter = newValue);
                          },
                          style: TextStyle(color: Colors.black87),
                          dropdownColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.user.id != null &&
                    _startDate != null &&
                    _endDate != null)
                  Expanded(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FutureBuilder<List<Task>>(
                          future: TaskDatabase.instance
                              .getTasksByUserIdAndDateRange(
                                widget.user.id!,
                                _startDate!,
                                _endDate!,
                              ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return Center(child: CircularProgressIndicator());
                            List<Task> tasks =
                                snapshot.data!
                                    .where((t) => t.userId == widget.user.id)
                                    .toList();
                            if (_filter == 'Completed')
                              tasks =
                                  tasks
                                      .where((t) => t.isCompleted == 1)
                                      .toList();
                            if (_filter == 'Not Completed')
                              tasks =
                                  tasks
                                      .where((t) => t.isCompleted == 0)
                                      .toList();
                            final completed =
                                tasks.where((t) => t.isCompleted == 1).length;
                            final notCompleted =
                                tasks.where((t) => t.isCompleted == 0).length;
                            final totalTasks = tasks.length;
                            final completionRate =
                                totalTasks > 0
                                    ? (completed / totalTasks * 100)
                                        .toStringAsFixed(1)
                                    : '0.0';

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Tasks: $totalTasks',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Text(
                                    'Completed Tasks: $completed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Not Completed Tasks: $notCompleted',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    'Completion Rate: $completionRate%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 200,
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            value: completed.toDouble(),
                                            color: Colors.green,
                                            title: 'Completed',
                                            radius: 50,
                                          ),
                                          PieChartSectionData(
                                            value: notCompleted.toDouble(),
                                            color: Colors.red,
                                            title: 'Not Completed',
                                            radius: 50,
                                          ),
                                        ],
                                        centerSpaceRadius: 40,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ListView.builder(
                                    itemCount: tasks.length,
                                    shrinkWrap: true,
                                    physics:
                                        NeverScrollableScrollPhysics(), // tránh scroll conflict
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];
                                      return Card(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            task.title,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          subtitle: Text(
                                            'Status: ${task.isCompleted == 1 ? 'Completed' : 'Not Completed'}, Category: ${task.category}',
                                            style: TextStyle(
                                              color:
                                                  task.isCompleted == 1
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
