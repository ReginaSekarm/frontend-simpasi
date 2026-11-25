import '../../utils/json_utils.dart';

class Recipe {
  final int id;
  final String title;
  final String? photoUrl, ageCategory, mainIngredient, tips, storageTips;
  final String ingredients, steps; // satu baris = satu item
  final double? proteinG, carbsG, fatG;
  final int? calories;

  const Recipe({
    required this.id,
    required this.title,
    this.photoUrl,
    this.ageCategory,
    this.mainIngredient,
    required this.ingredients,
    required this.steps,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.calories,
    this.tips,
    this.storageTips,
  });

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
        id: asInt(j['id'])!,
        title: j['title'] as String,
        photoUrl: j['photo_url'] as String?,
        ageCategory: j['age_category'] as String?,
        mainIngredient: j['main_ingredient'] as String?,
        ingredients: (j['ingredients'] as String?) ?? '',
        steps: (j['steps'] as String?) ?? '',
        proteinG: asDouble(j['protein_g']),
        carbsG: asDouble(j['carbs_g']),
        fatG: asDouble(j['fat_g']),
        calories: asInt(j['calories']),
        tips: j['tips'] as String?,
        storageTips: j['storage_tips'] as String?,
      );

  List<String> get ingredientList => _lines(ingredients);
  List<String> get stepList => _lines(steps);

  static List<String> _lines(String s) =>
      s.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

class RecipeComment {
  final int id;
  final int userId;
  final String userName, content;
  final DateTime createdAt;
  final DateTime? editedAt;
  final int ageSeconds; // umur komentar, dihitung server
  final int replyCount;

  const RecipeComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.editedAt,
    required this.ageSeconds,
    required this.replyCount,
  });

  factory RecipeComment.fromJson(Map<String, dynamic> j) => RecipeComment(
        id: asInt(j['id'])!,
        userId: asInt(j['user_id'])!,
        userName: (j['user_name'] as String?) ?? '',
        content: j['content'] as String,
        createdAt: asDate(j['created_at'])!,
        editedAt: asDate(j['edited_at']),
        ageSeconds: asInt(j['age_seconds']) ?? 0,
        replyCount: asInt(j['reply_count']) ?? 0,
      );

  bool get isEdited => editedAt != null;

  /// User hanya boleh mengedit komentarnya sendiri dalam 24 jam
  bool canEdit(int myUserId) => userId == myUserId && ageSeconds < 24 * 3600;
  bool canDelete(int myUserId) => userId == myUserId;
}