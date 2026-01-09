import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';

/// موفر المصادقة
/// يدير حالة المصادقة للتطبيق ويُحدث الواجهات عند التغيير
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _initialize();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تهيئة الحالة عند بدء التطبيق
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إنشاء حساب
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// معالجة الأخطاء وتحويلها لنصوص عربية
  String _handleError(dynamic e) {
    final message = e.toString().toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (message.contains('email already in use')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    } else if (message.contains('network')) {
      return 'خطأ في الاتصال بالإنترنت';
    }
    return 'حدث خطأ ما، يرجى المحاولة مرة أخرى';
  }
}
