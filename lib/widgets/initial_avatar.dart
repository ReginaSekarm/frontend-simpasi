import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Avatar bulat berisi inisial nama user (misal "A" untuk Aisyah).
/// Dipakai di Home dan Menu — biar warna & ukuran konsisten.
class InitialAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const InitialAvatar({
    super.key,
    required this.initial,
    this.size = 50,
  });

  // Warna sama di semua halaman
  static const Color bgColor   = Color(0xFFFCEBD5);
  static const Color textColor = Color(0xFF9E5665);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(size),
      height: context.w(size),
      decoration: const BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: context.sp(size * 24 / 50), // rasio 24:50 seperti desain
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 29 / 24,
        ),
      ),
    );
  }
}