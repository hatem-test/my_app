import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    final notifications = context.watch<List<NotificationModel>>();

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
          : ListView.separated(
              padding: EdgeInsets.all(padding),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
      NotificationModel notification, bool isSmallScreen) {
    IconData icon;
    switch (notification.notificationType) {
      case NotificationType.report:
        icon = Icons.description_rounded;
        break;
      case NotificationType.message:
        icon = Icons.message_rounded;
        break;
      case NotificationType.attendance:
        icon = Icons.event_available_rounded;
        break;
      case NotificationType.system:
        icon = Icons.system_update_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: notification.isRead
            ? null
            : Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
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
                color: notification.isRead
                    ? AppColors.backgroundSecondary
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: notification.isRead
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
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.timestampText,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
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
