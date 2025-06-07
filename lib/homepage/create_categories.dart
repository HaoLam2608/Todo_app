import 'package:flutter/material.dart';
import 'package:todo_list/database/category_database.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  Color selectedColor = Colors.green;
  IconData? _selectedIcon;

  // Danh sách icon mẫu từ Material Icons
  final List<IconData> _icons = [
    Icons.home,
    Icons.work,
    Icons.favorite,
    Icons.star,
    Icons.book,
    Icons.directions_car,
    Icons.flight,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new category'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Category name :"),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.blueAccent,
                hintText: "Family",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Category icon :"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _icons.map((icon) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIcon == icon ? Colors.blueAccent : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 30, color: selectedColor),
                ),
              )).toList(),
            ),
            if (_selectedIcon != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(_selectedIcon, size: 50, color: selectedColor),
              ),
            const SizedBox(height: 16),
            const Text("Category color :"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                buildColorChoice(Colors.green),
                buildColorChoice(Colors.teal),
                buildColorChoice(Colors.blue),
                buildColorChoice(Colors.indigo),
                buildColorChoice(Colors.brown),
                buildColorChoice(Colors.purple),
                buildColorChoice(Colors.pink),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      await DatabaseHelper.instance.insertCategory({
                        'name': _nameController.text,
                        'color': selectedColor.value,
                        'icon': _selectedIcon?.codePoint.toString(),
                      });
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Create Category'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildColorChoice(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 16,
        child: selectedColor == color
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}