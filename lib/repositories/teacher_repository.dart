import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class TeacherRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب جميع المعلمات مع بيانات المستخدم الخاصة بهن
  Future<List<TeacherModel>> getAllTeachers() async {
    final response = await _client.from('teachers').select('*, users(*)');
    return (response as List)
        .map((json) => TeacherModel.fromJson(json))
        .toList();
  }

  /// جلب بيانات معلمة محددة
  Future<TeacherModel?> getTeacherById(String id) async {
    final response = await _client
        .from('teachers')
        .select('*, users(*)')
        .eq('id', id)
        .maybeSingle();
    return response != null ? TeacherModel.fromJson(response) : null;
  }

  /// جلب بيانات المعلمة عن طريق ID المستخدم
  Future<TeacherModel?> getTeacherByUserId(String userId) async {
    final response = await _client
        .from('teachers')
        .select('*, users(*)')
        .eq('user_id', userId)
        .maybeSingle();
    return response != null ? TeacherModel.fromJson(response) : null;
  }

  /// تحديث بيانات المعلمة
  Future<TeacherModel> updateTeacher(
      String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('teachers')
        .update(data)
        .eq('id', id)
        .select('*, users(*)')
        .single();
    return TeacherModel.fromJson(response);
  }

  /// إنشاء سجل معلمة هيكلي (تلقائي)
  Future<void> createTeacherSkeleton(String userId) async {
    await _client.from('teachers').upsert({
      'user_id': userId,
      'is_active': true,
    });
  }
}
