import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddEditChildScreen extends StatefulWidget {
  final Map<String, dynamic>? child;

  const AddEditChildScreen({super.key, this.child});

  @override
  State<AddEditChildScreen> createState() => _AddEditChildScreenState();
}

class _AddEditChildScreenState extends State<AddEditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedTeacher;
  String? _selectedGuardian;

  // Dummy Data for Dropdowns
  final List<String> _teachers = ['سارة أحمد', 'نورة العلي', 'منى سالم'];
  final List<String> _guardians = [
    'ولي أمر أحمد',
    'ولي أمر سارة',
    'ولي أمر عمر'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.child != null) {
      _nameController.text = widget.child!['name'];
      _ageController.text = widget.child!['age']?.toString() ?? '';
      _selectedGender = widget.child!['gender'];
      _selectedTeacher = widget.child!['teacher'];
      _selectedGuardian = widget.child!['guardian'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.child == null ? 'إضافة طفل' : 'تعديل بيانات الطفل'),
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
                    child: Icon(Icons.child_care,
                        size: 50, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الطفل',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال اسم الطفل' : null,
                  ),
                  const SizedBox(height: 16),
                  // Age
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'العمر (بالسنوات)',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال العمر' : null,
                  ),
                  const SizedBox(height: 16),
                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'الجنس',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'D', child: Text('ذكر')),
                      DropdownMenuItem(value: 'K', child: Text('أنثى')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedGender = value),
                    validator: (value) =>
                        value == null ? 'يرجى اختيار الجنس' : null,
                  ),
                  const SizedBox(height: 16),
                  // Guardian Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGuardian,
                    decoration: const InputDecoration(
                      labelText: 'ولي الأمر',
                      prefixIcon: Icon(Icons.face_3_outlined),
                    ),
                    items: _guardians
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGuardian = value),
                    validator: (value) =>
                        value == null ? 'يرجى اختيار ولي الأمر' : null,
                  ),
                  const SizedBox(height: 16),
                  // Teacher Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTeacher,
                    decoration: const InputDecoration(
                      labelText: 'المعلمة المسؤولة',
                      prefixIcon: Icon(Icons.person_search_outlined),
                    ),
                    items: _teachers
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedTeacher = value),
                    validator: (value) =>
                        value == null ? 'يرجى اختيار المعلمة' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم الحفظ بنجاح'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.child == null ? 'إضافة' : 'حفظ التعديلات',
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
    _ageController.dispose();
    super.dispose();
  }
}
