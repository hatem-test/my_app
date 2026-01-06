import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.06), // 6% of screen width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'مرحباً بك',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: width * 0.08, // Responsive font size
                      ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'يرجى اختيار نوع الحساب للمتابعة',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: width * 0.045,
                      ),
                ),
                SizedBox(height: height * 0.045),
                _RoleCard(
                  label: 'أم',
                  color: AppColors.primary,
                  onTap: () => context.push('/login?role=mother'),
                ),
                SizedBox(height: height * 0.015),
                _RoleCard(
                  label: 'معلمة',
                  color: AppColors.secondary,
                  onTap: () => context.push('/login?role=teacher'),
                ),
                SizedBox(height: height * 0.015),
                _RoleCard(
                  label: 'مدير',
                  color: AppColors.accent,
                  onTap: () => context.push('/login?role=admin'),
                ),
                SizedBox(height: height * 0.05),
                Center(
                  child: Image.asset(
                    'assets/images/role_selection_img.png',
                    width: width * 0.8,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(width * 0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.03,
            horizontal: width * 0.04,
          ),
          child: Row(
            children: [
              // Icon removed
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: width * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
