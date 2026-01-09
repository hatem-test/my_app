import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_provider.dart';

class MotherHomeScreen extends StatelessWidget {
  const MotherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('أطفالي'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.language, size: width * 0.06), // Responsive icon
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
      body: ListView(
        padding: EdgeInsets.all(width * 0.04),
        children: [
          _buildChildCard(context, 'أحمد محمد', '4 سنوات',
              'assets/images/boy.png', AppColors.boy),
          _buildChildCard(context, 'سارة محمد', '3 سنوات',
              'assets/images/girl.png', AppColors.girl),
          SizedBox(height: height * 0.1), // Fab space
        ],
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
      String imagePath, Color color) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Card(
      margin: EdgeInsets.only(bottom: width * 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/child/123'), // Mock ID
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
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: width * 0.08,
                      color: color,
                    ),
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
                    SizedBox(height: 4),
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
                  _StatusChip(label: 'حضور', color: AppColors.success),
                  SizedBox(height: 4),
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
        color: color.withValues(alpha: 0.1),
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
