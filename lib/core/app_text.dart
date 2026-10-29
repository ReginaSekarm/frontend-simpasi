import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gf;

import '../utils/responsive.dart';

extension AppText on BuildContext {
  /// Teks Inter singkat.
  /// w = 400 / 500 / 600 / 700, h = rasio tinggi baris (mis. 15 / 12).
  TextStyle txt(
    double size, {
    int w = 400,
    Color c = Colors.black,
    double? h,
    TextDecoration? deco,
  }) =>
      gf.GoogleFonts.inter(
        fontSize: size * Responsive.scale(this),
        fontWeight: FontWeight.values[(w ~/ 100) - 1],
        color: c,
        height: h,
        decoration: deco,
      );
}