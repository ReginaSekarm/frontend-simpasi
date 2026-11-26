import '../core/network/api_client.dart';
import 'service_error.dart';

class CommentReplyData {
  final int id;
  final int userId;
  final String userName;
  final String content;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final int? ageSeconds;

  const CommentReplyData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.createdAt,
    this.editedAt,
    this.ageSeconds,
  });

  factory CommentReplyData.fromJson(Map<String, dynamic> j) {
    int parseInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return CommentReplyData(
      id: parseInt(j['id']),
      userId: parseInt(j['user_id'] ?? j['userId']),
      userName: (j['user_name'] ?? j['userName'] ?? 'Pengguna').toString(),
      content: (j['content'] ?? '').toString(),
      createdAt: parseDt(j['created_at'] ?? j['createdAt']),
      editedAt: parseDt(j['edited_at'] ?? j['editedAt']),
      ageSeconds: j['age_seconds'] != null ? parseInt(j['age_seconds']) : null,
    );
  }
}

class CommentThreadData {
  final int id;
  final int userId;
  final String userName;
  final String content;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final int? ageSeconds;
  final int replyCount;
  final List<CommentReplyData> replies;

  const CommentThreadData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.createdAt,
    this.editedAt,
    this.ageSeconds,
    this.replyCount = 0,
    this.replies = const [],
  });

  factory CommentThreadData.fromJson(
    Map<String, dynamic> j, {
    List<CommentReplyData> replies = const [],
  }) {
    int parseInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    final countRaw = j['reply_count'] ?? j['replyCount'];
    final resolvedCount =
        countRaw != null ? parseInt(countRaw) : replies.length;

    return CommentThreadData(
      id: parseInt(j['id']),
      userId: parseInt(j['user_id'] ?? j['userId']),
      userName: (j['user_name'] ?? j['userName'] ?? 'Pengguna').toString(),
      content: (j['content'] ?? '').toString(),
      createdAt: parseDt(j['created_at'] ?? j['createdAt']),
      editedAt: parseDt(j['edited_at'] ?? j['editedAt']),
      ageSeconds: j['age_seconds'] != null ? parseInt(j['age_seconds']) : null,
      replyCount: resolvedCount,
      replies: replies,
    );
  }

  CommentThreadData copyWith({
    String? content,
    DateTime? editedAt,
    int? replyCount,
    List<CommentReplyData>? replies,
  }) {
    return CommentThreadData(
      id: id,
      userId: userId,
      userName: userName,
      content: content ?? this.content,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      ageSeconds: ageSeconds,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? this.replies,
    );
  }
}

class CommentsResult {
  final List<CommentThreadData> comments;
  final String? error;

  const CommentsResult({this.comments = const [], this.error});
}

class CommentActionResult {
  final bool success;
  final String? error;
  final int? createdId;

  const CommentActionResult({
    required this.success,
    this.error,
    this.createdId,
  });
}

class CommentService {
  CommentService._();

  static Future<CommentsResult> getComments(int recipeId) async {
    try {
      final res = await ApiClient.get('/recipes/$recipeId/comments');
      final rawList = res['data'];
      if (rawList is! List) {
        return const CommentsResult(comments: []);
      }

      final threads = rawList
          .whereType()
          .map(
            (e) => CommentThreadData.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();

      return CommentsResult(comments: threads);
    } catch (e) {
      return CommentsResult(error: pesanError(e));
    }
  }

  static Future<List<CommentReplyData>> getReplies(int commentId) async {
    try {
      final res = await ApiClient.get('/recipes/comments/$commentId/replies');
      final rawList = res['data'];
      if (rawList is! List) return const [];

      return rawList
          .whereType()
          .map(
            (e) => CommentReplyData.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<CommentActionResult> createComment({
    required int recipeId,
    required String content,
  }) async {
    try {
      final res = await ApiClient.post(
        '/recipes/$recipeId/comments',
        data: {'content': content},
      );
      final data = res['data'];
      int? createdId;
      if (data is Map && data['id'] != null) {
        createdId = int.tryParse(data['id'].toString());
      }
      return CommentActionResult(success: true, createdId: createdId);
    } catch (e) {
      return CommentActionResult(success: false, error: pesanError(e));
    }
  }

  static Future<CommentActionResult> replyComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final res = await ApiClient.post(
        '/recipes/comments/$commentId/reply',
        data: {'content': content},
      );
      final data = res['data'];
      int? createdId;
      if (data is Map && data['id'] != null) {
        createdId = int.tryParse(data['id'].toString());
      }
      return CommentActionResult(success: true, createdId: createdId);
    } catch (e) {
      return CommentActionResult(success: false, error: pesanError(e));
    }
  }

  static Future<CommentActionResult> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      await ApiClient.put(
        '/recipes/comments/$commentId',
        data: {'content': content},
      );
      return const CommentActionResult(success: true);
    } catch (e) {
      return CommentActionResult(success: false, error: pesanError(e));
    }
  }

  static Future<CommentActionResult> deleteComment(int commentId) async {
    try {
      await ApiClient.delete('/recipes/comments/$commentId');
      return const CommentActionResult(success: true);
    } catch (e) {
      return CommentActionResult(success: false, error: pesanError(e));
    }
  }
}