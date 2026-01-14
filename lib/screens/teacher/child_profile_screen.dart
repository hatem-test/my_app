import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class ChildProfileScreen extends StatelessWidget {
  final String childId;

  const ChildProfileScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    // Mock child data
    final child = {
      'name': 'أحمد محمد',
      'age': '4 سنوات',
      'gender': 'ذكر',
      'class': 'الصف الأول',
    };

    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.edit_note_rounded,
        'title': 'كتابة تقرير',
        'color': AppColors.accent,
        'route': '/teacher/report/$childId',
      },
      {
        'icon': Icons.restaurant_rounded,
        'title': 'الوجبات',
        'color': AppColors.secondary,
        'route': '/teacher/meals/$childId',
      },
      {
        'icon': Icons.medical_services_rounded,
        'title': 'الحالة الصحية',
        'color': const Color(0xFFEF5350),
        'route': '/teacher/health/$childId',
      },
      {
        'icon': Icons.notes_rounded,
        'title': 'الملاحظات',
        'color': AppColors.primary,
        'route': '/teacher/notes/$childId',
      },
      {
        'icon': Icons.phone_rounded,
        'title': 'معلومات التواصل',
        'color': const Color(0xFF7E57C2),
        'route': '/teacher/contact/$childId',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('ملف الطفل'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Child Info Card
              _buildChildInfoCard(context, child, isSmallScreen),
              SizedBox(height: isSmallScreen ? 18 : 24),

              // Action Options
              ...actions.map(
                  (action) => _buildActionCard(context, action, isSmallScreen)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildInfoCard(
      BuildContext context, Map<String, dynamic> child, bool isSmallScreen) {
    final isMale = child['gender'] == 'ذكر';
    final color = isMale ? AppColors.boy : AppColors.girl;
    final imagePath =
        isMale ? 'assets/images/boy.png' : 'assets/images/girl.png';

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 70 : 90,
            height: isSmallScreen ? 70 : 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: isSmallScreen ? 35 : 45,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 14 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['name'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                _buildInfoRow(Icons.cake_rounded, child['age'], isSmallScreen),
                const SizedBox(height: 4),
                _buildInfoRow(
                  isMale ? Icons.male_rounded : Icons.female_rounded,
                  child['gender'],
                  isSmallScreen,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                    Icons.class_rounded, child['class'], isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 14 : 18,
          color: Colors.white.withOpacity(0.9),
        ),
        SizedBox(width: isSmallScreen ? 6 : 8),
        Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, Map<String, dynamic> action, bool isSmallScreen) {
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
      child: ListTile(
        onTap: () => context.push(action['route']),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 10 : 12,
        ),
        leading: Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: (action['color'] as Color).withOpacity(0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
          ),
          child: Icon(
            action['icon'],
            color: action['color'],
            size: isSmallScreen ? 22 : 26,
          ),
        ),
        title: Text(
          action['title'],
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: isSmallScreen ? 14 : 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
