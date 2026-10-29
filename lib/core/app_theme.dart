// core/app_theme.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_page_transistions.dart';

class AppColors {
  static const Color primary = Color(0xFFD45060);
  static const Color accent  = Color(0xFFF1A038);
  static const Color success = Color(0xFF77B255);
  static const Color error   = Color(0xFFDD2E44);
  static const Color cream   = Color(0xFFFCEBD5);
  static const Color teal    = Color(0xFF8BDFDD);
  static const Color grey    = Color(0xFF8F8F8F);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      scaffoldBackgroundColor: Colors.white,
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothFadeScaleTransitionsBuilder(),
          TargetPlatform.iOS: SmoothFadeScaleTransitionsBuilder(),
          TargetPlatform.windows: SmoothFadeScaleTransitionsBuilder(),
          TargetPlatform.macOS: SmoothFadeScaleTransitionsBuilder(),
          TargetPlatform.linux: SmoothFadeScaleTransitionsBuilder(),
        },
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}