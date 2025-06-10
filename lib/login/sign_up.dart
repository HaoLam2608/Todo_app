import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/database/user_database.dart';
import 'package:todo_list/database/user_model.dart';
import 'package:todo_list/login/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  String errorMessage = '';
  String? emailError;
  String? passwordError;

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordStrong(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _signUp() async {
    setState(() {
      emailError = null;
      passwordError = null;
      errorMessage = '';
    });

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng điền đầy đủ thông tin.';
      });
      return;
    }

    if (!_isEmailValid(email)) {
      setState(() {
        emailError = 'Email không đúng định dạng.';
      });
      return;
    }

    if (!_isPasswordStrong(password)) {
      setState(() {
        passwordError =
        'Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường và ký tự đặc biệt.';
      });
      return;
    }

    try {
      // Kiểm tra email đã tồn tại trong SQLite
      final existingUser = await UserDatabase.instance.isEmailExist(email);
      if (existingUser) {
        setState(() {
          errorMessage = 'Email đã tồn tại.';
        });
      }

      // Tạo tài khoản Firebase
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Lưu thông tin vào SQLite
      final newUser = UserModel(
        username: username,
        email: email,
        password: password,
      );
      await UserDatabase.instance.registerUser(newUser);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email đã được sử dụng.';
        } else if (e.code == 'weak-password') {
          passwordError = 'Mật khẩu quá yếu.';
        } else {
          errorMessage = 'Lỗi: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Đã xảy ra lỗi: $e';
      });
    }
  }


  Widget buildSocialIcon(String assetPath) {
    return ClipOval(
      child: Container(
        width: 44,
        height: 44,
        color: Colors.white,
        padding: const EdgeInsets.all(6),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Username
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Your Username *',
                  helperText: 'Vui lòng nhập tên người dùng.',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Your Email *',
                  helperText:
                      'Email phải đúng định dạng (ví dụ: example@gmail.com)',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: emailError,
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  helperText:
                      'Mật khẩu tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường và ký tự đặc biệt.',
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
                  errorText: passwordError,
                ),
              ),
              const SizedBox(height: 20),

              // Error message
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already a user? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'OR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildSocialIcon('assets/img/fb_icon.jfif'),
                  const SizedBox(width: 20),
                  buildSocialIcon('assets/img/ins_icon.png'),
                  const SizedBox(width: 20),
                  buildSocialIcon('assets/img/twitter_icon.png'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
