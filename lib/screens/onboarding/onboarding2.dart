// lib/screens/onboarding2.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding3.dart'; // Tetap
import '../auth/register.dart';

const _kRed = Color(0xFFD45060);
const _kOrange = Color(0xFFF1A038);
const _kDot = Color(0xFFD9D9D9);

const _image = 'assets/images/onboarding2.png';
const _title = 'Pencarian Riwayat\nPemeriksaan';
const _desc =
    'Catat berat, tinggi, dan lingkar kepala si Kecil di setiap kunjungan, lalu pantau riwayat pertumbuhannya dari waktu ke waktu.';
const _total = 5;
const _current = 1;

// Halaman baru masuk dari kanan (mundur = keluar ke kanan)
Route<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
    );

class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 393; // skala lebar terhadap frame Figma
    final sy = size.height / 852; // skala tinggi terhadap frame Figma

    // Halaman ini keluar ke kiri saat halaman lain masuk di atasnya
    final secondary = ModalRoute.of(context)!.secondaryAnimation!;

    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0))
          .animate(CurvedAnimation(parent: secondary, curve: Curves.easeInOut)),
      child: Scaffold(
        backgroundColor: _kRed,
        body: Stack(
          children: [
            // Ilustrasi (169.44 x 166.71, top 259.44)
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

            // Judul 2 baris (lebar 260, top 460.32)
            Positioned(
              top: 460.32 * sy,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 260 * s,           // 👈 UBAH: 225 → 260
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

            // Deskripsi (lebar 352.31, top 532)
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

            // Tombol Lewati (84.02 x 32.11, top 65, kanan 17.94)
            Positioned(
              top: 65 * sy,
              right: 17.94 * s,
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushReplacement(_slide(const RegisterScreen())),
                child: Container(
                  width: 84.02 * s,
                  height: 32.11 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(32.1089 * s),
                  ),
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.inter(
                      fontSize: 12.8436 * s,
                      fontWeight: FontWeight.w600,
                      height: 16 / 12.8436,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),

            // Indikator halaman (kiri 22.21, bawah 45.43)
            Positioned(
              left: 22.21 * s,
              bottom: 45.43 * s,
              child: Row(
                children: List.generate(_total, (i) {
                  final active = i == _current;
                  return Container(
                    margin: EdgeInsets.only(right: 4.04 * s),
                    width: (active ? 48.45 : 7.07) * s,
                    height: (active ? 10.09 : 7.07) * s,
                    decoration: BoxDecoration(
                      color: active ? _kOrange : _kDot,
                      borderRadius: BorderRadius.circular(30.2844 * s),
                    ),
                  );
                }),
              ),
            ),

            // Tombol panah mundur (kanan 71.68, bawah 25.24)
            Positioned(
              right: 71.68 * s,
              bottom: 25.24 * s,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 50.47 * s,
                  height: 50.47 * s,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: _kRed,
                    size: 30 * s,
                  ),
                ),
              ),
            ),

            // Tombol panah maju (kanan 18.15, bawah 25.24)
            Positioned(
              right: 18.15 * s,
              bottom: 25.24 * s,
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .push(_slide(const Onboarding3Page())),
                child: Container(
                  width: 50.47 * s,
                  height: 50.47 * s,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: _kRed,
                    size: 30 * s,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}