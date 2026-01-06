import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    // Mock notifications data
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'تقرير جديد',
        'message': 'تم إرسال تقرير يومي جديد لولي أمر أحمد',
        'time': 'منذ 5 دقائق',
        'isRead': false,
        'icon': Icons.description_rounded,
      },
      {
        'title': 'رسالة من الإدارة',
        'message': 'اجتماع المعلمين غداً الساعة 10 صباحاً',
        'time': 'منذ ساعة',
        'isRead': false,
        'icon': Icons.message_rounded,
      },
      {
        'title': 'تحديث النظام',
        'message': 'تم تحديث النظام بنجاح',
        'time': 'منذ يوم',
        'isRead': true,
        'icon': Icons.system_update_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'قراءة الكل',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(isSmallScreen)
          : ListView.builder(
              padding: EdgeInsets.all(padding),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(
                    notifications[index], isSmallScreen);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: isSmallScreen ? 50 : 64,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 18 : 24),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الإشعارات الجديدة هنا',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: notification['isRead']
            ? Colors.white
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: notification['isRead']
            ? null
            : Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: notification['isRead']
                    ? AppColors.backgroundSecondary
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification['icon'],
                color: notification['isRead']
                    ? AppColors.textSecondary
                    : AppColors.primary,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: notification['isRead']
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification['time'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification['isRead'])
              Container(
                width: isSmallScreen ? 8 : 10,
                height: isSmallScreen ? 8 : 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
