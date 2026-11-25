import '../../core/network/api_client.dart';
import '../../utils/json_utils.dart';

class AiRecommendation {
  final String babyName;
  final int ageMonths;
  final String html; // <h3>, <p>, <ul><li>, <ol><li>

  const AiRecommendation(this.babyName, this.ageMonths, this.html);

  factory AiRecommendation.fromJson(Map<String, dynamic> j) => AiRecommendation(
        (j['babyName'] as String?) ?? '',
        asInt(j['ageMonths']) ?? 0,
        (j['recommendation'] as String?) ?? '',
      );
}

class AiHistoryItem {
  final int id;
  final String query, response;
  final DateTime createdAt;

  const AiHistoryItem(this.id, this.query, this.response, this.createdAt);

  factory AiHistoryItem.fromJson(Map<String, dynamic> j) => AiHistoryItem(
        asInt(j['id'])!,
        (j['query'] as String?) ?? '',
        (j['response'] as String?) ?? '',
        asDate(j['created_at'])!,
      );
}

class AiRepository {
  /// Bisa memakan waktu beberapa detik; tampilkan loading.
  Future<AiRecommendation> recommend({
    required int babyId,
    String? allergies,
    required String availableIngredients,
  }) async {
    final res = await ApiClient.post('/ai/recommend-menu', data: {
      'babyId': babyId,
      'allergies': allergies?.trim(),
      'availableIngredients': availableIngredients.trim(),
    });
    return AiRecommendation.fromJson(Map<String, dynamic>.from(res['data'] as Map));
  }

  Future<List<AiHistoryItem>> history() async =>
      dataList(await ApiClient.get('/ai/history')).map(AiHistoryItem.fromJson).toList();
}