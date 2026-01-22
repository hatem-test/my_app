import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/providers/data_providers.dart';
import 'teacher_home_screen.dart';
import 'notifications_screen.dart';
import 'teacher_profile_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  bool _loadingInitiated = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, teacherProvider, _) {
        // ضمان تحميل ملف المعلمة بمجرد توفر المستخدم في AuthProvider
        final authProvider = context.watch<AuthProvider>();
        final userId = authProvider.currentUser?.id;

        if (userId != null &&
            !_loadingInitiated &&
            teacherProvider.profile == null) {
          _loadingInitiated = true;
          // استدعاء التحميل في microtask لتجنب استدعائه مباشرة داخل build
          Future.microtask(() {
            if (mounted) {
              context.read<TeacherProvider>().loadProfile(userId);
            }
          });
        }

        // إعادة تعيين العلم عند تغيير المستخدم
        if (userId != null &&
            _loadingInitiated &&
            teacherProvider.profile?.userId != userId) {
          _loadingInitiated = false;
        }

        if (teacherProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل بيانات المعلمة...'),
                  SizedBox(height: 8),
                  Text(
                    'قد يستغرق بعض الوقت',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (teacherProvider.error != null || teacherProvider.profile == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      teacherProvider.error ??
                          'لم يتم العثور على بيانات المعلمة. تأكد من اتصالك بالإنترنت.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _loadingInitiated = false;
                        final userId = context.read<AuthProvider>().currentUser?.id;
                        if (userId != null) {
                          context.read<TeacherProvider>().loadProfile(userId);
                        }
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                    TextButton(
                      onPressed: () => context.read<AuthProvider>().logout(),
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // بمجرد توفر البيانات، نوفر البيانات الفرعية (مثل الإشعارات)
        return MultiProvider(
          providers: [
            DataProviders.notificationsProvider(
                teacherProvider.profile!.userId),
          ],
          child: const _TeacherShell(),
        );
      },
    );
  }
}

class _TeacherShell extends StatefulWidget {
  const _TeacherShell();

  @override
  State<_TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<_TeacherShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TeacherHomeScreen(),
    const NotificationsScreen(),
    const TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'الرئيسية',
                      index: 0,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      icon: Icons.notifications_rounded,
                      label: 'الإشعارات',
                      index: 1,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'الملف',
                      index: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
