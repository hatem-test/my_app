import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'أحمد محمد'); // Mock data
  final _emailController =
      TextEditingController(text: 'ahmed@example.com'); // Mock data
  final _phoneController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Default phone without +963 (will be added in UI prefix)
    _phoneController.text = '912345678';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  // Save changes
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
                  );
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        AssetImage('assets/profile_placeholder.png'),
                    backgroundColor: AppColors.backgroundSecondary,
                    child: Icon(Icons.person,
                        size: 60, color: AppColors.textDisabled),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'الاسم',
                controller: _nameController,
                icon: Icons.person_outline,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                icon: Icons.email_outlined,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'رقم الهاتف',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                enabled: _isEditing,
                prefixText: '+963 ',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
              if (!_isEditing) ...[
                _buildActionTile(
                  title: 'تغيير كلمة المرور',
                  icon: Icons.lock_outline,
                  color: AppColors.primary,
                  onTap: () {
                    // Show Change Password Dialog
                  },
                ),
                _buildActionTile(
                  title: 'تسجيل الخروج',
                  icon: Icons.logout,
                  color: Colors.orange,
                  onTap: () {
                    context.read<AuthService>().logout();
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
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: color.withValues(alpha: 0.5)),
    );
  }
}
