import 'package:flutter/material.dart';
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
                onTap: () {
                  // Pick Image
                },
                child: Center(
                  child: Container(
                    width: width * 0.3,
                    height: width * 0.3,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Icon(Icons.add_a_photo,
                        size: width * 0.1, color: AppColors.textSecondary),
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
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      label: 'ولد',
                      icon: Icons.boy,
                      isSelected: _selectedGender == 'boy',
                      onTap: () => setState(() => _selectedGender = 'boy'),
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: _GenderCard(
                      label: 'بنت',
                      icon: Icons.girl,
                      isSelected: _selectedGender == 'girl',
                      onTap: () => setState(() => _selectedGender = 'girl'),
                      color: Colors.pink,
                    ),
                  ),
                ],
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

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.02),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(width * 0.03),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: width * 0.1,
                color: isSelected ? color : AppColors.textDisabled),
            SizedBox(height: height * 0.01),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.textDisabled,
                fontSize: width * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
