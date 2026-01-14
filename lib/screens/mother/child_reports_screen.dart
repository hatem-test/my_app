import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../repositories/report_repository.dart';
import '../../repositories/children_repository.dart';

class ChildReportsScreen extends StatelessWidget {
  final String childId;

  const ChildReportsScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final reportRepo = context.read<ReportRepository>();
    final childrenRepo = context.read<ChildrenRepository>();
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isSmallScreen = width < 360;
    final padding = width * 0.04;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('تقارير الطفل'),
          centerTitle: true,
          elevation: 0,
        ),
        body: StreamBuilder<ChildModel?>(
          stream: childrenRepo.watchChild(childId),
          builder: (context, childSnapshot) {
            final child = childSnapshot.data;
            final childName = child?.name ?? 'الطفل';

            return StreamBuilder<List<ReportModel>>(
              stream: reportRepo.watchReports(childId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            'حدث خطأ أثناء جلب التقارير',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final reports = snapshot.data ?? [];

                if (reports.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                              decoration: const BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.assignment_outlined,
                                  size: isSmallScreen ? 48 : 64,
                                  color: AppColors.textDisabled),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'لا توجد تقارير بعد',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'سيتم عرض التقارير هنا بمجرد إرسالها من المعلمة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Stream يقوم بالتحديث تلقائياً
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(padding),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportCard(
                        context,
                        report,
                        childName,
                        isSmallScreen,
                        padding,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    ReportModel report,
    String childName,
    bool isSmallScreen,
    double padding,
  ) {
    final reportDate = report.reportDate;
    final dateStr = _formatDate(reportDate);
    final timeStr = _formatTime(report.createdAt ?? reportDate);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showReportDetails(context, report, childName, isSmallScreen),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: AppColors.primary,
                      size: isSmallScreen ? 22 : 26,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقرير يوم $dateStr',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: isSmallScreen ? 16 : 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildReportSummary(report, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSummary(ReportModel report, bool isSmallScreen) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatusChip(
          Icons.medical_services_rounded,
          'صحة: ${report.healthStatus}',
          AppColors.primary,
          isSmallScreen,
        ),
        _buildStatusChip(
          Icons.directions_run_rounded,
          'نشاط: ${report.activity}',
          AppColors.accent,
          isSmallScreen,
        ),
        _buildStatusChip(
          Icons.emoji_emotions_rounded,
          'سلوك: ${report.behavior}',
          Colors.orange,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    IconData icon,
    String label,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 14 : 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(
    BuildContext context,
    ReportModel report,
    String childName,
    bool isSmallScreen,
  ) {
    final reportDate = report.reportDate;
    final dateStr = _formatDate(reportDate);
    final timeStr = _formatTime(report.createdAt ?? reportDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isSmallScreen ? 24 : 28),
          ),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: AppColors.primary,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقرير يوم $dateStr',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                Icons.medical_services_rounded,
                'الحالة الصحية',
                report.healthStatus,
                AppColors.primary,
                isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.directions_run_rounded,
                'النشاط',
                report.activity,
                AppColors.accent,
                isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.emoji_emotions_rounded,
                'السلوك',
                report.behavior,
                Colors.orange,
                isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.bedtime_rounded,
                'النوم',
                report.sleep,
                Colors.indigo,
                isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.restaurant_rounded,
                'الأكل',
                report.eating,
                Colors.green,
                isSmallScreen,
              ),
              if (report.additionalNotes != null &&
                  report.additionalNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.notes_rounded,
                  'ملاحظات إضافية',
                  report.additionalNotes!,
                  AppColors.textSecondary,
                  isSmallScreen,
                ),
              ],
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'تم الإرسال في الساعة $hour:$minute';
  }
}
