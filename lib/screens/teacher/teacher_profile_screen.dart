import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(context, isSmallScreen),
            SizedBox(height: isSmallScreen ? 18 : 24),

            // Profile Options
            _buildOptionCard(
              icon: Icons.person_outline_rounded,
              title: 'تعديل المعلومات الشخصية',
              isSmallScreen: isSmallScreen,
              onTap: () {},
            ),
            _buildOptionCard(
              icon: Icons.lock_outline_rounded,
              title: 'تغيير كلمة المرور',
              isSmallScreen: isSmallScreen,
              onTap: () {},
            ),
            _buildOptionCard(
              icon: Icons.notifications_outlined,
              title: 'إعدادات الإشعارات',
              isSmallScreen: isSmallScreen,
              onTap: () {},
            ),
            _buildOptionCard(
              icon: Icons.help_outline_rounded,
              title: 'المساعدة والدعم',
              isSmallScreen: isSmallScreen,
              onTap: () {},
            ),
            SizedBox(height: isSmallScreen ? 18 : 24),

            // Logout Button
            _buildLogoutButton(context, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
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
            child: Icon(
              Icons.person_rounded,
              size: isSmallScreen ? 40 : 50,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'سارة المحمد',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'معلمة - روضة الأمل',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'sara@email.com',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 6 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: isSmallScreen ? 14 : 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
      ),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'تسجيل الخروج',
                textAlign: TextAlign.center,
              ),
              content: const Text(
                'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          );
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 6 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.logout_rounded,
            color: AppColors.error,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
