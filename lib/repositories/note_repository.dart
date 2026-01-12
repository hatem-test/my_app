import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class NoteRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب جميع الملاحظات لطفل محدد
  Future<List<NoteModel>> getNotesByChild(String childId) async {
    final response = await _client
        .from('notes')
        .select()
        .eq('child_id', childId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => NoteModel.fromJson(json)).toList();
  }

  /// إضافة ملاحظة جديدة
  Future<NoteModel> createNote(NoteModel note) async {
    final response = await _client
        .from('notes')
        .insert(note.toInsertJson())
        .select()
        .single();
    return NoteModel.fromJson(response);
  }

  /// تحديث ملاحظة
  Future<NoteModel> updateNote(String id, String content) async {
    final response = await _client
        .from('notes')
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return NoteModel.fromJson(response);
  }

  /// حذف ملاحظة
  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }

  /// الاستماع للملاحظات الجديدة (Real-time)
  Stream<List<NoteModel>> watchNotes(String childId) {
    return _client
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('child_id', childId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => NoteModel.fromJson(json)).toList());
  }
}
