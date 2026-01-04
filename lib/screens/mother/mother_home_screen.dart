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
          _buildChildCard(
              context, 'أحمد محمد', '4 سنوات', 'assets/boy_1.png', Colors.blue),
          _buildChildCard(context, 'سارة محمد', '3 سنوات', 'assets/girl_1.png',
              Colors.pink),
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
      String image, Color color) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Card(
      margin: EdgeInsets.only(bottom: width * 0.04),
      child: InkWell(
        onTap: () => context.push('/child/123'), // Mock ID
        borderRadius: BorderRadius.circular(width * 0.04),
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            children: [
              Container(
                width: width * 0.2,
                height: width * 0.2,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(width * 0.03),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(Icons.face, size: width * 0.12, color: color),
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: width * 0.055,
                              ),
                    ),
                    SizedBox(height: width * 0.01),
                    Text(
                      age,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: width * 0.04,
                          ),
                    ),
                    SizedBox(height: width * 0.02),
                    Row(
                      children: [
                        _StatusChip(label: 'ممتاز', color: AppColors.success),
                        SizedBox(width: width * 0.02),
                        _StatusChip(label: 'حضور', color: AppColors.primary),
                      ],
                    )
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: AppColors.textDisabled, size: width * 0.04),
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
