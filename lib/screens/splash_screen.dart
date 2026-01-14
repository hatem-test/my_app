import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart'; // تأكد من إضافة المكتبة في pubspec.yaml
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = "v2.0.1";

  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  // دالة واحدة لجلب الإصدار والانتظار ثم التنقل
  _loadDataAndNavigate() async {
    // 1. جلب معلومات الإصدار
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      debugPrint("Error loading package info: $e");
    }

    // 2. الانتظار لمدة ثانيتين (كما في كودك الأصلي)
    await Future.delayed(const Duration(seconds: 2));

    // 3. التنقل إلى الصفحة الرئيسية
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        // استخدمنا Stack لوضع الإصدار فوق الصورة في الأسفل
        children: [
          // الصورة في المنتصف
          Center(
            child: Image.asset(
              "assets/images/splash.png",
              width: width * 0.6,
              height: height * 0.6,
            ),
          ),

          // رقم الإصدار في الأسفل
          Positioned(
            bottom: 40, // المسافة من أسفل الشاشة
            left: 0,
            right: 0,
            child: Text(
              "Version $_version",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 40, 40, 40),
                fontSize: 13, // خط صغير
                fontWeight: FontWeight.w400,
                fontFamily: 'sans-serif', // أو أي خط تفضله
              ),
            ),
          ),
        ],
      ),
    );
  }
}
