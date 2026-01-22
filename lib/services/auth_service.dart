import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';
import '../repositories/guardian_repository.dart';
import '../repositories/teacher_repository.dart';

/// خدمة المصادقة
/// تتولى منطق الأعمال الخاص بالمصادقة (مثل التحقق من صحة البيانات ومعالجة الأخطاء)
class AuthService {
  final AuthRepository _repository;
  final GuardianRepository _guardianRepository;
  final TeacherRepository _teacherRepository;

  AuthService(
    this._repository,
    this._guardianRepository,
    this._teacherRepository,
  );

  /// تسجيل الدخول
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _repository.signIn(email, password);
      if (response.user != null) {
        UserModel? user = await _repository.getUserProfile(response.user!.id);

        // إذا كان السجل مفقوداً، نقوم بمزامنته
        user ??= await _syncProfileIfMissing(response.user!);

        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// إنشاء حساب جديد مع الدور والاسم
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
        name: name,
        role: role.name,
      );
      if (response.user != null) {
        final newUser = UserModel(
          id: response.user!.id,
          email: email,
          name: name,
          role: role,
          phone: phone,
          createdAt: DateTime.now(),
        );

        // إنشاء ملف المستخدم في قاعدة البيانات
        try {
          await _repository.createUserProfile(newUser);
        } catch (e) {
          // إذا فشل إنشاء البروفايل (مثلاً بسبب RLS أو تعارض)، لا نوقف العملية
          // لأن المستخدم تم إنشاؤه بالفعل في Auth ويحتاج للتحقق
          debugPrint('Warning: Could not create user profile yet: $e');
        }
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _repository.signOut();
  }

  /// التحقق من البريد الإلكتروني باستخدام الكود
  Future<UserModel?> verifyEmail(String email, String token) async {
    try {
      final response = await _repository.verifyOTP(email: email, token: token);
      if (response.user != null) {
        UserModel? user = await _repository.getUserProfile(response.user!.id);

        // مزامنة الملف إذا كان مفقوداً بعد التحقق
        user ??= await _syncProfileIfMissing(response.user!);

        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// إعادة إرسال كود التحقق
  Future<void> resendVerificationCode(String email) async {
    try {
      await _repository.resendOTP(email);
    } catch (e) {
      rethrow;
    }
  }

  /// جلب بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    final user = _repository.currentUser;
    if (user != null) {
      UserModel? profile = await _repository.getUserProfile(user.id);

      // مزامنة تلقائية إذا كان المسار مقطوعاً
      profile ??= await _syncProfileIfMissing(user);

      return profile;
    }
    return null;
  }

  /// تحديث الملف الشخصي
  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    final user = _repository.currentUser;
    if (user != null) {
      await _repository.updateUserProfile(user.id, {
        'name': name,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      });
      // أيضا نحدث بيانات التعريف
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'name': name}),
      );
    }
  }

  /// تغيير كلمة المرور
  Future<void> changePassword(String newPassword) async {
    await _repository.updatePassword(newPassword);
  }

  /// مزامنة الملف المفقود من بيانات تعريف Auth
  Future<UserModel> _syncProfileIfMissing(User authUser) async {
    final metadata = authUser.userMetadata ?? {};
    final roleStr = metadata['role'] as String? ?? 'mother';

    final newUser = UserModel(
      id: authUser.id,
      email: authUser.email ?? '',
      name: metadata['name'] ?? 'مستخدم',
      role: UserRole.values.firstWhere(
        (e) => e.name == roleStr,
        orElse: () => UserRole.mother,
      ),
      phone: authUser.phone,
      isVerified: authUser.emailConfirmedAt != null,
      createdAt: DateTime.now(),
    );

    // 1. إعادة إنشاء سجل المستخدم فقط
    // تم تخطي إنشاء سجلات role skeleton أثناء تسجيل الدخول لتجنب التأخير والصراعات مع RLS
    try {
      await _repository.createUserProfile(newUser);
    } catch (e) {
      debugPrint('Error syncing user profile: $e');
      // لا نوقف العملية لأن ملف Auth موجود بالفعل
    }

    return newUser;
  }
}
