// lib/screens/onboarding4.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _image = 'assets/images/onboarding4.png';
const _title = 'Forum Diskusi';
const _desc =
    'Terhubung dengan sesama orang tua dan kader Posyandu se-Indonesia '
    'untuk berbagi cerita, bertanya, dan saling mendukung mencegah stunting.';

// Isi halaman 4 saja. Tombol "Mulai", titik, dan panah ada di onboarding1.dart
class Onboarding4Page extends StatelessWidget {
  const Onboarding4Page({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 393;
    final sy = size.height / 852;

    return Stack(
      children: [
        Positioned(
          top: 193.82 * sy,
          left: 51.48 * s,
          child: Image.asset(
            _image,
            width: 297.13 * s,
            height: 236.82 * s,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: 469.41 * sy,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 280 * s,
              child: Text(
                _title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24.2275 * s,
                  fontWeight: FontWeight.w700,
                  height: 29 / 24.2275,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 525 * sy,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 352.31 * s,
              child: Text(
                _desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16.1517 * s,
                  fontWeight: FontWeight.w400,
                  height: 20 / 16.1517,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}