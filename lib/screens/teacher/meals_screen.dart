import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MealsScreen extends StatelessWidget {
  final String? childId;

  const MealsScreen({super.key, this.childId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    final List<Map<String, dynamic>> meals = [
      {
        'name': 'الفطور',
        'time': '8:30 صباحاً',
        'items': ['حليب', 'خبز', 'جبنة', 'فاكهة'],
        'icon': Icons.free_breakfast_rounded,
        'color': AppColors.accent,
      },
      {
        'name': 'وجبة خفيفة',
        'time': '10:30 صباحاً',
        'items': ['بسكويت', 'عصير'],
        'icon': Icons.cookie_rounded,
        'color': AppColors.secondary,
      },
      {
        'name': 'الغداء',
        'time': '12:30 ظهراً',
        'items': ['أرز', 'دجاج', 'خضروات', 'سلطة'],
        'icon': Icons.lunch_dining_rounded,
        'color': AppColors.primary,
      },
    ];

    final List<String> allergies = ['الفول السوداني', 'البيض'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('الوجبات'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (allergies.isNotEmpty) ...[
                _buildAllergyWarning(allergies, isSmallScreen),
                SizedBox(height: isSmallScreen ? 16 : 20),
              ],
              Text(
                'وجبات اليوم',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              ...meals.map((meal) => _buildMealCard(meal, isSmallScreen)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllergyWarning(List<String> allergies, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(color: AppColors.warning.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: const Color(0xFFFF8F00),
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحذير من الحساسية',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF8F00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حساسية من: ${allergies.join('، ')}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
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

  Widget _buildMealCard(Map<String, dynamic> meal, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: (meal['color'] as Color).withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 12 : 14),
                  ),
                  child: Icon(
                    meal['icon'],
                    color: meal['color'],
                    size: isSmallScreen ? 22 : 26,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['name'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: isSmallScreen ? 14 : 16,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            meal['time'],
                            style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            const Divider(height: 1),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (meal['items'] as List<String>).map((item) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 14,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
