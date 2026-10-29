import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppNav {
  /// Push dengan transisi yang lebih halus + precache asset
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    List<String> precacheImages = const [],
    List<String> precacheSvgs = const [],
  }) async {
    // Pre-cache dulu supaya saat transisi gambar sudah siap
    for (final path in precacheImages) {
      await precacheImage(AssetImage(path), context);
    }
    for (final path in precacheSvgs) {
      final loader = SvgAssetLoader(path);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }

    if (!context.mounted) return null;

    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: child,
            ),
          );
        },
      ),
    );
  }
}