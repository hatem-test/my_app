import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ChildrenRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب جميع الأطفال
  Future<List<ChildModel>> getAllChildren() async {
    print('DEBUG: ChildrenRepository.getAllChildren - Fetching all...');
    final response = await _client.from('children').select();
    print(
        'DEBUG: ChildrenRepository.getAllChildren - Found: ${response.length}');
    return (response as List).map((json) => ChildModel.fromJson(json)).toList();
  }

  /// جلب أطفال ولي أمر معين
  Future<List<ChildModel>> getChildrenByGuardian(String guardianId) async {
    final response =
        await _client.from('children').select().eq('guardian_id', guardianId);
    return (response as List).map((json) => ChildModel.fromJson(json)).toList();
  }

  /// جلب أطفال فصل معين أو معلم معين
  Future<List<ChildModel>> getChildrenByTeacher(String teacherId) async {
    final response =
        await _client.from('children').select().eq('teacher_id', teacherId);
    return (response as List).map((json) => ChildModel.fromJson(json)).toList();
  }

  /// جلب بيانات طفل محدد
  Future<ChildModel?> getChildById(String id) async {
    try {
      final response =
          await _client.from('children').select().eq('id', id).maybeSingle();
      return response != null ? ChildModel.fromJson(response) : null;
    } catch (e) {
      debugPrint('Error fetching child by id: $e');
      rethrow;
    }
  }

  /// إضافة طفل جديد
  Future<ChildModel> createChild(ChildModel child) async {
    final response = await _client
        .from('children')
        .insert(child.toInsertJson())
        .select()
        .single();
    return ChildModel.fromJson(response);
  }

  /// تحديث بيانات طفل
  Future<ChildModel> updateChild(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('children')
          .update(data)
          .eq('id', id)
          .select()
          .maybeSingle();

      if (response == null) {
        throw 'فشل تحديث البيانات. قد لا تملك الصلاحيات الكافية (RLS) أو السجل غير موجود.';
      }

      return ChildModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw 'فشل تحديث البيانات: لا يوجد سجل مطابق أو لا توجد صلاحيات تحديث (RLS Policy).';
      }
      rethrow;
    } catch (e) {
      debugPrint('Error updating child: $e');
      rethrow;
    }
  }

  /// حذف طفل
  Future<void> deleteChild(String id) async {
    await _client.from('children').delete().eq('id', id);
  }

  /// رفع صورة الطفل إلى Supabase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
      final path = 'profiles/$fileName';

      await _client.storage.from('children').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return _client.storage.from('children').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// الاستماع لتغييرات بيانات طفل معين (Real-time)
  Stream<ChildModel?> watchChild(String id) {
    return _client
        .from('children')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isEmpty ? null : ChildModel.fromJson(data.first));
  }

  /// الاستماع لتغييرات قائمة أطفال ولي أمر معين
  Stream<List<ChildModel>> watchChildrenByGuardian(String guardianId) {
    return _client
        .from('children')
        .stream(primaryKey: ['id'])
        .eq('guardian_id', guardianId)
        .map((data) => data.map((json) => ChildModel.fromJson(json)).toList());
  }

  /// الاستماع لتغييرات قائمة أطفال فصل معين أو معلم معين
  Stream<List<ChildModel>> watchChildrenByTeacher(String teacherId) {
    return _client
        .from('children')
        .stream(primaryKey: ['id'])
        .eq('teacher_id', teacherId)
        .map((data) => data.map((json) => ChildModel.fromJson(json)).toList());
  }
}
