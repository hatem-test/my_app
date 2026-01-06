import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ContactScreen extends StatelessWidget {
  final String? childId;

  const ContactScreen({super.key, this.childId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    final Map<String, dynamic> contactInfo = {
      'motherName': 'فاطمة أحمد',
      'phone': '+963 912 345 678',
      'email': 'fatima@email.com',
      'relationship': 'الأم',
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('معلومات التواصل'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              _buildContactHeader(contactInfo, isSmallScreen),
              SizedBox(height: isSmallScreen ? 18 : 24),
              _buildContactOption(
                icon: Icons.phone_rounded,
                title: 'الهاتف',
                subtitle: contactInfo['phone'],
                color: AppColors.success,
                isSmallScreen: isSmallScreen,
                onTap: () {},
              ),
              _buildContactOption(
                icon: Icons.email_rounded,
                title: 'البريد الإلكتروني',
                subtitle: contactInfo['email'],
                color: AppColors.primary,
                isSmallScreen: isSmallScreen,
                onTap: () {},
              ),
              _buildContactOption(
                icon: Icons.message_rounded,
                title: 'رسالة نصية',
                subtitle: 'إرسال رسالة SMS',
                color: AppColors.accent,
                isSmallScreen: isSmallScreen,
                onTap: () {},
              ),
              SizedBox(height: isSmallScreen ? 18 : 24),
              _buildInfoCard(contactInfo, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactHeader(Map<String, dynamic> info, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 70 : 90,
            height: isSmallScreen ? 70 : 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Icon(Icons.person_rounded,
                size: isSmallScreen ? 36 : 45, color: AppColors.primary),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(info['motherName'],
              style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(info['relationship'],
                style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 10 : 12,
        ),
        leading: Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
          ),
          child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: AppColors.textSecondary)),
        trailing: Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
          ),
          child: Icon(Icons.arrow_forward_ios_rounded,
              size: isSmallScreen ? 14 : 16, color: color),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> info, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: isSmallScreen ? 18 : 22),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Text('معلومات إضافية',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          const Divider(height: 1),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildInfoRow('العلاقة', info['relationship'], isSmallScreen),
          _buildInfoRow('رقم الطوارئ', info['phone'], isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
