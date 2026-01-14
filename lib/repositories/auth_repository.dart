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
    Map<String, dynamic>? data;

    try {
      // محاولة جلب البيانات من الجدول
      final response =
          await _client.from('users').select().eq('id', userId).maybeSingle();
      if (response != null) {
        data = Map<String, dynamic>.from(response as Map);
      }
    } catch (e) {
      debugPrint('Error fetching user profile from table: $e');
    }

    // قراءة الدور من Metadata في Auth إذا لم يكن موجوداً في الجدول
    final authUser = _client.auth.currentUser;
    if (authUser != null && authUser.id == userId) {
      final metadata = authUser.userMetadata ?? {};
      final metaRole = metadata['role'] as String?;

      // إذا لم يكن هناك سجل في الجدول أو حقل الدور مفقود، نستخدم دور الـ metadata
      if (data == null) {
        data = {
          'id': authUser.id,
          'email': authUser.email ?? '',
          'name': metadata['name'] ?? 'مستخدم',
          'phone': authUser.phone,
          'role': metaRole ?? 'mother',
          'profile_image_url': null,
          // created_at في Auth يكون عادة نصاً أو DateTime؛ نتركه كما هو
          'created_at': authUser.createdAt,
          'updated_at': null,
        };
      } else {
        data['role'] ??= metaRole ?? 'mother';
      }
    }

    if (data != null) {
      user = UserModel.fromJson(data);

      // ضبط حالة التحقق من البريد بناءً على Auth
      if (authUser != null && authUser.id == userId) {
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

  /// تحديث كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
