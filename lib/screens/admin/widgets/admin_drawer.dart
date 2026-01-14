import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';

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
              Navigator.pop(context); // Close drawer
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('إدارة الوجبات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/meals');
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
            leading: const Icon(Icons.family_restroom),
            title: const Text('إدارة أولياء الأمور'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/guardians');
            },
          ),
          ListTile(
            leading: Icon(Icons.boy),
            title: const Text('إدارة الأطفال'),
            onTap: () {
              Navigator.pop(context); // Close drawer first
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
            leading: const Icon(Icons.person),
            title: const Text('ملفي الشخصي'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/profile');
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
