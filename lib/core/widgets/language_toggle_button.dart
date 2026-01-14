import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_colors.dart';

class LanguageToggleButton extends StatelessWidget {
  final Color? color;
  const LanguageToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isArabic = appProvider.locale.languageCode == 'ar';

    return IconButton(
      onPressed: () {
        appProvider
            .setLocale(isArabic ? const Locale('en') : const Locale('ar'));
      },
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: color ?? AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isArabic ? 'EN' : 'عربي',
          style: TextStyle(
            color: color ?? AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      tooltip: isArabic ? 'Switch to English' : 'تغيير للعربية',
    );
  }
}
