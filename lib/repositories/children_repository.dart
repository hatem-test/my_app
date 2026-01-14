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

  /// جلب جميع الأطفال مع بيانات المعلمة وولي الأمر
  Future<List<Map<String, dynamic>>> getAllChildrenWithDetails() async {
    try {
      final response = await _client.from('children').select('''
            *,
            guardians(id, users(name)),
            teachers(id, users(name))
          ''');

      debugPrint(
          'DEBUG: getAllChildrenWithDetails - Response length: ${(response as List).length}');

      return (response as List).map((json) {
        try {
          final child = ChildModel.fromJson(json);
          final guardian = json['guardians'];
          final teacher = json['teachers'];

          String guardianName = 'غير محدد';
          if (guardian != null) {
            if (guardian is Map) {
              if (guardian['users'] != null) {
                final user = guardian['users'];
                if (user is Map && user['name'] != null) {
                  guardianName = user['name'] as String;
                }
              } else {
                debugPrint(
                    'DEBUG: guardian exists but users is null for child ${child.id}');
              }
            }
          }

          String teacherName = 'غير محدد';
          if (teacher != null) {
            if (teacher is Map) {
              if (teacher['users'] != null) {
                final user = teacher['users'];
                if (user is Map && user['name'] != null) {
                  teacherName = user['name'] as String;
                }
              } else {
                debugPrint(
                    'DEBUG: teacher exists but users is null for child ${child.id}');
              }
            }
          }

          return {
            'child': child,
            'guardianName': guardianName,
            'teacherName': teacherName,
          };
        } catch (e) {
          debugPrint('Error parsing child data: $e');
          // في حالة فشل parsing، نحاول على الأقل إرجاع الطفل بدون التفاصيل
          try {
            final child = ChildModel.fromJson(json);
            return {
              'child': child,
              'guardianName': 'غير محدد',
              'teacherName': 'غير محدد',
            };
          } catch (e2) {
            debugPrint('Error creating child model: $e2');
            rethrow;
          }
        }
      }).toList();
    } on PostgrestException catch (e) {
      final errorMessage = e.message ?? '';
      final errorCode = e.code ?? '';
      final errorDetails = e.details ?? '';
      final errorHint = e.hint ?? '';

      debugPrint(
          'PostgrestException in getAllChildrenWithDetails: $errorCode - $errorMessage');
      debugPrint('Details: $errorDetails');
      debugPrint('Hint: $errorHint');

      // إذا كان الخطأ متعلق بالصلاحيات، نعيد خطأ واضح
      if (errorMessage.contains('permission denied') ||
          errorMessage.contains('RLS') ||
          errorCode == 'PGRST301') {
        throw 'خطأ في الصلاحيات: يرجى التأكد من أن السياسات (RLS Policies) تم تطبيقها بشكل صحيح. راجع ملف complete_admin_rls_policies.sql';
      }
      rethrow;
    } catch (e) {
      debugPrint('Error fetching children with details: $e');
      // في حالة فشل الـ join، نعيد البيانات بدون التفاصيل
      try {
        final children = await getAllChildren();
        return children
            .map((child) => {
                  'child': child,
                  'guardianName': 'غير محدد',
                  'teacherName': 'غير محدد',
                })
            .toList();
      } catch (e2) {
        debugPrint('Error fetching children without details: $e2');
        rethrow;
      }
    }
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
      final path = 'child/$fileName';

      await _client.storage.from('images').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return _client.storage.from('images').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading image to Supabase Storage: $e');
      // Rethrowing so the UI can catch it and show a snackbar
      throw 'فشل رفع الصورة: $e';
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
