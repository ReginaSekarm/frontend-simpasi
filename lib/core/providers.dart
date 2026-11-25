import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/ai/ai_repository.dart';
import '../features/auth/auth_repository.dart';
import '../features/baby/baby_model.dart';
import '../features/baby/baby_repository.dart';
import '../features/notification/notification_repository.dart';
import '../features/recipe/recipe_model.dart';
import '../features/recipe/recipe_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final babyRepositoryProvider = Provider<BabyRepository>((ref) => BabyRepository());
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) => RecipeRepository());
final aiRepositoryProvider = Provider<AiRepository>((ref) => AiRepository());
final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => NotificationRepository());

// ---------- Data yang dimuat dari backend ----------
final babiesProvider = FutureProvider.autoDispose<List<Baby>>(
    (ref) => ref.watch(babyRepositoryProvider).list());

final checkupsProvider = FutureProvider.autoDispose.family<List<Checkup>, int>(
    (ref, babyId) => ref.watch(babyRepositoryProvider).checkups(babyId));

typedef RecipeFilter = ({String? ageCategory, String? mainIngredient, String? search});

final recipesProvider = FutureProvider.autoDispose.family<List<Recipe>, RecipeFilter>(
    (ref, f) => ref.watch(recipeRepositoryProvider).list(
          ageCategory: f.ageCategory,
          mainIngredient: f.mainIngredient,
          search: f.search,
        ));

final recipeDetailProvider = FutureProvider.autoDispose.family<Recipe, int>(
    (ref, id) => ref.watch(recipeRepositoryProvider).detail(id));

final recommendationsProvider = FutureProvider.autoDispose.family<List<Recipe>, int>(
    (ref, babyId) => ref.watch(recipeRepositoryProvider).recommendationsFor(babyId));

final collectionProvider = FutureProvider.autoDispose<List<Recipe>>(
    (ref) => ref.watch(recipeRepositoryProvider).collection());

final commentsProvider = FutureProvider.autoDispose.family<List<RecipeComment>, int>(
    (ref, recipeId) => ref.watch(recipeRepositoryProvider).comments(recipeId));

final aiHistoryProvider = FutureProvider.autoDispose<List<AiHistoryItem>>(
    (ref) => ref.watch(aiRepositoryProvider).history());

final notificationsProvider = FutureProvider.autoDispose<NotificationPage>(
    (ref) => ref.watch(notificationRepositoryProvider).list());