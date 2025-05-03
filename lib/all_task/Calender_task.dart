import 'package:flutter/material.dart';
import 'package:todo_list/database/task_database.dart';
import '../services/session_manager.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  List<Map<String, dynamic>> events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final userId =
        await SessionManager.getCurrentUserId(); // Lấy ID người dùng hiện tại
    final tasks = await TaskDatabase.instance.getTasks();
    List<Map<String, dynamic>> newEvents = [];

    for (var task in tasks) {
      if (task.userId == userId) {
        // Kiểm tra nếu task thuộc về người dùng hiện tại
        try {
          // Expected format: "yyyy-MM-dd"
          List<String> dateParts = task.dueDate.split(' ')[0].split('-');
          if (dateParts.length != 3) {
            print("Invalid date format: ${task.dueDate}");
            continue;
          }

          int year = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int day = int.parse(dateParts[2]);

          String time = "No time set";
          if (task.dueDate.contains(" ")) {
            time = task.dueDate.split(" ")[1];
          }

          newEvents.add({
            'date': DateTime(year, month, day),
            'time': time,
            'title': task.title,
            'id': task.id,
          });
        } catch (e) {
          print(
            "Error parsing date for task ${task.title}: ${task.dueDate}, error: $e",
          );
        }
      }
    }

    setState(() {
      events = newEvents;
      _isLoading = false;
    });
  }

  List<int> _getDaysInMonth(int year, int month) {
    var firstDayOfMonth = DateTime(year, month, 1);
    var lastDayOfMonth = DateTime(year, month + 1, 0);

    int firstWeekday = firstDayOfMonth.weekday % 7; // Sunday as 0
    List<int> days = [];

    for (int i = 0; i < firstWeekday; i++) {
      days.add(0);
    }

    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(i);
    }

    int remainingCells = 42 - days.length;
    for (int i = 1; i <= remainingCells; i++) {
      days.add(i);
    }

    return days;
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    var firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    var lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);
    List<int> daysInMonth = _getDaysInMonth(currentYear, currentMonth);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            if (currentMonth > 1) {
                              currentMonth--;
                            } else {
                              currentMonth = 12;
                              currentYear--;
                            }
                          });
                        },
                        splashRadius: 20,
                      ),
                      Text(
                        '$currentYear ${_getMonthName(currentMonth)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            if (currentMonth < 12) {
                              currentMonth++;
                            } else {
                              currentMonth = 1;
                              currentYear++;
                            }
                          });
                        },
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WeekdayLabel('SUN'),
                        _WeekdayLabel('MON'),
                        _WeekdayLabel('TUE'),
                        _WeekdayLabel('WED'),
                        _WeekdayLabel('THU'),
                        _WeekdayLabel('FRI'),
                        _WeekdayLabel('SAT'),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: daysInMonth.length,
                    itemBuilder: (context, index) {
                      int day = daysInMonth[index];
                      bool isCurrentMonth = true;

                      if (index < firstDayOfMonth.weekday % 7) {
                        isCurrentMonth = false; // Previous month
                      } else if (index >=
                          (firstDayOfMonth.weekday % 7) + lastDayOfMonth.day) {
                        isCurrentMonth = false; // Next month
                      }

                      int adjustedDay = day;
                      int adjustedMonth = currentMonth;
                      int adjustedYear = currentYear;

                      if (index < firstDayOfMonth.weekday % 7) {
                        adjustedMonth =
                            currentMonth == 1 ? 12 : currentMonth - 1;
                        adjustedYear =
                            currentMonth == 1 ? currentYear - 1 : currentYear;
                        var prevMonthLastDay =
                            DateTime(adjustedYear, adjustedMonth + 1, 0).day;
                        adjustedDay =
                            prevMonthLastDay -
                            (firstDayOfMonth.weekday % 7 - index) +
                            1;
                      } else if (index >=
                          (firstDayOfMonth.weekday % 7) + lastDayOfMonth.day) {
                        adjustedMonth =
                            currentMonth == 12 ? 1 : currentMonth + 1;
                        adjustedYear =
                            currentMonth == 12 ? currentYear + 1 : currentYear;
                        adjustedDay = day;
                      }

                      bool isSelected =
                          adjustedDay == selectedDate.day &&
                          adjustedMonth == selectedDate.month &&
                          adjustedYear == selectedDate.year;

                      bool hasEvents = events.any(
                        (event) =>
                            event['date'].day == adjustedDay &&
                            event['date'].month == adjustedMonth &&
                            event['date'].year == adjustedYear,
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = DateTime(
                              adjustedYear,
                              adjustedMonth,
                              adjustedDay,
                            );
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              day > 0 ? day.toString() : '',
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : isCurrentMonth
                                        ? (hasEvents
                                            ? Colors.blue
                                            : Colors.black)
                                        : Colors.grey,
                                fontWeight:
                                    isSelected || hasEvents
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final dayEvents =
        events
            .where(
              (event) =>
                  event['date'].day == selectedDate.day &&
                  event['date'].month == selectedDate.month &&
                  event['date'].year == selectedDate.year,
            )
            .toList();

    if (dayEvents.isEmpty) {
      return const Center(
        child: Text(
          "No tasks for this date.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (event['id'] != null) {
                          await TaskDatabase.instance.delete(event['id']);
                          _loadEvents();
                        }
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event['time'],
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }
}
