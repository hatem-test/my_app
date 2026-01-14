import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../models/models.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/guardian_repository.dart';

class AddEditGuardianScreen extends StatefulWidget {
  final GuardianModel? guardian;

  const AddEditGuardianScreen({super.key, this.guardian});

  @override
  State<AddEditGuardianScreen> createState() => _AddEditGuardianScreenState();
}

class _AddEditGuardianScreenState extends State<AddEditGuardianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _relationship = 'أم';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.guardian != null) {
      _nameController.text = widget.guardian!.name;
      _emailController.text = widget.guardian!.email;
      _phoneController.text = widget.guardian!.phone;
      _relationship = widget.guardian!.relationship;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final guardianRepo = context.read<GuardianRepository>();
    final authRepo = context.read<AuthRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guardian == null
            ? 'إضافة ولي أمر'
            : 'تعديل بيانات ولي الأمر'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth > 600 ? 600 : double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.backgroundSecondary,
                    child: Icon(Icons.face_3,
                        size: 50, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال الاسم' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _relationship,
                    decoration: const InputDecoration(
                      labelText: 'العلاقة',
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'أم', child: Text('أم')),
                      DropdownMenuItem(value: 'أب', child: Text('أب')),
                      DropdownMenuItem(value: 'آخر', child: Text('آخر')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _relationship = value);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  if (widget.guardian == null) {
                                    // إنشاء ولي أمر جديد
                                    await guardianRepo.createGuardian(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      relationship: _relationship,
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم الإضافة بنجاح'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  } else {
                                    // تحديث بيانات المستخدم
                                    await authRepo.updateUserProfile(
                                      widget.guardian!.userId,
                                      {
                                        'name': _nameController.text.trim(),
                                        'email': _emailController.text.trim(),
                                        'phone': _phoneController.text.trim(),
                                      },
                                    );
                                    // تحديث بيانات ولي الأمر
                                    await guardianRepo.updateGuardian(
                                      widget.guardian!.id,
                                      {
                                        'relationship': _relationship,
                                      },
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم الحفظ بنجاح'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  final msg = e.toString().toLowerCase();
                                  if (msg.contains('row-level') ||
                                      msg.contains('permission') ||
                                      msg.contains('rls')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'فشل الحفظ بسبب قيود الصلاحيات (RLS). نفّذ ملف `complete_admin_rls_policies.sql` في لوحة تحكم Supabase أو تواصل مع المشرف.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('حدث خطأ أثناء الحفظ: $e'),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted)
                                    setState(() => _isLoading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              widget.guardian == null
                                  ? 'إضافة'
                                  : 'حفظ التعديلات',
                              style: const TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
