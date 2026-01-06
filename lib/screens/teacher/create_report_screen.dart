import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

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
                  onChanged: (value) {},
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
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_document,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التقرير اليومي',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'املأ البيانات التالية لإرسال التقرير',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
              value: value,
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
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
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
      });
    }
  }
}
