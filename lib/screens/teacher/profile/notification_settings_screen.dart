import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _newMessages = true;
  bool _schoolAnnouncements = true;
  bool _childArrival = true;
  bool _childDepature = true;
  bool _appUpdates = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final padding = size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            _buildSectionHeader('التنبيهات الأساسية', isSmallScreen),
            _buildSwitchTile(
              title: 'الرسائل الجديدة',
              subtitle: 'استلام إشعار عند وصول رسالة جديدة من الأهل',
              value: _newMessages,
              onChanged: (val) => setState(() => _newMessages = val),
              icon: Icons.message_outlined,
            ),
            _buildSwitchTile(
              title: 'إعلانات الروضة',
              subtitle: 'استلام إشعار عند وجود إعلان هام من الإدارة',
              value: _schoolAnnouncements,
              onChanged: (val) => setState(() => _schoolAnnouncements = val),
              icon: Icons.campaign_outlined,
            ),
            const Divider(height: 32),
            _buildSectionHeader('تتبع الأطفال', isSmallScreen),
            _buildSwitchTile(
              title: 'وصول الطفل',
              subtitle: 'تنبيه عند تسجيل وصول طفل للفصل',
              value: _childArrival,
              onChanged: (val) => setState(() => _childArrival = val),
              icon: Icons.login_rounded,
            ),
            _buildSwitchTile(
              title: 'مغادرة الطفل',
              subtitle: 'تنبيه عند تسجيل مغادرة طفل للفصل',
              value: _childDepature,
              onChanged: (val) => setState(() => _childDepature = val),
              icon: Icons.logout_rounded,
            ),
            const Divider(height: 32),
            _buildSectionHeader('أخرى', isSmallScreen),
            _buildSwitchTile(
              title: 'تحديثات التطبيق',
              subtitle: 'إشعارات حول الميزات الجديدة والتحسينات',
              value: _appUpdates,
              onChanged: (val) => setState(() => _appUpdates = val),
              icon: Icons.system_update_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Transform.scale(
          scale: 0.7,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }
}
