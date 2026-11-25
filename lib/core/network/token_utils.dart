import 'dart:convert';
import 'api_client.dart';

class SessionInfo {
  final int userId;
  final String role; // 'user' atau 'kader'
  final DateTime expiresAt;
  const SessionInfo(this.userId, this.role, this.expiresAt);
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class TokenUtils {
  static SessionInfo? decode(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return SessionInfo(
        (map['id'] as num).toInt(),
        map['role'] as String,
        DateTime.fromMillisecondsSinceEpoch((map['exp'] as num).toInt() * 1000),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<SessionInfo?> current() async => decode(await ApiClient.getToken());
}