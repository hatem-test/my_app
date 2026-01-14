import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/models.dart';
// Optional if needed
import '../../repositories/children_repository.dart';
import '../../repositories/dashboard_repository.dart';
import '../../models/activity_item.dart';
import '../../repositories/guardian_repository.dart';
import '../../repositories/teacher_repository.dart';
import 'dashboard/widgets/children_gender_pie_chart.dart';
import 'dashboard/widgets/dashboard_stat_card.dart';
import 'dashboard/widgets/user_distribution_bar_chart.dart';
import 'widgets/admin_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _childrenCount = 0;
  int _teachersCount = 0;
  int _guardiansCount = 0;
  int _boysCount = 0;
  int _girlsCount = 0;
  List<ActivityItem> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final childrenRepo = context.read<ChildrenRepository>();
      final teacherRepo = context.read<TeacherRepository>();
      final guardianRepo = context.read<GuardianRepository>();
      final dashboardRepo = context.read<DashboardRepository>();

      print('DEBUG: Starting fetch Children...');
      final children = await childrenRepo.getAllChildren();
      print('DEBUG: Children fetched: ${children.length}');

      print('DEBUG: Starting fetch Teachers...');
      final teachers = await teacherRepo.getAllTeachers();
      print('DEBUG: Teachers fetched: ${teachers.length}');

      print('DEBUG: Starting fetch Guardians...');
      final guardians = await guardianRepo.getAllGuardians();
      print('DEBUG: Guardians fetched: ${guardians.length}');

      print('DEBUG: Starting fetch Recent Activities...');
      final recentActivities = await dashboardRepo.getRecentActivities();
      print('DEBUG: Activities fetched: ${recentActivities.length}');

      int boys = 0;
      int girls = 0;

      for (var child in children) {
        if (child.gender == Gender.boy) {
          boys++;
        } else {
          girls++;
        }
      }

      if (mounted) {
        setState(() {
          _childrenCount = children.length;
          _teachersCount = teachers.length;
          _guardiansCount = guardians.length;
          _boysCount = boys;
          _girlsCount = girls;
          _recentActivities = recentActivities;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Error loading stats: $e');
      debugPrint(stack.toString());
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الأدمن'),
        centerTitle: true,
      ),
      drawer: const AdminDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadAllStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
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
              const SizedBox(height: 8),
              const Text(
                'إليك نظرة عامة على إحصائيات الحضانة',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive Grid
                  int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

                  double spacing = 16.0;
                  double availableWidth =
                      constraints.maxWidth - ((crossAxisCount - 1) * spacing);
                  double itemWidth = availableWidth / crossAxisCount;
                  double desiredHeight =
                      110.0; // Fixed height to ensure no overflow

                  double childAspectRatio = itemWidth / desiredHeight;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                    children: [
                      DashboardStatCard(
                        title: 'عدد الأطفال',
                        value: _childrenCount.toString(),
                        icon: Icons.child_care,
                        color: AppColors.primary,
                        onTap: () => context.go('/admin/children'),
                      ),
                      DashboardStatCard(
                        title: 'عدد المعلمات',
                        value: _teachersCount.toString(),
                        icon: Icons.person_outline,
                        color: AppColors.secondary,
                        onTap: () => context.go('/admin/teachers'),
                      ),
                      DashboardStatCard(
                        title: 'أولياء الأمور',
                        value: _guardiansCount.toString(),
                        icon: Icons.face_3,
                        color: AppColors.accent,
                        onTap: () => context.go('/admin/guardians'),
                      ),
                      DashboardStatCard(
                        title: 'التقارير اليوم',
                        value: '0', // Placeholder
                        icon: Icons.article_outlined,
                        color: AppColors.error,
                        onTap: () => context.go('/admin/reports'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Charts Section
              if (_isLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              else
                Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 900) {
                          // Row layout for large screens
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: UserDistributionBarChart(
                                  childrenCount: _childrenCount,
                                  teachersCount: _teachersCount,
                                  guardiansCount: _guardiansCount,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: ChildrenGenderPieChart(
                                  boysCount: _boysCount,
                                  girlsCount: _girlsCount,
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Column layout for smaller screens
                          return Column(
                            children: [
                              UserDistributionBarChart(
                                childrenCount: _childrenCount,
                                teachersCount: _teachersCount,
                                guardiansCount: _guardiansCount,
                              ),
                              const SizedBox(height: 16),
                              ChildrenGenderPieChart(
                                boysCount: _boysCount,
                                girlsCount: _girlsCount,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 32),
              const Text(
                'آخر النشاطات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_recentActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'لا توجد نشاطات حديثة',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentActivities.length,
                  itemBuilder: (context, index) {
                    final activity = _recentActivities[index];
                    return _buildActivityItem(activity);
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activity.color.withOpacity(0.1),
          child: Icon(activity.icon, color: activity.color, size: 20),
        ),
        title: Text(activity.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(activity.subtitle, style: const TextStyle(fontSize: 12)),
        onTap: () {
          // Optional: Handle navigation based on activity type
          if (activity.type == ActivityType.newReport) {
            // Navigate to reports if needed
          }
        },
      ),
    );
  }
}
