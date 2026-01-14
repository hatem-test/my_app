import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ReportRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب تقارير طفل معين
  Future<List<ReportModel>> getReportsByChild(String childId) async {
    final response = await _client
        .from('reports')
        .select()
        .eq('child_id', childId)
        .order('report_date', ascending: false);
    return (response as List)
        .map((json) => ReportModel.fromJson(json))
        .toList();
  }

  /// جلب تقرير يوم معين لطفل
  Future<ReportModel?> getReportByDate(String childId, DateTime date) async {
    final dateString = date.toIso8601String().split('T').first;
    final response = await _client
        .from('reports')
        .select()
        .eq('child_id', childId)
        .eq('report_date', dateString)
        .maybeSingle();
    return response != null ? ReportModel.fromJson(response) : null;
  }

  /// إضافة تقرير جديد
  Future<ReportModel> createReport(ReportModel report) async {
    final response = await _client
        .from('reports')
        .insert(report.toInsertJson())
        .select()
        .single();
    return ReportModel.fromJson(response);
  }

  /// تحديث تقرير
  Future<ReportModel> updateReport(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('reports')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ReportModel.fromJson(response);
  }

  /// الاستماع للتقارير (Real-time)
  Stream<List<ReportModel>> watchReports(String childId) {
    return _client
        .from('reports')
        .stream(primaryKey: ['id'])
        .eq('child_id', childId)
        .order('report_date', ascending: false)
        .map((data) => data.map((json) => ReportModel.fromJson(json)).toList());
  }

  /// جلب جميع التقارير (للأدمن) مع إمكانية التصفية حسب التاريخ
  /// يُرجع قائمة من Map تحتوي على بيانات التقرير والطفل والمعلمة
  Future<List<Map<String, dynamic>>> getAllReports({DateTime? date}) async {
    var query = _client.from('reports').select('''
      *,
      children:child_id(name, gender, image_url),
      teachers:teacher_id(
        users:user_id(name)
      )
    ''');

    if (date != null) {
      final dateString = date.toIso8601String().split('T').first;
      query = query.eq('report_date', dateString);
    }

    final response = await query.order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
