import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// مستودع المصادقة
/// يتولى التفاعل المباشر مع Supabase Auth وجدول المستخدمين
class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// الحصول على المستخدم الحالي من Supabase Auth
  User? get currentUser => _client.auth.currentUser;

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// إنشاء حساب جديد مع تخزين الاسم والدور في بيانات التعريف
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
      },
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// التحقق من كود الـ OTP المرسل للبريد
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  /// إعادة إرسال كود التحقق
  Future<void> resendOTP(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  /// جلب بيانات الملف الشخصي من جدول users مع نسخة احتياطية من بيانات التعريف
  Future<UserModel?> getUserProfile(String userId) async {
    UserModel? user;
    try {
      // محاولة جلب البيانات من الجدول
      final response =
          await _client.from('users').select().eq('id', userId).maybeSingle();
      if (response != null) {
        user = UserModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching user profile from table: $e');
    }

    // التحقق من المستخدم الحالي لضبط حالة التحقق من البريد
    final authUser = _client.auth.currentUser;
    if (authUser != null && authUser.id == userId) {
      if (user != null) {
        user = user.copyWith(isVerified: authUser.emailConfirmedAt != null);
      }
    }

    return user;
  }

  /// تحليل الدور من النص (نفس المنطق الموجود في UserModel)
  UserRole _parseRole(dynamic role) {
    if (role is String) {
      return UserRole.values.firstWhere(
        (e) => e.name == role,
        orElse: () => UserRole.mother,
      );
    }
    return UserRole.mother;
  }

  /// إنشاء أو تحديث ملف المستخدم في جدول users
  Future<void> createUserProfile(UserModel user) async {
    await _client.from('users').upsert(user.toJson());
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', userId);
  }
}
