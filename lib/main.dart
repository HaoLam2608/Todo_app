import 'package:flutter/material.dart';
import 'services/session_manager.dart';
import 'login/login_screen.dart';
import 'package:todo_list/homepage/homepage.dart';
import 'database/user_model.dart'; // Import UserModel
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<Map<String, dynamic>?>(
        future: SessionManager.getUserSession(), // Lấy thông tin người dùng
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Kiểm tra đã đăng nhập chưa
          final userData = snapshot.data;
          final isLoggedIn =
              userData != null; // Kiểm tra nếu userData không null

          // Nếu đã đăng nhập thì vào HomeScreen, nếu chưa thì vào LoginScreen
          if (isLoggedIn) {
            final user = UserModel.fromJson(
              userData,
            ); // Chuyển đổi từ JSON sang UserModel
            return HomeScreen(user: user);
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home':
            (context) => HomeScreen(
              user: UserModel(id: 0, username: '', email: '', password: ''),
            ), // Placeholder
        // Các routes khác...
      },
    );
  }
}
