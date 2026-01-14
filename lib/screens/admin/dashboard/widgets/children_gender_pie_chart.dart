import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ChildrenGenderPieChart extends StatefulWidget {
  final int boysCount;
  final int girlsCount;

  const ChildrenGenderPieChart({
    super.key,
    required this.boysCount,
    required this.girlsCount,
  });

  @override
  State<ChildrenGenderPieChart> createState() => _ChildrenGenderPieChartState();
}

class _ChildrenGenderPieChartState extends State<ChildrenGenderPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // If no data, show a placeholder or empty state
    if (widget.boysCount == 0 && widget.girlsCount == 0) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('لا توجد بيانات للأطفال حالياً'),
        ),
      );
    }

    final total = widget.boysCount + widget.girlsCount;
    final boysPercentage =
        ((widget.boysCount / total) * 100).toStringAsFixed(1);
    final girlsPercentage =
        ((widget.girlsCount / total) * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'توزيع الأطفال حسب الجنس',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        _showingSections(
                          value: widget.boysCount.toDouble(),
                          title: '$boysPercentage%',
                          color: AppColors.boy,
                          isTouched: touchedIndex == 0,
                          icon: Icons.boy,
                        ),
                        _showingSections(
                          value: widget.girlsCount.toDouble(),
                          title: '$girlsPercentage%',
                          color: AppColors.girl,
                          isTouched: touchedIndex == 1,
                          icon: Icons.girl,
                        ),
                      ],
                    ),
                  ),
                  Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('المجموع',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(total.toString(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ))
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('ذكور ($boysPercentage%)', AppColors.boy),
                const SizedBox(width: 24),
                _buildLegendItem('إناث ($girlsPercentage%)', AppColors.girl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _showingSections({
    required double value,
    required String title,
    required Color color,
    required bool isTouched,
    required IconData icon,
  }) {
    final fontSize = isTouched ? 20.0 : 14.0;
    final radius = isTouched ? 60.0 : 50.0;
    const shadows = [Shadow(color: Colors.black12, blurRadius: 2)];
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xffffffff),
        shadows: shadows,
      ),
      badgeWidget: isTouched
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Icon(icon, color: color, size: 20),
            )
          : null,
      badgePositionPercentageOffset: .98,
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
