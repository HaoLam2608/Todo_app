import 'package:flutter/material.dart';
import 'package:todo_list/database/user_database.dart';
import 'package:todo_list/database/user_model.dart';
import 'package:todo_list/homepage/homepage.dart';
import 'package:todo_list/login/sign_up.dart';
import '../services/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  String errorMessage = '';

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng nhập email và mật khẩu!';
      });
      return;
    }

    try {
      final user = await UserDatabase.instance.getUserByEmailAndPassword(email, password);
      if (user != null) {
        await SessionManager.saveUserSession(user);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
      } else {
        setState(() {
          errorMessage = 'Sai email hoặc mật khẩu!';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Đã xảy ra lỗi: $e';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        errorMessage = '';
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final emailExists = await UserDatabase.instance.isEmailExist(firebaseUser.email!);

        if (emailExists) {
          final allUsers = await UserDatabase.instance.getAllUsers();
          final localUser = allUsers.firstWhere(
                (user) => user.email == firebaseUser.email!,
          );

          await SessionManager.saveUserSession(localUser);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(user: localUser)),
          );
        } else {
          final newUser = UserModel(
            username: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email!,
            password: 'GoogleAuth123!', // Password hợp lệ theo regex
            joinDate: DateTime.now().toIso8601String(),
            completedTasks: 0,
            isNotificationsEnabled: true,
          );

          try {
            final userId = await UserDatabase.instance.registerUser(newUser);
            final createdUser = newUser.copyWith(id: userId);

            await SessionManager.saveUserSession(createdUser);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(user: createdUser)),
            );
          } catch (registerError) {
            print('Register error: $registerError');
            setState(() {
              errorMessage = 'Không thể tạo tài khoản Google: $registerError';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Đăng nhập Google thất bại: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Chỉ hiện error khi không phải lỗi Google sign-in
                    errorText: errorMessage.isNotEmpty &&
                        emailController.text.trim().isEmpty &&
                        !errorMessage.contains('Google')
                        ? 'Email is required'
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Chỉ hiện error khi không phải lỗi Google sign-in
                    errorText: errorMessage.isNotEmpty &&
                        passwordController.text.trim().isEmpty &&
                        !errorMessage.contains('Google')
                        ? 'Password is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password logic
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ),
                if (errorMessage.isNotEmpty &&
                    emailController.text.trim().isNotEmpty &&
                    passwordController.text.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hoặc đăng nhập bằng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: Image.asset('assets/img/google_icon.png', height: 24),
                  label: const Text('Đăng nhập với Google'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
