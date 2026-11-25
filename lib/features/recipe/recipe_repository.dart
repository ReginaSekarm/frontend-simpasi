import '../../core/network/api_client.dart';
import '../../utils/json_utils.dart';
import 'recipe_model.dart';

class RecipeRepository {
  // ---------- Resep ----------
  Future<List<Recipe>> list({String? ageCategory, String? mainIngredient, String? search}) async {
    final res = await ApiClient.get('/recipes', query: {
      if (ageCategory != null && ageCategory.isNotEmpty) 'ageCategory': ageCategory,
      if (mainIngredient != null && mainIngredient.isNotEmpty) 'mainIngredient': mainIngredient,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    });
    return dataList(res).map(Recipe.fromJson).toList();
  }

  Future<Recipe> detail(int id) async {
    final res = await ApiClient.get('/recipes/$id');
    return Recipe.fromJson(Map<String, dynamic>.from(res['data'] as Map));
  }

  /// Rekomendasi menu sesuai umur & kondisi anak.
  /// CATATAN: bentuk response endpoint ini belum saya lihat; di sini diasumsikan daftar resep.
  Future<List<Recipe>> recommendationsFor(int babyId) async =>
      dataList(await ApiClient.get('/babies/$babyId/recommendations')).map(Recipe.fromJson).toList();

  // ---------- Koleksi ----------
  Future<List<Recipe>> collection() async =>
      dataList(await ApiClient.get('/collection')).map(Recipe.fromJson).toList();

  Future<void> saveToCollection(int recipeId) async {
    await ApiClient.post('/collection', data: {'recipeId': recipeId});
  }

  Future<void> removeFromCollection(int recipeId) async {
    await ApiClient.delete('/collection/$recipeId');
  }

  // ---------- Komentar ----------
  Future<List<RecipeComment>> comments(int recipeId) async =>
      dataList(await ApiClient.get('/recipes/$recipeId/comments')).map(RecipeComment.fromJson).toList();

  Future<List<RecipeComment>> replies(int commentId) async =>
      dataList(await ApiClient.get('/comments/$commentId/replies')).map(RecipeComment.fromJson).toList();

  Future<void> addComment(int recipeId, String content) async {
    await ApiClient.post('/recipes/$recipeId/comments', data: {'content': content.trim()});
  }

  Future<void> reply(int commentId, String content) async {
    await ApiClient.post('/comments/$commentId/reply', data: {'content': content.trim()});
  }

  Future<void> editComment(int commentId, String content) async {
    await ApiClient.put('/comments/$commentId', data: {'content': content.trim()});
  }

  Future<void> deleteComment(int commentId) async {
    await ApiClient.delete('/comments/$commentId');
  }
}