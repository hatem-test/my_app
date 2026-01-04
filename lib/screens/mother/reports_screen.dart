import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير اليومية')),
      body: ListView.builder(
        padding: EdgeInsets.all(width * 0.04),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: width * 0.04),
            child: ListTile(
              contentPadding: EdgeInsets.all(width * 0.03),
              leading: Container(
                padding: EdgeInsets.all(width * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment_outlined,
                    color: AppColors.primary, size: width * 0.06),
              ),
              title: Text(
                'تقرير يوم ${30 - index} ديسمبر',
                style: TextStyle(fontSize: width * 0.04),
              ),
              subtitle: Text(
                'تم الاستلام',
                style: TextStyle(fontSize: width * 0.035),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: width * 0.04),
              onTap: () {
                // Navigate to report details
              },
            ),
          );
        },
      ),
    );
  }
}
