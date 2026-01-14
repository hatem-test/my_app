import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/language_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          const LanguageToggleButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  final success = await authProvider.updateProfile(
                    name: _nameController.text,
                    phone: _phoneController.text,
                  );
                  if (success) {
                    setState(() => _isEditing = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.errorMessage ??
                              'حدث خطأ أثناء الحفظ'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.04),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: height * 0.02),
              Stack(
                children: [
                  CircleAvatar(
                    radius: width * 0.15,
                    backgroundColor: AppColors.backgroundSecondary,
                    child: authProvider.currentUser?.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              authProvider.currentUser!.profileImageUrl!,
                              width: width * 0.3,
                              height: width * 0.3,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.person,
                            size: width * 0.15, color: AppColors.textDisabled),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(width * 0.02),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: width * 0.05),
                      ),
                    ),
                ],
              ),
              SizedBox(height: height * 0.04),
              _buildTextField(
                label: 'الاسم',
                controller: _nameController,
                icon: Icons.person_outline,
                enabled: _isEditing,
              ),
              SizedBox(height: height * 0.02),
              _buildTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                icon: Icons.email_outlined,
                enabled: false, // Email usually read-only
              ),
              SizedBox(height: height * 0.02),
              _buildTextField(
                label: 'رقم الهاتف',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: height * 0.05),
              if (!_isEditing) ...[
                _buildActionTile(
                  title: 'تغيير كلمة المرور',
                  icon: Icons.lock_outline,
                  color: AppColors.primary,
                  onTap: () {
                    _showChangePasswordDialog(context, authProvider);
                  },
                ),
                _buildActionTile(
                  title: 'تسجيل الخروج',
                  icon: Icons.logout,
                  color: Colors.orange,
                  onTap: () async {
                    await authProvider.logout();
                  },
                ),
                _buildActionTile(
                  title: 'حذف الحساب',
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: () {
                    // Show Delete Confirmation
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? prefixText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : AppColors.backgroundSecondary,
      ),
      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Builder(builder: (context) {
      final width = MediaQuery.of(context).size.width;
      return ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(width * 0.02),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: width * 0.06),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: width * 0.04,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: width * 0.04, color: color.withValues(alpha: 0.5)),
      );
    });
  }

  void _showChangePasswordDialog(
      BuildContext context, AuthProvider authProvider) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور الجديدة',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                final success =
                    await authProvider.changePassword(passwordController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'تم تغيير كلمة المرور بنجاح'
                          : (authProvider.errorMessage ?? 'حدث خطأ')),
                      backgroundColor:
                          success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
