import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class GuardianRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب جميع أولياء الأمور مع بيانات المستخدم الخاصة بهم
  Future<List<GuardianModel>> getAllGuardians() async {
    try {
      final response = await _client.from('guardians').select('*, users(*)');
      return (response as List)
          .map((json) => GuardianModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      if (msg.contains('row-level') ||
          msg.contains('permission') ||
          msg.contains('rls')) {
        // Try fallback without joining users to show something to the admin
        final fallback = await _client.from('guardians').select();
        return (fallback as List)
            .map((json) =>
                GuardianModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      rethrow;
    }
  }

  /// جلب بيانات ولي أمر محدد
  Future<GuardianModel?> getGuardianById(String id) async {
    final response = await _client
        .from('guardians')
        .select('*, users(*)')
        .eq('id', id)
        .maybeSingle();
    return response != null ? GuardianModel.fromJson(response) : null;
  }

  /// جلب بيانات ولي الأمر عن طريق ID المستخدم
  Future<GuardianModel?> getGuardianByUserId(String userId) async {
    final response = await _client
        .from('guardians')
        .select('*, users(*)')
        .eq('user_id', userId)
        .maybeSingle();
    return response != null ? GuardianModel.fromJson(response) : null;
  }

  /// تحديث بيانات ولي الأمر
  Future<GuardianModel> updateGuardian(
      String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('guardians')
        .update(data)
        .eq('id', id)
        .select('*, users(*)')
        .single();
    return GuardianModel.fromJson(response);
  }

  /// إنشاء سجل ولي أمر مع إنشاء سجل المستخدم (إن لم يكن موجوداً)
  Future<GuardianModel> createGuardian({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? emergencyPhone,
    String relationship = 'أم',
  }) async {
    try {
      // إنشاء / إدراج المستخدم في جدول users
      final userResp = await _client
          .from('users')
          .insert({
            'email': email,
            'name': name,
            'phone': phone,
            'role': 'guardian',
          })
          .select()
          .single();

      final userId = userResp['id'] as String;

      // إنشاء سجل ولي الأمر المرتبط
      final guardianResp = await _client
          .from('guardians')
          .insert({
            'user_id': userId,
            'address': address,
            'emergency_phone': emergencyPhone,
            'relationship': relationship,
          })
          .select('*, users(*)')
          .single();

      return GuardianModel.fromJson(guardianResp);
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('row-level') ||
          msg.contains('permission') ||
          msg.contains('rls')) {
        throw Exception(
            'فشل إنشاء ولي الأمر بسبب قيود الصلاحيات (RLS).\nلتصحيح المشكلة، نفِّذ ملف `complete_admin_rls_policies.sql` في لوحة تحكم Supabase أو تأكد أن المستخدم الحالي يملك دور admin.');
      }
      rethrow;
    }
  }

  /// حذف ولي الأمر (اختياري حذف المستخدم أيضاً)
  Future<void> deleteGuardian(String id, {bool deleteUser = false}) async {
    // الحصول على السجل أولاً لمعرفة user_id
    final guardian = await getGuardianById(id);
    if (guardian == null) return;

    await _client.from('guardians').delete().eq('id', id);

    if (deleteUser) {
      await _client.from('users').delete().eq('id', guardian.userId);
    }
  }

  /// إنشاء سجل ولي أمر هيكلي (تلقائي)
  Future<void> createGuardianSkeleton(String userId) async {
    await _client.from('guardians').upsert({
      'user_id': userId,
      'relationship': 'أم',
    });
  }
}
