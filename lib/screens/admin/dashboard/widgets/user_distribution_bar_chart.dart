import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class UserDistributionBarChart extends StatelessWidget {
  final int teachersCount;
  final int guardiansCount;
  final int childrenCount;

  const UserDistributionBarChart({
    super.key,
    required this.teachersCount,
    required this.guardiansCount,
    required this.childrenCount,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [teachersCount, guardiansCount, childrenCount]
            .reduce((curr, next) => curr > next ? curr : next)
            .toDouble() +
        2;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'توزيع المستخدمين',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        // getTooltipColor: (group) => Colors.blueGrey, // Removed as it might be deprecated or handled differently
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.round().toString(),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            bottomTitles(value, meta),
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.divider.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: teachersCount.toDouble(),
                          color: AppColors.secondary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6)),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: guardiansCount.toDouble(),
                          color: AppColors.accent,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6)),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: childrenCount.toDouble(),
                          color: AppColors.primary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6)),
                        )
                      ],
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

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'المعلمات';
        break;
      case 1:
        text = 'أولياء الأمور';
        break;
      case 2:
        text = 'الأطفال';
        break;
      default:
        text = '';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    // Only show integer titles
    if (value % 1 != 0) return Container();

    return Padding(
      padding: const EdgeInsets.only(left: 8.0), // Adjust alignment as needed
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: 10,
        ),
      ),
    );
  }
}
