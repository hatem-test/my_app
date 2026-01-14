import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../models/models.dart';
import '../../../repositories/teacher_repository.dart';
import '../../../repositories/auth_repository.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final TeacherModel? teacher;

  const AddEditTeacherScreen({super.key, this.teacher});

  @override
  State<AddEditTeacherScreen> createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      _nameController.text = widget.teacher!.name;
      _emailController.text = widget.teacher!.email;
      _phoneController.text = widget.teacher!.phone;
      _specializationController.text = widget.teacher!.specialization ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final teacherRepo = context.read<TeacherRepository>();
    final authRepo = context.read<AuthRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.teacher == null ? 'إضافة معلمة' : 'تعديل بيانات المعلمة'),
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
                  // Teacher Image
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.backgroundSecondary,
                    child: Icon(Icons.person,
                        size: 50, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  // Name
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
                  // Email
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
                  // Phone
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
                  // Specialization
                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(
                      labelText: 'التخصص / الدور',
                      helperText: 'مثال: معلمة صف، مساعدة، معلمة لغة',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  if (widget.teacher == null) {
                                    // إنشاء معلمة جديدة
                                    await teacherRepo.createTeacher(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      specialization:
                                          _specializationController.text.trim(),
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم الإضافة بنجاح'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  } else {
                                    // تحديث بيانات المستخدم المرتبط
                                    await authRepo.updateUserProfile(
                                      widget.teacher!.userId,
                                      {
                                        'name': _nameController.text.trim(),
                                        'email': _emailController.text.trim(),
                                        'phone': _phoneController.text.trim(),
                                      },
                                    );

                                    // تحديث بيانات المعلمة
                                    await teacherRepo.updateTeacher(
                                      widget.teacher!.id,
                                      {
                                        'specialization':
                                            _specializationController.text
                                                .trim(),
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
                              widget.teacher == null
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
    _specializationController.dispose();
    super.dispose();
  }
}
