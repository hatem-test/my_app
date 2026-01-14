import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../repositories/health_record_repository.dart';
import '../../repositories/children_repository.dart';

class ChildHealthScreen extends StatelessWidget {
  final String childId;

  const ChildHealthScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final healthRepo = context.read<HealthRecordRepository>();
    final childrenRepo = context.read<ChildrenRepository>();
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isSmallScreen = width < 360;
    final padding = width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('الحالة الصحية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<ChildModel?>(
        stream: childrenRepo.watchChild(childId),
        builder: (context, childSnapshot) {
          final child = childSnapshot.data;

          return StreamBuilder<List<HealthRecordModel>>(
            stream: healthRepo.watchHealthRecords(childId),
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
                          'حدث خطأ أثناء جلب السجلات الصحية',
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

              final healthRecords = snapshot.data ?? [];
              final latestRecord = healthRecords.isNotEmpty
                  ? healthRecords.first
                  : null;

              return RefreshIndicator(
                onRefresh: () async {
                  // Stream يقوم بالتحديث تلقائياً
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (latestRecord != null)
                        _buildHealthOverview(
                            latestRecord, child, isSmallScreen),
                      if (latestRecord != null)
                        SizedBox(height: isSmallScreen ? 18 : 24),
                      if (latestRecord != null) ...[
                        Text(
                          'المؤشرات الصحية',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontSize: isSmallScreen ? 18 : 20,
                              ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildIndicatorsGrid(latestRecord, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 18 : 24),
                      ],
                      Text(
                        'السجل الصحي',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: isSmallScreen ? 18 : 20,
                            ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      if (healthRecords.isEmpty)
                        _buildEmptyState(isSmallScreen, padding)
                      else
                        ...healthRecords
                            .map((record) => _buildHealthNoteCard(
                                  record,
                                  isSmallScreen,
                                )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHealthOverview(
    HealthRecordModel latestRecord,
    ChildModel? child,
    bool isSmallScreen,
  ) {
    final statusColor = _getStatusColor(latestRecord.generalStatus);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.favorite_rounded,
                color: Colors.white, size: isSmallScreen ? 30 : 36),
          ),
          SizedBox(width: isSmallScreen ? 14 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحالة العامة',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  latestRecord.generalStatus,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (latestRecord.vaccinations != null &&
              latestRecord.vaccinations!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 14,
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: statusColor, size: isSmallScreen ? 14 : 18),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    latestRecord.vaccinations!,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsGrid(
    HealthRecordModel latestRecord,
    bool isSmallScreen,
  ) {
    final indicators = <Map<String, dynamic>>[];

    if (latestRecord.temperature != null) {
      indicators.add({
        'label': 'درجة الحرارة',
        'value': latestRecord.temperature!,
        'icon': Icons.thermostat_rounded,
        'color': AppColors.accent,
      });
    }

    indicators.add({
      'label': 'آخر فحص',
      'value': _formatDate(latestRecord.recordDate),
      'icon': Icons.medical_services_rounded,
      'color': AppColors.primary,
    });

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: indicators.map((indicator) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: (indicator['color'] as Color).withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 12 : 14),
                  ),
                  child: Icon(indicator['icon'] as IconData,
                      color: indicator['color'] as Color,
                      size: isSmallScreen ? 22 : 26),
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),
                Text(
                  indicator['value'] as String,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  indicator['label'] as String,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthNoteCard(
    HealthRecordModel record,
    bool isSmallScreen,
  ) {
    final Color statusColor = _getStatusColor(record.generalStatus);
    final IconData statusIcon = _getStatusIcon(record.recordType);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6 : 8,
                          vertical: isSmallScreen ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record.recordTypeText,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (record.description != null &&
                      record.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      record.description!,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: isSmallScreen ? 12 : 14,
                          color: AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(record.recordDate),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen, double padding) {
    return Center(
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
              child: Icon(Icons.medical_services_outlined,
                  size: isSmallScreen ? 48 : 64,
                  color: AppColors.textDisabled),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد سجلات صحية بعد',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم عرض السجلات الصحية هنا عند إضافتها من قبل المعلمة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('جيدة') ||
        status.contains('ممتازة') ||
        status.contains('سليمة')) {
      return AppColors.success;
    } else if (status.contains('متوسطة') || status.contains('عادية')) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  IconData _getStatusIcon(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.checkup:
        return Icons.medical_services_rounded;
      case HealthRecordType.vaccination:
        return Icons.vaccines_rounded;
      case HealthRecordType.note:
        return Icons.note_rounded;
    }
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
}
