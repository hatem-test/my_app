import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/teacher_provider.dart';
import '../../models/models.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;
    final authProvider = context.watch<AuthProvider>();
    final teacherProvider = context.watch<TeacherProvider>();
    final teacher = teacherProvider.profile;

    if (teacher == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
            _buildProfileHeader(context, isSmallScreen, authProvider, teacher),
            SizedBox(height: isSmallScreen ? 18 : 24),

            // Profile Options
            _buildOptionCard(
              icon: Icons.person_outline_rounded,
              title: 'تعديل المعلومات الشخصية',
              isSmallScreen: isSmallScreen,
              onTap: () => context.push('/teacher/profile/edit'),
            ),
            _buildOptionCard(
              icon: Icons.lock_outline_rounded,
              title: 'تغيير كلمة المرور',
              isSmallScreen: isSmallScreen,
              onTap: () => context.push('/teacher/profile/change-password'),
            ),
            _buildOptionCard(
              icon: Icons.notifications_outlined,
              title: 'إعدادات الإشعارات',
              isSmallScreen: isSmallScreen,
              onTap: () => context.push('/teacher/profile/notifications'),
            ),
            _buildOptionCard(
              icon: Icons.help_outline_rounded,
              title: 'المساعدة والدعم',
              isSmallScreen: isSmallScreen,
              onTap: () => context.push('/teacher/profile/help'),
            ),
            SizedBox(height: isSmallScreen ? 18 : 24),

            // Logout Button
            _buildLogoutButton(context, isSmallScreen, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isSmallScreen,
      AuthProvider auth, TeacherModel teacher) {
    final user = auth.currentUser;
    return Container(
      width: double.infinity,
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
            child: Icon(
              Icons.person_rounded,
              size: isSmallScreen ? 36 : 45,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: isSmallScreen ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? teacher.name,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    teacher.specializationText,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: isSmallScreen ? 14 : 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
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

  Widget _buildLogoutButton(
      BuildContext context, bool isSmallScreen, AuthProvider auth) {
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
                  onPressed: () async {
                    Navigator.pop(context);
                    await auth.logout();
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
