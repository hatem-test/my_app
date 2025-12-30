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
    return Scaffold(
      appBar: AppBar(
        title: const Text('أطفالي'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
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
            icon: const Icon(Icons.brightness_medium),
            onPressed: () {
              context.read<AppProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChildCard(
              context, 'أحمد محمد', '4 سنوات', 'assets/boy_1.png', Colors.blue),
          _buildChildCard(context, 'سارة محمد', '3 سنوات', 'assets/girl_1.png',
              Colors.pink),
          const SizedBox(height: 80), // Fab space
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-child'),
        label: Text('إضافة طفل',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, String name, String age,
      String image, Color color) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/child/123'), // Mock ID
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(Icons.face, size: 48, color: color),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      age,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        _StatusChip(label: 'ممتاز', color: AppColors.success),
                        SizedBox(width: 8),
                        _StatusChip(label: 'حضور', color: AppColors.primary),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: AppColors.textDisabled, size: 16),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
