import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/constants/app_colors.dart';
import '../../../../models/models.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportDetailScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final report = ReportModel.fromJson(reportData);
    final childName = reportData['children'] != null
        ? reportData['children']['name']
        : 'طفل غير معروف';

    final teacherData = reportData['teachers'];
    final teacherName = (teacherData != null && teacherData['users'] != null)
        ? teacherData['users']['name']
        : 'معلمة غير معروفة';

    final dateFormat = intl.DateFormat('yyyy/MM/dd hh:mm a', 'ar');
    final dateString = dateFormat.format(report.createdAt ?? report.reportDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التقرير'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.assignment_ind,
                        size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      childName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            dateString,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.secondary.withOpacity(0.2),
                          child: const Icon(Icons.person,
                              size: 18, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'كتب التقرير: ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          teacherName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Details Grid
            Row(
              children: [
                Expanded(
                    child: _DetailItem(
                        icon: Icons.health_and_safety,
                        label: 'الصحة',
                        value: report.healthStatus,
                        color: Colors.red)),
                const SizedBox(width: 12),
                Expanded(
                    child: _DetailItem(
                        icon: Icons.mood,
                        label: 'السلوك/المزاج',
                        value: report.behavior,
                        color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _DetailItem(
                        icon: Icons.restaurant,
                        label: 'الأكل',
                        value: report.eating,
                        color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _DetailItem(
                        icon: Icons.bed,
                        label: 'النوم',
                        value: report.sleep,
                        color: Colors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _DetailItem(
                      icon: Icons.local_activity,
                      label: 'النشاط',
                      value: report.activity,
                      color: Colors.blue)),
            ]),

            const SizedBox(height: 20),

            // Notes
            if (report.additionalNotes != null &&
                report.additionalNotes!.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.note, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('ملاحظات إضافية',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        report.additionalNotes!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
