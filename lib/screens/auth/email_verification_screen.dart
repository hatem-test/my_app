import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _timerSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _otpCode => _otpController.text.trim();

  Future<void> _verify() async {
    if (_otpCode.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final email = widget.email.isNotEmpty
        ? widget.email
        : authProvider.currentUser?.email ?? '';

    final success = await authProvider.verifyEmail(email, _otpCode);

    if (success) {
      if (mounted) {
        // سيتم تحويل المستخدم تلقائياً عبر GoRouter لأن الحالة تغيرت
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التحقق بنجاح')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(authProvider.errorMessage ?? 'كود التحقق غير صحيح')),
        );
      }
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;

    final authProvider = context.read<AuthProvider>();
    final email = widget.email.isNotEmpty
        ? widget.email
        : authProvider.currentUser?.email ?? '';

    final success = await authProvider.resendVerificationCode(email);

    if (success) {
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة إرسال الكود')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تحقق من البريد'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.08),
          child: Column(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'أدخل رمز التحقق',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'لقد أرسلنا رمز التحقق إلى\n${widget.email.isNotEmpty ? widget.email : context.read<AuthProvider>().currentUser?.email ?? ""}',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Dynamic OTP Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TextField(
                  controller: _otpController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: '------',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (_) => _verify(),
                ),
              ),

              const SizedBox(height: 40),

              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'تحقق الآن',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Resend Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _canResend
                        ? 'لم يصلك الكود؟ '
                        : 'يمكنك إعادة الإرسال خلال ',
                    style: GoogleFonts.cairo(color: AppColors.textSecondary),
                  ),
                  if (_canResend)
                    TextButton(
                      onPressed: _resend,
                      child: Text(
                        'إعادة إرسال',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      '$_timerSeconds ثانية',
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
