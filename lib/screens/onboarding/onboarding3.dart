// lib/screens/onboarding3.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _image = 'assets/images/onboarding3.png';
const _title = 'Profil Tumbuh Kembang';
const _desc =
    'Simpan profil lengkap si Kecil dan lihat grafik perkembangannya dibandingkan standar tumbuh kembang balita Indonesia.';

// Isi halaman 3 saja. Tombol, titik, dan panah ada di onboarding1.dart
class Onboarding3Page extends StatelessWidget {
  const Onboarding3Page({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 393;
    final sy = size.height / 852;

    return Stack(
      children: [
        Positioned(
          top: 107 * sy,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              _image,
              width: 265 * s,
              height: 374 * s,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 500 * sy,
          left: 0,
          right: 0,
          child: Text(
            _title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24.2275 * s,
              fontWeight: FontWeight.w700,
              height: 29 / 24.2275,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: 550 * sy,
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