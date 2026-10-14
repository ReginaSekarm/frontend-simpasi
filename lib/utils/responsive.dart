import 'package:flutter/material.dart';

class Responsive {
  static const double designWidth = 390; // lebar desain Figma
  static const double maxContentWidth = 480; // batas lebar di tablet/web

  static double scale(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w / designWidth).clamp(0.75, 1.25);
  }
}

extension ResponsiveContext on BuildContext {
  /// Skala dari lebar layar (0.75 - 1.25)
  double get k => Responsive.scale(this);

  /// Ukuran lebar/tinggi/ikon: context.w(65)
  double w(double v) => v * k;

  /// Ukuran font: context.sp(14)
  double sp(double v) => v * k;

  double get screenW => MediaQuery.sizeOf(this).width;
  double get screenH => MediaQuery.sizeOf(this).height;

  bool get isSmallPhone => screenW < 360;
  bool get isTablet => screenW >= 600;
}