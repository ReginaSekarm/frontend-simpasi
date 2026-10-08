// lib/screens/onboarding3.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding4.dart';
import '../auth/register.dart';

const _kRed = Color(0xFFD45060);
const _kOrange = Color(0xFFF1A038);
const _kDot = Color(0xFFD9D9D9);

const _image = 'assets/images/onboarding3.png'; 
const _title = 'Profil Tumbuh Kembang';
const _desc =
    'Simpan profil lengkap si Kecil dan lihat grafik perkembangannya dibandingkan standar tumbuh kembang balita Indonesia.';
const _total = 4;
const _current = 2;

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

class Onboarding3Page extends StatelessWidget {
  const Onboarding3Page({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 393;
    final sy = size.height / 852;

    final secondary = ModalRoute.of(context)!.secondaryAnimation!;

    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0))
          .animate(CurvedAnimation(parent: secondary, curve: Curves.easeInOut)),
      child: Scaffold(
        backgroundColor: _kRed,
        body: Stack(
          children: [
            // Ilustrasi (Batas bawah gambar berakhir di y ≈ 481)
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

            // Judul (Diturunkan ke 500 * sy agar ada space dari gambar)
            Positioned(
              top: 500 * sy,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 283 * s,
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

            // Deskripsi (Diturunkan ke 550 * sy agar tidak mepet dengan judul)
            Positioned(
              top: 580 * sy,
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

            // Tombol Lewati
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

            // Indikator halaman
            Positioned(
              left: 22.21 * s,
              bottom: 45.43 * sy,
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

            // Tombol panah mundur
            Positioned(
              right: 71.68 * s,
              bottom: 25.24 * sy,
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

            // Tombol panah maju
            Positioned(
              right: 18.15 * s,
              bottom: 25.24 * sy,
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .push(_slide(const Onboarding4Page())),
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