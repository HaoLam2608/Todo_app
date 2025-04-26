import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart'
    as FlutterIconPicker;
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
            ElevatedButton(
              onPressed: () async {
                IconData? icon =
                    (await FlutterIconPicker.showIconPicker(context))
                        as IconData?;
                if (icon != null) {
                  setState(() {
                    _selectedIcon = icon;
                  });
                }
              },
              child: const Text('Choose icon from library'),
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
                        'icon': _selectedIcon?.codePoint,
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
        child:
            selectedColor == color
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
      ),
    );
  }
}
