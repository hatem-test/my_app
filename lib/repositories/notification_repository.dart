import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب إشعارات المستخدم
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  /// تحديد إشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  /// حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    await _client.from('notifications').delete().eq('id', notificationId);
  }

  /// الاستماع للإشعارات الجديدة (Real-time)
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((json) => NotificationModel.fromJson(json)).toList());
  }

  /// الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (response as List).length;
  }
}
