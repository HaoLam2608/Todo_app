import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_list/database/user_database.dart';
import 'package:todo_list/database/user_model.dart';
import 'package:todo_list/login/login_screen.dart';

class SettingsPage extends StatefulWidget {
  final UserModel user;

  const SettingsPage({required this.user, super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserModel _user;
  final _picker = ImagePicker();
  final _dbHelper = UserDatabase.instance;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<String> _saveImagePermanently(XFile pickedFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedFile.path);
    final newPath = path.join(directory.path, fileName);
    await File(pickedFile.path).copy(newPath);
    return newPath;
  }

  Future<void> _updateAvatar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Change Avatar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Do you want to select a new avatar from your device?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final permission = await Permission.photos.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access photos denied')),
      );
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected')));
        return;
      }

      if (_user.id == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User ID is missing')));
        return;
      }

      final avatarPath = await _saveImagePermanently(pickedFile);
      await _dbHelper.updateUserAvatar(_user.id!, avatarPath);
      setState(() {
        _user = _user.copyWith(avatarPath: avatarPath);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update avatar: $e')));
    }
  }

  Future<void> _updateBackground() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Change Background',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Do you want to select a new background image?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final permission = await Permission.photos.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access photos denied')),
      );
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected')));
        return;
      }

      if (_user.id == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User ID is missing')));
        return;
      }

      final backgroundPath = await _saveImagePermanently(pickedFile);
      await _dbHelper.updateUserBackground(_user.id!, backgroundPath);
      setState(() {
        _user = _user.copyWith(backgroundImagePath: backgroundPath);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update background: $e')),
      );
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _user.username);
    final emailController = TextEditingController(text: _user.email);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value != _user.password) {
                          return 'Incorrect password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (_user.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID is missing')),
                      );
                      return;
                    }
                    try {
                      await _dbHelper.updateUser(
                        _user.id!,
                        nameController.text,
                        emailController.text,
                        _user.password,
                        _user.avatarPath,
                        _user.backgroundImagePath,
                        null,
                        null,
                        _user.joinDate,
                        _user.completedTasks,
                        _user.isNotificationsEnabled,
                      );
                      setState(() {
                        _user = _user.copyWith(
                          username: nameController.text,
                          email: emailController.text,
                        );
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: oldPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password';
                        }
                        if (value != _user.password) {
                          return 'Incorrect old password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        final passwordRegex = RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
                        );
                        if (!passwordRegex.hasMatch(value)) {
                          return 'Password must be at least 8 characters, with uppercase, lowercase, numbers, and special characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (_user.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID is missing')),
                      );
                      return;
                    }
                    try {
                      await _dbHelper.updateUser(
                        _user.id!,
                        _user.username,
                        _user.email,
                        newPasswordController.text,
                        _user.avatarPath,
                        _user.backgroundImagePath,
                        null,
                        null,
                        _user.joinDate,
                        _user.completedTasks,
                        _user.isNotificationsEnabled,
                      );
                      setState(() {
                        _user = _user.copyWith(
                          password: newPasswordController.text,
                        );
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to change password: $e'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _configureNotifications() async {
    bool enableAppNotifications = _user.isNotificationsEnabled ?? true;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: const Text('Enable App Notifications'),
                        value: enableAppNotifications,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            enableAppNotifications = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_user.id == null) return;
                        await _dbHelper.updateUser(
                          _user.id!,
                          _user.username,
                          _user.email,
                          _user.password,
                          _user.avatarPath,
                          _user.backgroundImagePath,
                          null,
                          null,
                          _user.joinDate,
                          _user.completedTasks,
                          enableAppNotifications,
                        );
                        setState(() {
                          _user = _user.copyWith(
                            isNotificationsEnabled: enableAppNotifications,
                          );
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'App Notifications: ${enableAppNotifications ? 'Enabled' : 'Disabled'}',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This action cannot be undone. Please enter your password to confirm.',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value != _user.password) {
                        return 'Incorrect password';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (_user.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID is missing')),
                      );
                      return;
                    }
                    try {
                      await _dbHelper.deleteUser(_user.id!);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account deleted successfully'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete account: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showUserStats() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'User Stats',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${_user.username}'),
                Text('Join Date: ${_user.joinDate ?? 'Unknown'}'),
                Text('Completed Tasks: ${_user.completedTasks ?? 0}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Log out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      if (_user.backgroundImagePath != null)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_user.backgroundImagePath!),
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.3),
                              colorBlendMode: BlendMode.darken,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _updateAvatar,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    _user.avatarPath != null
                                        ? FileImage(File(_user.avatarPath!))
                                        : null,
                                child:
                                    _user.avatarPath == null
                                        ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _user.username,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _user.email,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Customize",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                buildSettingsButton(
                  "Edit Profile",
                  icon: Icons.edit,
                  onPressed: _editProfile,
                ),
                const SizedBox(height: 8),
                buildSettingsButton(
                  "Change Background",
                  icon: Icons.image,
                  onPressed: _updateBackground,
                ),
                const SizedBox(height: 8),
                buildSettingsButton(
                  "Notifications",
                  icon: Icons.notifications,
                  onPressed: _configureNotifications,
                ),
                const SizedBox(height: 8),
                // Removed "Theme Preference" button
                const SizedBox(height: 8),
                // Removed "Language" button
                const SizedBox(height: 8),
                buildSettingsButton(
                  "Change Password",
                  icon: Icons.lock,
                  onPressed: _changePassword,
                ),
                const SizedBox(height: 32),
                const Text(
                  "Account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                buildSettingsButton(
                  "User Stats",
                  icon: Icons.bar_chart,
                  onPressed: _showUserStats,
                ),
                const SizedBox(height: 8),
                buildSettingsButton(
                  "Delete Account",
                  icon: Icons.delete_forever,
                  onPressed: _deleteAccount,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _logout,
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget buildSettingsButton(
    String label, {
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: onPressed != null ? Colors.white : Colors.grey[200],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 16),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
