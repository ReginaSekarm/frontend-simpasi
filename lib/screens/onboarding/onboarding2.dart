// lib/screens/onboarding2.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _image = 'assets/images/onboarding2.png';
const _title = 'Pencarian Riwayat\nPemeriksaan';
const _desc =
    'Catat berat, tinggi, dan lingkar kepala si Kecil di setiap kunjungan, lalu pantau riwayat pertumbuhannya dari waktu ke waktu.';

// Isi halaman 2 saja. Tombol, titik, dan panah ada di onboarding1.dart
class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 393;
    final sy = size.height / 852;

    return Stack(
      children: [
        Positioned(
          top: 259.44 * sy,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              _image,
              width: 169.44 * s,
              height: 166.71 * s,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 460.32 * sy,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 260 * s,
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
          top: 532 * sy,
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