import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../models/models.dart';

class MotherHomeScreen extends StatelessWidget {
  const MotherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiProvider(
      providers: [
        DataProviders.guardianProfileProvider(userId),
        ProxyProvider<GuardianModel?, String?>(
          update: (_, profile, __) => profile?.id,
        ),
      ],
      child: Consumer<String?>(
        builder: (context, guardianId, _) {
          if (guardianId == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('أطفالي')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return MultiProvider(
            providers: [
              DataProviders.guardianChildrenProvider(guardianId),
            ],
            child: const _MotherHomeView(),
          );
        },
      ),
    );
  }
}

class _MotherHomeView extends StatelessWidget {
  const _MotherHomeView();

  @override
  Widget build(BuildContext context) {
    final children = context.watch<List<ChildModel>>();
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('أطفالي'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.language, size: width * 0.06),
            onPressed: () {
              final provider = context.read<AppProvider>();
              provider.setLocale(
                provider.locale.languageCode == 'ar'
                    ? const Locale('en')
                    : const Locale('ar'),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.brightness_medium, size: width * 0.06),
            onPressed: () {
              context.read<AppProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // التحديث يتم تلقائياً عبر Stream، ولكن يمكن إضافة منطق إعادة تحميل يدوي هنا إذا لزم الأمر
        },
        child: children.isEmpty
            ? Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(width * 0.08),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.child_care,
                            size: width * 0.2, color: AppColors.textDisabled),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'لا يوجد أطفال مسجلين حالياً',
                        style: GoogleFonts.cairo(
                          color: AppColors.textPrimary,
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ابدئي بإضافة أطفالك لتتمكني من متابعتهم',
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontSize: width * 0.038,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: width * 0.04,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  return _buildChildCard(
                    context,
                    child.name,
                    child.ageText,
                    child.imageUrl ?? child.defaultImagePath,
                    child.gender == Gender.boy ? AppColors.boy : AppColors.girl,
                    child.id,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-child'),
        label: Text('إضافة طفل',
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, fontSize: width * 0.04)),
        icon: Icon(Icons.add, size: width * 0.06),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, String name, String age,
      String imagePath, Color color, String childId) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Card(
      margin: EdgeInsets.only(bottom: width * 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/child/$childId'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.03, vertical: width * 0.025),
          child: Row(
            children: [
              Container(
                width: width * 0.16,
                height: width * 0.16,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.2), width: 2),
                ),
                child: ClipOval(
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: width * 0.08,
                            color: color,
                          ),
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.045,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      age,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: width * 0.035,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // يمكن جلب حالة الحضور الحقيقية هنا لاحقاً
                  const _StatusChip(label: 'حضور', color: AppColors.success),
                  const SizedBox(height: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.textDisabled, size: width * 0.04),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.03, vertical: width * 0.01),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: width * 0.03,
        ),
      ),
    );
  }
}
