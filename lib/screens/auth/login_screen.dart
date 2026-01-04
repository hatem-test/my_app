import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthService>().login(
              _emailController.text,
              _passwordController.text,
            );
        // Navigation is handled by Router stream
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل تسجيل الدخول: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SizedBox(height: height * 0.05), // Move image down slightly
                Image.asset(
                  'assets/images/login_singup.png',
                  width: width * 0.25, // Reduced size to not dominate
                  fit: BoxFit.contain, // Ensure proper scaling
                ),
                SizedBox(height: height * 0.03),
                Text(
                  'تسجيل الدخول',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: width * 0.07,
                      ),
                ),
                SizedBox(height: height * 0.04),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني أو رقم الجوال',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                ),
                SizedBox(height: height * 0.02),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
                ),
                SizedBox(height: height * 0.03),
                SizedBox(
                  height: height * 0.065,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'دخول',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                TextButton(
                  onPressed: () {}, // TODO: Implement Forgot Password
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/create-account');
                  },
                  child: Text(
                    'ليس لديك حساب؟ أنشئ حساباً جديداً',
                    style: TextStyle(fontSize: width * 0.035),
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
