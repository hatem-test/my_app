import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HealthScreen extends StatelessWidget {
  final String? childId;

  const HealthScreen({super.key, this.childId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    final Map<String, dynamic> healthData = {
      'generalStatus': 'جيدة',
      'temperature': '36.8°',
      'lastCheckup': 'منذ أسبوع',
      'vaccinations': 'محدثة',
    };

    final List<Map<String, dynamic>> healthNotes = [
      {
        'title': 'فحص دوري',
        'description': 'تم إجراء الفحص الدوري والنتائج سليمة',
        'date': '2024/01/01',
        'status': 'success',
      },
      {
        'title': 'تطعيم',
        'description': 'تم أخذ تطعيم الإنفلونزا الموسمية',
        'date': '2023/12/15',
        'status': 'info',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('الحالة الصحية'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthOverview(healthData, isSmallScreen),
              SizedBox(height: isSmallScreen ? 18 : 24),
              Text(
                'المؤشرات الصحية',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              _buildIndicatorsGrid(healthData, isSmallScreen),
              SizedBox(height: isSmallScreen ? 18 : 24),
              Text(
                'السجل الصحي',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              ...healthNotes
                  .map((note) => _buildHealthNoteCard(note, isSmallScreen)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthOverview(Map<String, dynamic> data, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
              color: AppColors.success.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10)),
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
                      fontSize: isSmallScreen ? 12 : 14, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  data['generalStatus'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
                    color: AppColors.success, size: isSmallScreen ? 14 : 18),
                SizedBox(width: isSmallScreen ? 4 : 6),
                Text(
                  data['vaccinations'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsGrid(Map<String, dynamic> data, bool isSmallScreen) {
    final indicators = [
      {
        'label': 'درجة الحرارة',
        'value': data['temperature'],
        'icon': Icons.thermostat_rounded,
        'color': AppColors.accent
      },
      {
        'label': 'آخر فحص',
        'value': data['lastCheckup'],
        'icon': Icons.medical_services_rounded,
        'color': AppColors.primary
      },
    ];

    return Row(
      children: indicators.map((indicator) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              boxShadow: [
                BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4))
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
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  indicator['label'] as String,
                  style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthNoteCard(Map<String, dynamic> note, bool isSmallScreen) {
    final Color statusColor =
        note['status'] == 'success' ? AppColors.success : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
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
                note['status'] == 'success'
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                color: statusColor,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['title'],
                    style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note['description'],
                    style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: isSmallScreen ? 12 : 14,
                          color: AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text(note['date'],
                          style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: AppColors.textDisabled)),
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
}
