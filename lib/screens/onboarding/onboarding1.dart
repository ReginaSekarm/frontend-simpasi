// lib/screens/onboarding1.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding2.dart';
import '../auth/register.dart';

const _kRed = Color(0xFFD45060);
const _kOrange = Color(0xFFF1A038);
const _kDot = Color(0xFFD9D9D9);

const _image = 'assets/images/onboarding1.png'; // "Group 483.png" dari Figma
const _title = 'Resep Bergizi Harian';
const _desc =
    'Ratusan ide resep MPASI dan makanan bergizi yang mudah diikuti, siap mendukung tumbuh kembang si Kecil setiap hari.';
const _total = 5;
const _current = 0;

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

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

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
            // Ilustrasi (152.43 x 172.62, top 253.38)
            Positioned(
              top: 253.38 * sy,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  _image,
                  width: 152.43 * s,
                  height: 172.62 * s,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Judul (top 469.41)
            Positioned(
              top: 469.41 * sy,
              left: 0,
              right: 0,
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

            // Deskripsi (top 517.86, lebar 352.31)
            Positioned(
              top: 517.86 * sy,
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
                      fontWeight: FontWeight.w500,
                      height: 20 / 16.1517,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Tombol Lewati (83.23 x 31.81, top 65, kanan 17.7)
            Positioned(
              top: 65 * sy,
              right: 17.7 * s,
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushReplacement(_slide(const RegisterScreen())),
                child: Container(
                  width: 83.23 * s,
                  height: 31.81 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(31.8075 * s),
                  ),
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.inter(
                      fontSize: 12.723 * s,
                      fontWeight: FontWeight.w600,
                      height: 15 / 12.723,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),

            // Indikator halaman (kiri 21.2, bawah 45.43)
            Positioned(
              left: 21.2 * s,
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

            // Tombol panah maju (50.47, kanan 18.15, bawah 25.24)
            Positioned(
              right: 18.15 * s,
              bottom: 25.24 * s,
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).push(_slide(const Onboarding2Page())),
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