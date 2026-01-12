import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : 2;
    final user = context.watch<AuthProvider>().currentUser;

    return MultiProvider(
      providers: [
        DataProviders.totalChildrenCountProvider(),
        DataProviders.totalTeachersCountProvider(),
        DataProviders.totalGuardiansCountProvider(),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة تحكم الأدمن'),
          centerTitle: true,
        ),
        drawer: const AdminDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك، ${user?.name ?? 'المدير'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Consumer3<int, int, int>(
                builder:
                    (context, childrenCount, teachersCount, guardiansCount, _) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: screenWidth > 1200
                        ? 1.5
                        : screenWidth > 800
                            ? 1.2
                            : screenWidth > 600
                                ? 1.0
                                : 0.85,
                    children: [
                      _buildStatCard(
                        context,
                        title: 'عدد الأطفال',
                        value: childrenCount.toString(),
                        icon: Icons.child_care,
                        color: AppColors.primary,
                      ),
                      _buildStatCard(
                        context,
                        title: 'عدد المعلمات',
                        value: teachersCount.toString(),
                        icon: Icons.person_outline,
                        color: AppColors.secondary,
                      ),
                      _buildStatCard(
                        context,
                        title: 'عدد أولياء الأمور',
                        value: guardiansCount.toString(),
                        icon: Icons.face_3,
                        color: AppColors.accent,
                      ),
                      _buildStatCard(
                        context,
                        title: 'التقارير اليوم',
                        value: '0', // يمكن إضافة موفر خاص بهذا لاحقاً
                        icon: Icons.article_outlined,
                        color: AppColors.error,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'آخر النشاطات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityItem('تم إضافة طفل جديد: أحمد محمد', 'منذ 5 دقائق'),
              _buildActivityItem(
                  'أرسلت المعلمة سارة تقرير يومي', 'منذ 15 دقيقة'),
              _buildActivityItem('قامت الأم ريم بتحديث بياناتها', 'منذ ساعة'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 30,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.backgroundSecondary,
          child: Icon(Icons.history, color: AppColors.textSecondary, size: 20),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.admin_panel_settings,
                      size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'لوحة الأدمن',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('الرئيسية'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('إدارة المعلمات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/teachers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.face_3),
            title: const Text('إدارة أولياء الأمور'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/guardians');
            },
          ),
          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text('إدارة الأطفال'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/children');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('التقارير'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/reports');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('تسجيل الخروج',
                style: TextStyle(color: AppColors.error)),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.logout();
            },
          ),
        ],
      ),
    );
  }
}
