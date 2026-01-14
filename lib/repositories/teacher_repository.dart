import 'package:supabase_flutter/supabase_flutter.dart';
// 'postgrest' types are exported by 'supabase_flutter', direct import removed to avoid analyzer warnings.
import '../models/models.dart';

class TeacherRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب جميع المعلمات مع بيانات المستخدم الخاصة بهن
  Future<List<TeacherModel>> getAllTeachers() async {
    try {
      final response = await _client.from('teachers').select('*, users(*)');
      return (response as List)
          .map((json) => TeacherModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      if (msg.contains('row-level') || msg.contains('permission') || msg.contains('rls')) {
        // Try fallback without joining users to show something to the admin
        final fallback = await _client.from('teachers').select();
        return (fallback as List)
            .map((json) => TeacherModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      rethrow;
    }
  }

  /// جلب بيانات معلمة محددة
  Future<TeacherModel?> getTeacherById(String id) async {
    try {
      final response = await _client
          .from('teachers')
          .select('*, users(*)')
          .eq('id', id)
          .maybeSingle();
      return response != null ? TeacherModel.fromJson(response) : null;
    } on PostgrestException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      if (msg.contains('row-level') || msg.contains('permission') || msg.contains('rls')) {
        final fallback = await _client.from('teachers').select().eq('id', id).maybeSingle();
        return fallback != null
            ? TeacherModel.fromJson(Map<String, dynamic>.from(fallback as Map))
            : null;
      }
      rethrow;
    }
  }

  /// جلب بيانات المعلمة عن طريق ID المستخدم
  Future<TeacherModel?> getTeacherByUserId(String userId) async {
    try {
      final response = await _client
          .from('teachers')
          .select('*, users(*)')
          .eq('user_id', userId)
          .maybeSingle();
      return response != null ? TeacherModel.fromJson(response) : null;
    } on PostgrestException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      if (msg.contains('row-level') || msg.contains('permission') || msg.contains('rls')) {
        final fallback = await _client.from('teachers').select().eq('user_id', userId).maybeSingle();
        return fallback != null
            ? TeacherModel.fromJson(Map<String, dynamic>.from(fallback as Map))
            : null;
      }
      rethrow;
    }
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

  /// إنشاء سجل معلمة مع إنشاء سجل المستخدم (إن لم يكن موجوداً)
  Future<TeacherModel> createTeacher({
    required String name,
    required String email,
    String? phone,
    String? specialization,
  }) async {
    try {
      // إنشاء / إدراج المستخدم في جدول users
      final userResp = await _client.from('users').insert({
        'email': email,
        'name': name,
        'phone': phone,
        'role': 'teacher',
      }).select().single();

      final userId = userResp['id'] as String;

      // إنشاء سجل المعلمة المرتبط
      final teacherResp = await _client.from('teachers').insert({
        'user_id': userId,
        'specialization': specialization,
        'is_active': true,
      }).select('*, users(*)').single();

      return TeacherModel.fromJson(teacherResp);
    } on PostgrestException catch (e) {
      final msg = (e.message ?? e.toString()).toLowerCase();
      if (msg.contains('row-level') || msg.contains('permission') || msg.contains('rls')) {
        throw Exception(
            'فشل إنشاء المعلمة بسبب قيود الصلاحيات (RLS).\nلتصحيح المشكلة، نفِّذ ملف `complete_admin_rls_policies.sql` في لوحة تحكم Supabase أو تأكد أن المستخدم الحالي يملك دور admin.');
      }
      rethrow;
    }
  }

  /// حذف المعلمة (اختياري حذف المستخدم أيضاً)
  Future<void> deleteTeacher(String id, {bool deleteUser = false}) async {
    // الحصول على السجل أولاً لمعرفة user_id
    final teacher = await getTeacherById(id);
    if (teacher == null) return;

    await _client.from('teachers').delete().eq('id', id);

    if (deleteUser) {
      await _client.from('users').delete().eq('id', teacher.userId);
    }
  }

  /// الاستماع لتغييرات المعلمات (Real-time)
  /// هذه الطريقة تُعيد قائمة كاملة مُنضّمة من `getAllTeachers()` كلما حدث تغيير
  Stream<List<TeacherModel>> watchTeachers() async* {
    // أولاً، أعِد البيانات الحالية
    yield await getAllTeachers();

    // ثم استمع للتغييرات في جدول teachers وأعد جلب القائمة كاملة عند حدوث أي تغيير
    await for (final _ in _client.from('teachers').stream(primaryKey: ['id'])) {
      try {
        // عند أي حدث، جلب البيانات المحدثة مع بيانات المستخدمين (join)
        final list = await getAllTeachers();
        yield list;
      } catch (_) {
        // في حالة فشل الجلب، تجاهل لتجنّب إيقاف الـ stream
      }
    }
  }

  /// إنشاء سجل معلمة هيكلي (تلقائي)
  Future<void> createTeacherSkeleton(String userId) async {
    await _client.from('teachers').upsert({
      'user_id': userId,
      'is_active': true,
    });
  }
}
