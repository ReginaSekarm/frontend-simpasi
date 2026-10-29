import 'package:flutter/foundation.dart';

class RecipeItem {
  final String title;
  final String imagePath;
  final String badge;

  const RecipeItem({
    required this.title,
    required this.imagePath,
    required this.badge,
  });
}

class RecipeStore {
  // Semua resep yang tersedia
  static const List<RecipeItem> all = [
    RecipeItem(
      title: 'Bubur Hati Ayam',
      imagePath: 'assets/images/bubur-hati-ayam.png',
      badge: '9 - 11 Bulan',
    ),
    RecipeItem(
      title: 'Kue Ubi Keju',
      imagePath: 'assets/images/kue-ubi-keju.png',
      badge: '9 - 11 Bulan',
    ),
    RecipeItem(
      title: 'Jagung Kukus',
      imagePath: 'assets/images/jagung-kukus.png',
      badge: '9 - 11 Bulan',
    ),
    RecipeItem(
      title: 'Pepaya Lumat',
      imagePath: 'assets/images/pepaya-lumat.png',
      badge: '6 Bulan',
    ),
    RecipeItem(
      title: 'Telur Santan Pisang',
      imagePath: 'assets/images/telur-santan-pisang.png',
      badge: '9 - 11 Bulan',
    ),
    RecipeItem(
      title: 'Tahu Ayam Wortel',
      imagePath: 'assets/images/tahu-ayam-wortel.png',
      badge: '7 - 8 Bulan',
    ),
    RecipeItem(
      title: 'Egg Potato Mash',
      imagePath: 'assets/images/egg-potato-mash.png',
      badge: '12+ Bulan',
    ),
  ];

  /// Set title yang sudah di-like
  static final ValueNotifier<Set<String>> favorites = ValueNotifier({});

  static bool isLiked(String title) => favorites.value.contains(title);

  static void toggle(String title) {
    final next = Set<String>.from(favorites.value);
    if (next.contains(title)) {
      next.remove(title);
    } else {
      next.add(title);
    }
    favorites.value = next;
  }
}