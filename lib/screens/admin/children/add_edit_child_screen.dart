import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../repositories/children_repository.dart';
import '../../../../repositories/teacher_repository.dart';
import '../../../../repositories/guardian_repository.dart';
import '../../../../models/models.dart';

class AddEditChildScreen extends StatefulWidget {
  final Map<String, dynamic>? child;

  const AddEditChildScreen({super.key, this.child});

  @override
  State<AddEditChildScreen> createState() => _AddEditChildScreenState();
}

class _AddEditChildScreenState extends State<AddEditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();

  String? _selectedGender;
  String? _selectedTeacherId;
  String? _selectedGuardianId;
  DateTime? _selectedBirthDate;

  List<TeacherModel> _teachers = [];
  List<GuardianModel> _guardians = [];
  bool _isLoading = true;
  String? _errorMessage;

  File? _image;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teacherRepo = context.read<TeacherRepository>();
      final guardianRepo = context.read<GuardianRepository>();

      final teachers = await teacherRepo.getAllTeachers();
      final guardians = await guardianRepo.getAllGuardians();

      setState(() {
        _teachers = teachers;
        _guardians = guardians;
        _isLoading = false;
      });

      // تحميل بيانات الطفل إذا كان في وضع التعديل
      if (widget.child != null) {
        _loadChildData();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء جلب البيانات: $e';
        _isLoading = false;
      });
    }
  }

  void _loadChildData() {
    try {
      final childData = widget.child!;
      _nameController.text = childData['name']?.toString() ?? '';

      if (childData['birth_date'] != null) {
        final birthDateStr = childData['birth_date'].toString();
        try {
          _selectedBirthDate = DateTime.parse(birthDateStr);
          _birthDateController.text = _formatDate(_selectedBirthDate!);
        } catch (e) {
          debugPrint('Error parsing birth date: $e');
        }
      }

      _selectedGender = childData['gender']?.toString();
      _selectedTeacherId = childData['teacher_id']?.toString();
      _selectedGuardianId = childData['guardian_id']?.toString();
      _uploadedImageUrl = childData['image_url']?.toString();
    } catch (e) {
      debugPrint('Error loading child data: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365 * 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ الميلاد'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final repository = context.read<ChildrenRepository>();
      final gender = _selectedGender == 'D' || _selectedGender == 'boy'
          ? Gender.boy
          : Gender.girl;

      String? imageUrl = _uploadedImageUrl;
      if (_image != null) {
        imageUrl = await repository.uploadImage(_image!);
      }

      if (widget.child == null) {
        // إضافة طفل جديد
        final newChild = ChildModel(
          id: '', // سيتم إنشاؤه تلقائياً
          guardianId: _selectedGuardianId!,
          teacherId: _selectedTeacherId,
          name: _nameController.text.trim(),
          birthDate: _selectedBirthDate!,
          gender: gender,
          imageUrl: imageUrl,
        );

        await repository.createChild(newChild);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الطفل بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // تحديث بيانات الطفل
        final updateData = <String, dynamic>{
          'name': _nameController.text.trim(),
          'birth_date': _formatDate(_selectedBirthDate!),
          'gender': gender.name,
          'guardian_id': _selectedGuardianId,
          'teacher_id': _selectedTeacherId,
          'image_url': imageUrl,
        };

        await repository.updateChild(widget.child!['id'], updateData);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث البيانات بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                // تحديد الجنس الحالي
                                final isBoy = _selectedGender == 'boy' ||
                                    _selectedGender == 'D' ||
                                    (widget.child != null &&
                                        widget.child!['gender']?.toString() ==
                                            'boy');

                                final defaultImagePath = isBoy
                                    ? 'assets/images/boy.png'
                                    : 'assets/images/girl.png';
                                final defaultColor =
                                    isBoy ? AppColors.boy : AppColors.girl;

                                final displayImage = _image != null
                                    ? FileImage(_image!)
                                    : (_uploadedImageUrl != null &&
                                            _uploadedImageUrl!.isNotEmpty
                                        ? NetworkImage(_uploadedImageUrl!)
                                        : null);

                                return GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor:
                                            defaultColor.withOpacity(0.1),
                                        backgroundImage:
                                            displayImage as ImageProvider?,
                                        child: displayImage == null
                                            ? ClipOval(
                                                child: Image.asset(
                                                  defaultImagePath,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.camera_alt,
                                              color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Name
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم الطفل',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'يرجى إدخال اسم الطفل'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // Birth Date
                            TextFormField(
                              controller: _birthDateController,
                              decoration: const InputDecoration(
                                labelText: 'تاريخ الميلاد',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: _selectBirthDate,
                              validator: (value) => value!.isEmpty
                                  ? 'يرجى اختيار تاريخ الميلاد'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // Gender Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'الجنس',
                                prefixIcon: Icon(Icons.wc),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'boy', child: Text('ذكر')),
                                DropdownMenuItem(
                                    value: 'girl', child: Text('أنثى')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                  // تحديث الصورة عند تغيير الجنس
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'يرجى اختيار الجنس' : null,
                            ),
                            const SizedBox(height: 16),
                            // Guardian Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGuardianId,
                              decoration: const InputDecoration(
                                labelText: 'ولي الأمر',
                                prefixIcon: Icon(Icons.face_3_outlined),
                              ),
                              items: _guardians
                                  .map((g) => DropdownMenuItem(
                                        value: g.id,
                                        child: Text(g.name),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedGuardianId = value),
                              validator: (value) => value == null
                                  ? 'يرجى اختيار ولي الأمر'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // Teacher Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedTeacherId,
                              decoration: const InputDecoration(
                                labelText: 'المعلمة المسؤولة',
                                prefixIcon: Icon(Icons.person_search_outlined),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('لا يوجد'),
                                ),
                                ..._teachers.map((t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text(t.name),
                                    )),
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedTeacherId = value),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveChild,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  widget.child == null
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
    _birthDateController.dispose();
    super.dispose();
  }
}
