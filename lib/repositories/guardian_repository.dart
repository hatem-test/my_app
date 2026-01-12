import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class GuardianRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب جميع أولياء الأمور مع بيانات المستخدم الخاصة بهم
  Future<List<GuardianModel>> getAllGuardians() async {
    final response = await _client.from('guardians').select('*, users(*)');
    return (response as List)
        .map((json) => GuardianModel.fromJson(json))
        .toList();
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

  /// إنشاء سجل ولي أمر هيكلي (تلقائي)
  Future<void> createGuardianSkeleton(String userId) async {
    await _client.from('guardians').upsert({
      'user_id': userId,
      'relationship': 'أم',
    });
  }
}
