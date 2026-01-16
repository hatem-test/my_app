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
      icon: Icon(
        Icons.language,
        color: color ?? AppColors.primary,
        size: 20,
      ),
      tooltip: isArabic ? 'Switch to English' : 'تغيير للعربية',
    );
  }
}
