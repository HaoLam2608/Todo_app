import 'package:flutter/material.dart';
import 'package:todo_list/all_task/task.dart';
import 'package:todo_list/homepage/homepage.dart';
import 'package:todo_list/login/login_screen.dart';
import 'package:todo_list/login/onboaring.dart';
import 'package:todo_list/user/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreen(),
    );
  }
}

