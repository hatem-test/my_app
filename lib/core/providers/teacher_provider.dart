import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/teacher_repository.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherRepository _repository;

  TeacherModel? _profile;
  bool _isLoading = false;
  String? _error;

  TeacherProvider(this._repository);

  TeacherModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String userId) async {
    // إذا تم تحميل نفس الحساب بالفعل، لا داعي لإعادة التحميل
    if (_profile?.userId == userId && !_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.getTeacherByUserId(userId);
      if (_profile == null) {
        _error = 'لم يتم العثور على ملف المعلمة';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل البيانات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
