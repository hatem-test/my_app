import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/models.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.mother;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تم إنشاء الحساب، يرجى التحقق من بريدك')),
          );
          // الانتقال لصفحة التحقق
          context.push('/verify-email', extra: _emailController.text.trim());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'فشل إنشاء الحساب'),
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
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.06),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/login_singup.png',
                width: width * 0.15,
              ),
              SizedBox(height: height * 0.04),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              SizedBox(height: height * 0.02),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              SizedBox(height: height * 0.02),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v!.length < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
              ),
              SizedBox(height: height * 0.02),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'نوع الحساب',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: UserRole.mother, child: Text('أم')),
                  DropdownMenuItem(
                      value: UserRole.teacher, child: Text('معلمة')),
                  DropdownMenuItem(value: UserRole.admin, child: Text('مدير')),
                ],
                onChanged: (role) => setState(() => _selectedRole = role!),
              ),
              SizedBox(height: height * 0.04),
              SizedBox(
                height: height * 0.065,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) => ElevatedButton(
                    onPressed: auth.isLoading ? null : _register,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'تسجيل',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
