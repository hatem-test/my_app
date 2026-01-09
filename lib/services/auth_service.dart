import '../models/models.dart';
import '../repositories/auth_repository.dart';

/// خدمة المصادقة
/// تتولى منطق الأعمال الخاص بالمصادقة (مثل التحقق من صحة البيانات ومعالجة الأخطاء)
class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  /// تسجيل الدخول
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _repository.signIn(email, password);
      if (response.user != null) {
        return await _repository.getUserProfile(response.user!.id);
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
        await _repository.createUserProfile(newUser);
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

  /// جلب بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    final user = _repository.currentUser;
    if (user != null) {
      return await _repository.getUserProfile(user.id);
    }
    return null;
  }
}
