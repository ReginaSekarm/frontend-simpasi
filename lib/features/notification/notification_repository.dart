import '../../core/network/api_client.dart';
import '../../utils/json_utils.dart';

class NotificationItem {
  final int id;
  final String title, message, type; // new_recipe, checkup_result, kader_note, comment_reply
  final int? refId;                  // id resep atau id pemeriksaan (sesuai type)
  final String? actorName, refTitle;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.refId,
    this.actorName,
    this.refTitle,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: asInt(j['id'])!,
        title: (j['title'] as String?) ?? '',
        message: (j['message'] as String?) ?? '',
        type: (j['type'] as String?) ?? '',
        refId: asInt(j['ref_id']),
        actorName: j['actor_name'] as String?,
        refTitle: j['ref_title'] as String?,
        isRead: asBool(j['is_read']),
        createdAt: asDate(j['created_at'])!,
      );
}

class NotificationPage {
  final List<NotificationItem> items;
  final int unreadCount; // untuk angka merah di ikon lonceng
  const NotificationPage(this.items, this.unreadCount);
}

class NotificationRepository {
  Future<NotificationPage> list({bool unreadOnly = false}) async {
    final res = await ApiClient.get('/notifications',
        query: {if (unreadOnly) 'filter': 'unread'});
    return NotificationPage(
      dataList(res).map(NotificationItem.fromJson).toList(),
      asInt(res['unreadCount']) ?? 0,
    );
  }

  Future<void> markRead(int id) async {
    await ApiClient.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await ApiClient.put('/notifications/read-all');
  }

  Future<void> remove(int id) async {
    await ApiClient.delete('/notifications/$id');
  }
}