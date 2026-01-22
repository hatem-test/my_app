import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/teacher_provider.dart';
import '../../models/report_model.dart';
import '../../repositories/report_repository.dart';

class CreateReportScreen extends StatefulWidget {
  final String? childId;

  const CreateReportScreen({super.key, this.childId});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();

  String _healthStatus = '';
  String _activity = '';
  String _behavior = '';
  String _sleep = '';
  String _eating = '';
  String _additionalNotes = '';

  bool _isLoading = false;

  final List<String> _healthOptions = [
    'ممتازة',
    'جيدة',
    'متوسطة',
    'تحتاج متابعة'
  ];
  final List<String> _activityOptions = ['نشيط جداً', 'نشيط', 'متوسط', 'هادئ'];
  final List<String> _behaviorOptions = ['ممتاز', 'جيد', 'يحتاج تحسين'];
  final List<String> _sleepOptions = ['نام جيداً', 'نوم متقطع', 'لم ينم'];
  final List<String> _eatingOptions = [
    'أكل كل وجبته',
    'أكل معظمها',
    'أكل قليلاً',
    'لم يأكل'
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('كتابة تقرير'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(isSmallScreen),
                SizedBox(height: isSmallScreen ? 18 : 24),
                _buildDropdownField(
                  label: 'الحالة الصحية',
                  icon: Icons.medical_services_rounded,
                  value: _healthStatus.isEmpty ? null : _healthStatus,
                  options: _healthOptions,
                  onChanged: (value) =>
                      setState(() => _healthStatus = value ?? ''),
                  isSmallScreen: isSmallScreen,
                ),
                _buildDropdownField(
                  label: 'النشاط',
                  icon: Icons.directions_run_rounded,
                  value: _activity.isEmpty ? null : _activity,
                  options: _activityOptions,
                  onChanged: (value) => setState(() => _activity = value ?? ''),
                  isSmallScreen: isSmallScreen,
                ),
                _buildDropdownField(
                  label: 'السلوك',
                  icon: Icons.emoji_emotions_rounded,
                  value: _behavior.isEmpty ? null : _behavior,
                  options: _behaviorOptions,
                  onChanged: (value) => setState(() => _behavior = value ?? ''),
                  isSmallScreen: isSmallScreen,
                ),
                _buildDropdownField(
                  label: 'النوم',
                  icon: Icons.bedtime_rounded,
                  value: _sleep.isEmpty ? null : _sleep,
                  options: _sleepOptions,
                  onChanged: (value) => setState(() => _sleep = value ?? ''),
                  isSmallScreen: isSmallScreen,
                ),
                _buildDropdownField(
                  label: 'الأكل',
                  icon: Icons.restaurant_rounded,
                  value: _eating.isEmpty ? null : _eating,
                  options: _eatingOptions,
                  onChanged: (value) => setState(() => _eating = value ?? ''),
                  isSmallScreen: isSmallScreen,
                ),
                _buildTextAreaField(
                  label: 'ملاحظات إضافية',
                  icon: Icons.notes_rounded,
                  onChanged: (value) {
                    _additionalNotes = value;
                  },
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                _buildSubmitButton(isSmallScreen),
                SizedBox(height: isSmallScreen ? 18 : 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isSmallScreen) {
    final now = DateTime.now();
    final day = now.day.toString();
    final month = _getArabicMonth(now.month);
    final weekday = _getArabicWeekday(now.weekday);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'تقرير اليوم',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        weekday,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'تسجيل النشاط اليومي للطفل',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getArabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

  String _getArabicWeekday(int weekday) {
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return weekdays[weekday - 1];
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isSmallScreen,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: AppColors.primary, size: isSmallScreen ? 18 : 22),
                SizedBox(width: isSmallScreen ? 8 : 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),
            DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 10 : 12,
                ),
              ),
              hint: Text('اختر...',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
              isExpanded: true,
              items: options.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: onChanged,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'هذا الحقل مطلوب' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required bool isSmallScreen,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: AppColors.primary, size: isSmallScreen ? 18 : 22),
                SizedBox(width: isSmallScreen ? 8 : 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  ' (اختياري)',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'أضف ملاحظات إضافية هنا...',
                hintStyle: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 48 : 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16)),
          elevation: 4,
        ),
        child: _isLoading
            ? SizedBox(
                width: isSmallScreen ? 20 : 24,
                height: isSmallScreen ? 20 : 24,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: isSmallScreen ? 18 : 22),
                  SizedBox(width: isSmallScreen ? 8 : 10),
                  Text(
                    'إرسال التقرير',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) return;

    // يجب أن يكون هناك طفل محدد لكتابة التقرير له
    final childId = widget.childId;
    if (childId == null || childId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار طفل أولاً قبل كتابة التقرير'),
        ),
      );
      return;
    }

    // جلب بيانات المعلمة الحالية
    final teacherProvider = context.read<TeacherProvider>();
    final teacher = teacherProvider.profile;

    if (teacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'تعذّر جلب بيانات المعلمة، يرجى إعادة فتح التطبيق والمحاولة'),
        ),
      );
      return;
    }

    final repo = context.read<ReportRepository>();

    setState(() => _isLoading = true);

    final report = ReportModel(
      id: '', // سيتم توليده من Supabase، ولا يُستخدم في toInsertJson
      childId: childId,
      teacherId: teacher.id,
      healthStatus: _healthStatus,
      activity: _activity,
      behavior: _behavior,
      sleep: _sleep,
      eating: _eating,
      additionalNotes: _additionalNotes.isEmpty ? null : _additionalNotes,
      reportDate: DateTime.now(),
    );

    repo.createReport(report).then((_) {
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('تم إرسال التقرير بنجاح!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('سيتم إشعار ولي الأمر بالتقرير الجديد',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('حسناً'),
              ),
            ),
          ],
        ),
      );
    }).catchError((error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ التقرير: $error'),
        ),
      );
    });
  }
}
