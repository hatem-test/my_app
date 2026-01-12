import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class HealthRecordRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب جميع السجلات الصحية لطفل محدد
  Future<List<HealthRecordModel>> getHealthRecordsByChild(
      String childId) async {
    final response = await _client
        .from('health_records')
        .select()
        .eq('child_id', childId)
        .order('record_date', ascending: false);
    return (response as List)
        .map((json) => HealthRecordModel.fromJson(json))
        .toList();
  }

  /// إضافة سجل صحي جديد
  Future<HealthRecordModel> createHealthRecord(HealthRecordModel record) async {
    final response = await _client
        .from('health_records')
        .insert(record.toInsertJson())
        .select()
        .single();
    return HealthRecordModel.fromJson(response);
  }

  /// تحديث سجل صحي
  Future<HealthRecordModel> updateHealthRecord(
      String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('health_records')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return HealthRecordModel.fromJson(response);
  }

  /// حذف سجل صحي
  Future<void> deleteHealthRecord(String id) async {
    await _client.from('health_records').delete().eq('id', id);
  }

  /// الاستماع لتغييرات السجلات الصحية لطفل (Real-time)
  Stream<List<HealthRecordModel>> watchHealthRecords(String childId) {
    return _client
        .from('health_records')
        .stream(primaryKey: ['id'])
        .eq('child_id', childId)
        .order('record_date', ascending: false)
        .map((data) =>
            data.map((json) => HealthRecordModel.fromJson(json)).toList());
  }
}
