import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String _selectedGender = 'boy';
  File? _image;

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
    final height = size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة طفل')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.06),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Container(
                    width: width * 0.3,
                    height: width * 0.3,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _image == null
                        ? Icon(Icons.add_a_photo,
                            size: width * 0.1, color: AppColors.textSecondary)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'صورة الطفل',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: width * 0.035),
              ),
              SizedBox(height: height * 0.04),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الطفل',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              SizedBox(height: height * 0.02),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _birthDate = date);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.03, vertical: height * 0.02),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(width * 0.03),
                    color: AppColors.backgroundSecondary,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: AppColors.textSecondary, size: width * 0.06),
                      SizedBox(width: width * 0.03),
                      Text(
                        _birthDate == null
                            ? 'تاريخ الميلاد'
                            : '${_birthDate!.year}-${_birthDate!.month}-${_birthDate!.day}',
                        style: TextStyle(
                          color: _birthDate == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
              Text('النوع',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: width * 0.04)),
              SizedBox(height: height * 0.01),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03, vertical: height * 0.005),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedGender == 'boy' ? Colors.blue : Colors.pink,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(width * 0.03),
                  color: (_selectedGender == 'boy' ? Colors.blue : Colors.pink)
                      .withValues(alpha: 0.1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color:
                          _selectedGender == 'boy' ? Colors.blue : Colors.pink,
                      size: width * 0.08,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'boy',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'ولد',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: width * 0.02),
                            Icon(Icons.boy,
                                color: Colors.blue, size: width * 0.06),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'girl',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'بنت',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: width * 0.02),
                            Icon(Icons.girl,
                                color: Colors.pink, size: width * 0.06),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGender = value);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: height * 0.06),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _birthDate != null) {
                    // Save and pop
                    Navigator.of(context).pop();
                  } else if (_birthDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('الرجاء اختيار تاريخ الميلاد')),
                    );
                  }
                },
                child: Text('حفظ البيانات',
                    style: TextStyle(fontSize: width * 0.045)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
