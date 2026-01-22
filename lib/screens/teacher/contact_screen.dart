import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../repositories/children_repository.dart';
import '../../repositories/guardian_repository.dart';

class ContactScreen extends StatefulWidget {
  final String? childId;

  const ContactScreen({super.key, this.childId});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late Future<GuardianModel?> _guardianFuture;
  final ChildrenRepository _childrenRepository = ChildrenRepository();
  final GuardianRepository _guardianRepository = GuardianRepository();

  @override
  void initState() {
    super.initState();
    _guardianFuture = _fetchGuardianInfo();
  }

  Future<GuardianModel?> _fetchGuardianInfo() async {
    if (widget.childId == null) return null;
    try {
      final child = await _childrenRepository.getChildById(widget.childId!);
      if (child != null) {
        return await _guardianRepository.getGuardianById(child.guardianId);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching contact info: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('معلومات التواصل'),
          centerTitle: true,
          elevation: 0,
        ),
        body: FutureBuilder<GuardianModel?>(
          future: _guardianFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('حدث خطأ: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text('لم يتم العثور على معلومات التواصل'),
              );
            }

            final guardian = snapshot.data!;

            // Prepare data for UI
            final contactInfo = {
              'motherName':
                  guardian.name.isNotEmpty ? guardian.name : 'غير متوفر',
              'phone': guardian.phone.isNotEmpty ? guardian.phone : 'غير متوفر',
              'email': guardian.email.isNotEmpty ? guardian.email : 'غير متوفر',
              'relationship': guardian.relationship,
              'address': guardian.address ?? 'غير متوفر',
              'emergencyPhone': guardian.emergencyPhone ?? 'غير متوفر',
            };

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  _buildContactHeader(contactInfo, isSmallScreen),
                  SizedBox(height: isSmallScreen ? 18 : 24),
                  if (guardian.phone.isNotEmpty)
                    _buildContactOption(
                      icon: Icons.phone_rounded,
                      title: 'الهاتف',
                      subtitle: contactInfo['phone'] as String,
                      color: AppColors.success,
                      isSmallScreen: isSmallScreen,
                      onTap: () => _makePhoneCall(guardian.phone),
                    ),
                  if (guardian.email.isNotEmpty)
                    _buildContactOption(
                      icon: Icons.email_rounded,
                      title: 'البريد الإلكتروني',
                      subtitle: contactInfo['email'] as String,
                      color: AppColors.primary,
                      isSmallScreen: isSmallScreen,
                      onTap: () => _sendEmail(guardian.email),
                    ),
                  if (guardian.phone.isNotEmpty)
                    _buildContactOption(
                      icon: Icons.message_rounded,
                      title: 'رسالة نصية',
                      subtitle: 'إرسال رسالة SMS',
                      color: AppColors.accent,
                      isSmallScreen: isSmallScreen,
                      onTap: () => _sendSMS(guardian.phone),
                    ),
                  SizedBox(height: isSmallScreen ? 18 : 24),
                  _buildInfoCard(contactInfo, isSmallScreen),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactHeader(Map<String, dynamic> info, bool isSmallScreen) {
    return Container(
      width: double.infinity,
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
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 60 : 80,
            height: isSmallScreen ? 60 : 80,
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
                size: isSmallScreen ? 34 : 40, color: AppColors.primary),
          ),
          SizedBox(width: isSmallScreen ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info['motherName'],
                    style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(info['relationship'],
                      style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.white)),
                ),
              ],
            ),
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
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))
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
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))
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
          _buildInfoRow('رقم الطوارئ', info['emergencyPhone'],
              isSmallScreen), // Fixed key
          _buildInfoRow('عنوان السكن', info['address'], isSmallScreen),
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
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch $launchUri');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch $launchUri');
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber.replaceAll(' ', ''),
    );
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch $launchUri');
    }
  }
}
