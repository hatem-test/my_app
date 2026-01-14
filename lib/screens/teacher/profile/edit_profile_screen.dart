import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'حدث خطأ أثناء الحفظ'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final padding = size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('تعديل المعلومات الشخصية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatar(isSmallScreen),
              SizedBox(height: isSmallScreen ? 20 : 32),
              _buildTextField(
                controller: _nameController,
                label: 'الاسم الكامل',
                icon: Icons.person_outline,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الرجاء إدخال الاسم' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الرجاء إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value?.isEmpty ?? true
                    ? 'الرجاء إدخال البريد الإلكتروني'
                    : null,
              ),
              SizedBox(height: isSmallScreen ? 30 : 40),
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 45 : 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'حفظ التغييرات',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildAvatar(bool isSmallScreen) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: isSmallScreen ? 100 : 120,
            height: isSmallScreen ? 100 : 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Icon(
              Icons.person,
              size: isSmallScreen ? 50 : 60,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                size: isSmallScreen ? 16 : 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
