import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/constants/app_colors.dart';
import '../../../../models/models.dart';
import '../../../../repositories/report_repository.dart';
import '../widgets/admin_drawer.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AdminDrawer(),
        appBar: AppBar(
          title: const Text('سجل التقارير'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'تقارير اليوم'),
              Tab(text: 'كل التقارير'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            _ReportsList(isToday: true),
            _ReportsList(isToday: false),
          ],
        ),
      ),
    );
  }
}

class _ReportsList extends StatefulWidget {
  final bool isToday;

  const _ReportsList({required this.isToday});

  @override
  State<_ReportsList> createState() => _ReportsListState();
}

class _ReportsListState extends State<_ReportsList> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  void _refreshReports() {
    setState(() {
      final date = widget.isToday ? DateTime.now() : null;
      _reportsFuture =
          context.read<ReportRepository>().getAllReports(date: date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('حدث خطأ: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshReports,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.article_outlined,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(widget.isToday
                    ? 'لا توجد تقارير لليوم'
                    : 'لا توجد تقارير مسجلة'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshReports,
                  child: const Text('تحديث'),
                ),
              ],
            ),
          );
        }

        final reports = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _refreshReports(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index];
              return _ReportCard(data: data);
            },
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ReportCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final report = ReportModel.fromJson(data);
    final childName =
        data['children'] != null ? data['children']['name'] : 'طفل غير معروف';
    final teacherData = data['teachers'];
    final teacherName = (teacherData != null && teacherData['users'] != null)
        ? teacherData['users']['name']
        : 'معلمة غير معروفة';

    // Formatting Date
    final dateFormat = intl.DateFormat('yyyy/MM/dd', 'ar');
    final dateString = dateFormat.format(report.reportDate);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/admin/reports/detail', extra: data);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    childName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'بواسطة: $teacherName',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      label: 'الصحة',
                      value: report.healthStatus,
                      icon: Icons.health_and_safety,
                      color: Colors.red.shade100,
                      iconColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      label: 'المزاج',
                      value: report.behavior,
                      icon: Icons.mood,
                      color: Colors.orange.shade100,
                      iconColor: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (report.additionalNotes != null &&
                  report.additionalNotes!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.additionalNotes!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
