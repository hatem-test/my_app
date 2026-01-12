import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../repositories/children_repository.dart';

class EditChildProfileScreen extends StatefulWidget {
  final String childId;

  const EditChildProfileScreen({super.key, required this.childId});

  @override
  State<EditChildProfileScreen> createState() => _EditChildProfileScreenState();
}

class _EditChildProfileScreenState extends State<EditChildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String _selectedGender = 'boy';
  String _selectedClass = 'الصف الأول';
  File? _image;
  String? _networkImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  final _childrenRepo = ChildrenRepository();

  final List<String> _classes = ['الصف الأول', 'الصف الثاني', 'الصف الثالث'];

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    try {
      final child = await _childrenRepo.getChildById(widget.childId);
      if (child != null) {
        setState(() {
          _nameController.text = child.name;
          _birthDate = child.birthDate;
          _selectedGender = child.gender.name;
          _selectedClass = child.className ?? 'الصف الأول';
          _networkImageUrl = child.imageUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تاريخ الميلاد')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _networkImageUrl;
      if (_image != null) {
        imageUrl = await _childrenRepo.uploadImage(_image!);
      }

      await _childrenRepo.updateChild(widget.childId, {
        'name': _nameController.text.trim(),
        'birth_date': _birthDate!.toIso8601String().split('T').first,
        'gender': _selectedGender,
        'class_name': _selectedClass,
        'image_url': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بيانات الطفل بنجاح')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التحديث: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('تعديل ملف الطفل'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.04),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePicker(width),
                    SizedBox(height: width * 0.08),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الطفل',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'الرجاء إدخال اسم الطفل'
                          : null,
                    ),
                    SizedBox(height: width * 0.04),
                    _buildBirthDatePicker(width),
                    SizedBox(height: width * 0.04),
                    _buildGenderSelector(width),
                    SizedBox(height: width * 0.04),
                    DropdownButtonFormField<String>(
                      value: _selectedClass,
                      items: _classes
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedClass = val!),
                      decoration: InputDecoration(
                        labelText: 'الصف',
                        prefixIcon: const Icon(Icons.class_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: width * 0.08),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChild,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text(
                                'حفظ التغييرات',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBirthDatePicker(double width) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _birthDate ?? DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _birthDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              _birthDate == null
                  ? 'تاريخ الميلاد'
                  : DateFormat('yyyy-MM-dd').format(_birthDate!),
              style: TextStyle(
                color: _birthDate == null ? Colors.grey[600] : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(double width) {
    final isBoy = _selectedGender == 'boy';
    final color = isBoy ? AppColors.boy : AppColors.girl;
    final defaultImage =
        isBoy ? 'assets/images/boy.png' : 'assets/images/girl.png';

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: width * 0.3,
              height: width * 0.3,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: ClipOval(
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : _networkImageUrl != null
                        ? Image.network(
                            _networkImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(defaultImage, fit: BoxFit.cover),
                          )
                        : Image.asset(defaultImage, fit: BoxFit.cover),
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
                child:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector(double width) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('الجنس', style: TextStyle(color: Colors.grey[700])),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('ولد'),
                  value: 'boy',
                  groupValue: _selectedGender,
                  activeColor: AppColors.boy,
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('بنت'),
                  value: 'girl',
                  groupValue: _selectedGender,
                  activeColor: AppColors.girl,
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
