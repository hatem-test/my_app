import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AttendanceRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب سجلات الحضور ليوم معين
  Future<List<AttendanceModel>> getAttendanceByDate(DateTime date) async {
    final dateString = date.toIso8601String().split('T').first;
    final response = await _client
        .from('attendance')
        .select()
        .eq('attendance_date', dateString);
    return (response as List)
        .map((json) => AttendanceModel.fromJson(json))
        .toList();
  }

  /// جلب سجلات الحضور لطفل معين
  Future<List<AttendanceModel>> getAttendanceByChild(String childId) async {
    final response = await _client
        .from('attendance')
        .select()
        .eq('child_id', childId)
        .order('attendance_date', ascending: false);
    return (response as List)
        .map((json) => AttendanceModel.fromJson(json))
        .toList();
  }

  /// جلب سجل الحضور الحالي لطفل اليوم (إن وجد)
  Future<AttendanceModel?> getTodayAttendance(String childId) async {
    final dateString = DateTime.now().toIso8601String().split('T').first;
    final response = await _client
        .from('attendance')
        .select()
        .eq('child_id', childId)
        .eq('attendance_date', dateString)
        .maybeSingle();
    return response != null ? AttendanceModel.fromJson(response) : null;
  }

  /// تسجيل حضور (Check-in)
  Future<AttendanceModel> checkIn(String childId, String teacherId) async {
    final now = DateTime.now();

    final attendance = AttendanceModel(
      id: '', // سيتم توليده من قاعدة البيانات
      childId: childId,
      recordedBy: teacherId,
      checkIn: now,
      status: AttendanceStatus.present,
      attendanceDate: now,
    );

    final response = await _client
        .from('attendance')
        .insert(attendance.toInsertJson())
        .select()
        .single();
    return AttendanceModel.fromJson(response);
  }

  /// تسجيل انصراف (Check-out)
  Future<AttendanceModel> checkOut(String attendanceId) async {
    final now = DateTime.now();
    final response = await _client
        .from('attendance')
        .update({
          'check_out': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .eq('id', attendanceId)
        .select()
        .single();
    return AttendanceModel.fromJson(response);
  }

  /// تحديث حالة الحضور
  Future<AttendanceModel> updateStatus(
      String attendanceId, AttendanceStatus status) async {
    final response = await _client
        .from('attendance')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', attendanceId)
        .select()
        .single();
    return AttendanceModel.fromJson(response);
  }

  /// الاستماع لتغييرات الحضور اليوم (Real-time)
  Stream<List<AttendanceModel>> watchTodayAttendance() {
    final dateString = DateTime.now().toIso8601String().split('T').first;
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('attendance_date', dateString)
        .map((data) =>
            data.map((json) => AttendanceModel.fromJson(json)).toList());
  }
}
