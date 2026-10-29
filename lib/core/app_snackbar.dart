import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gf;

import '../utils/responsive.dart';
import 'app_theme.dart';

enum AppSnackType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackType type = AppSnackType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final Color color;
    final IconData icon;
    switch (type) {
      case AppSnackType.success:
        color = AppColors.success;
        icon = Icons.check_circle_outline;
      case AppSnackType.error:
        color = AppColors.error;
        icon = Icons.error_outline;
      case AppSnackType.info:
        color = AppColors.grey;
        icon = Icons.info_outline;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          duration: duration,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottomInset),
          content: Center(
            child: Container(
              height: context.w(44),
              constraints: BoxConstraints(
                minWidth: context.w(200),
                maxWidth: context.w(320),
              ),
              padding: EdgeInsets.symmetric(horizontal: context.w(18)),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(context.w(17)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: context.w(24)),
                  SizedBox(width: context.w(10)),
                  Flexible(
                    child: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: gf.GoogleFonts.inter(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}