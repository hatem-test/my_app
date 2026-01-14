import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../models/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // التوجيه حسب الدور
          final user = authProvider.currentUser;
          if (user != null) {
            switch (user.role) {
              case UserRole.teacher:
                context.go('/teacher');
                break;
              case UserRole.admin:
                context.go('/admin');
                break;
              case UserRole.mother:
              default:
                context.go('/');
                break;
            }
          } else {
            context.go('/');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'فشل تسجيل الدخول'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left:
                  16, // Or right based on direction, let's stick to LTR for this specific toggle position usually
              child: const LanguageToggleButton(),
            ),
            Center(
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
                        width: width * 0.05, // Reduced size to not dominate
                        height: height * 0.30,
                        fit: BoxFit.contain, // Ensure proper scaling
                      ),
                      SizedBox(height: height * 0.03),
                      Text(
                        'تسجيل الدخول',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
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
                        validator: (value) => value!.isEmpty
                            ? 'الرجاء إدخال البريد الإلكتروني'
                            : null,
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
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, _) => ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            child: auth.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    'دخول',
                                    style: TextStyle(fontSize: width * 0.045),
                                  ),
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
          ],
        ),
      ),
    );
  }
}
