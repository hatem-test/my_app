import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final padding = size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('المساعدة والدعم'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            _buildContactSupportCard(isSmallScreen),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.help_outline_rounded,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'الأسئلة الشائعة',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              'كيف يمكنني تغيير كلمة المرور؟',
              'يمكنك تغيير كلمة المرور من خلال الذهاب إلى صفحة الملف الشخصي واختيار "تغيير كلمة المرور".',
            ),
            _buildFAQItem(
              'كيف أقوم بإضافة تقرير يومي؟',
              'اذهب إلى القائمة الرئيسية، اختر الطفل، ثم اضغط على "إضافة تقرير" وقم بتعبئة البيانات المطلوبة.',
            ),
            _buildFAQItem(
              'هل يمكنني تعديل البيانات الشخصية؟',
              'نعم، يمكنك تعديل بياناتك الشخصية مثل الاسم ورقم الهاتف من صفحة "تعديل المعلومات الشخصية".',
            ),
            _buildFAQItem(
              'التطبيق لا يرسل إشعارات، ماذا أفعل؟',
              'تأكد من تفعيل الإشعارات من صفحة "إعدادات الإشعارات" وأيضاً من إعدادات الهاتف الخاصة بالتطبيق.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupportCard(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded,
              size: 50, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'هل تحتاج إلى مساعدة إضافية؟',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'فريق الدعم الفني جاهز لمساعدتك على مدار الساعة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(
                icon: Icons.phone,
                label: 'اتصل بنا',
                onTap: () => _launchUrl('tel:+963912345678'),
              ),
              _buildContactButton(
                icon: Icons.email,
                label: 'راسنا',
                onTap: () => _launchUrl('mailto:support@kindergarten.com'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }
}
