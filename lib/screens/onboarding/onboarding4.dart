// lib/screens/onboarding4.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/register.dart';

const _kRed = Color(0xFFD45060);
const _kMulaiBg = Color(0xFFB3EAE8);
const _kMulaiText = Color(0xFF1A7772);
const _kOrange = Color(0xFFF1A038);
const _kDot = Color(0xFFD9D9D9);

const _image = 'assets/images/onboarding4.png';
const _title = 'Forum Diskusi';
const _desc =
    'Terhubung dengan sesama orang tua dan kader Posyandu se-Indonesia '
    'untuk berbagi cerita, bertanya, dan saling mendukung mencegah stunting.';

const _total = 4; // Disesuaikan dengan _total di Onboarding 3
const _current = 3; // Indeks ke-3 (slide ke-4/terakhir)

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

class Onboarding4Page extends StatelessWidget {
  const Onboarding4Page({super.key});

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
            // Ilustrasi
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

            // Judul (Diberi lebar lebih besar 280 * s agar tidak terlipat dua baris)
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

            // Deskripsi (Diatur posisi top-nya agar ada space lebih aman dengan judul)
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

            // Tombol "Mulai"
            Positioned(
              right: 18.15 * s,
              bottom: 25.24 * sy,
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushReplacement(_slide(const RegisterScreen())),
                child: Container(
                  width: 83.23 * s,
                  height: 50.47 * sy,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kMulaiBg,
                    borderRadius: BorderRadius.circular(31.8075 * s),
                  ),
                  child: Text(
                    'Mulai',
                    style: GoogleFonts.inter(
                      fontSize: 12.723 * s,
                      fontWeight: FontWeight.w600,
                      height: 15 / 12.723,
                      color: _kMulaiText,
                    ),
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