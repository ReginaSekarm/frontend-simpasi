// lib/screens/onboarding1.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding2.dart';
import 'onboarding3.dart';
import 'onboarding4.dart';
import '../auth/register.dart';

const _kRed = Color(0xFFD45060);
const _kMulaiBg = Color(0xFFB3EAE8);
const _kMulaiText = Color(0xFF1A7772);
const _kOrange = Color(0xFFF1A038);
const _kDot = Color(0xFFD9D9D9);

const _image = 'assets/images/onboarding1.png';
const _title = 'Resep Bergizi Harian';
const _desc =
    'Ratusan ide resep MPASI dan makanan bergizi yang mudah diikuti, siap mendukung tumbuh kembang si Kecil setiap hari.';

const _total = 4;

// Animasi geser antar halaman onboarding
const _pageDuration = Duration(milliseconds: 400);
const _pageCurve = Curves.fastOutSlowIn;

// Dipakai hanya untuk keluar dari onboarding ke halaman Register
Route<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(
                parent: anim,
                curve: Curves.fastOutSlowIn,
                reverseCurve: Curves.fastOutSlowIn,
              )),
          child: child,
        );
      },
    );

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= _total) return;
    setState(() => _current = index);
    _controller.animateToPage(
      index,
      duration: _pageDuration,
      curve: _pageCurve,
    );
  }

  void _toRegister() {
    Navigator.of(context).pushReplacement(_slide(const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 393;
    final sy = size.height / 852;

    final isLast = _current == _total - 1;
    final showBack = _current > 0 && !isLast;

    // Saat pindah ke Register, halaman ini keluar ke kiri
    final secondary = ModalRoute.of(context)?.secondaryAnimation ??
        const AlwaysStoppedAnimation(0.0);

    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0))
          .animate(CurvedAnimation(
            parent: secondary,
            curve: Curves.fastOutSlowIn,
          )),
      child: Scaffold(
        backgroundColor: _kRed,
        body: Stack(
          children: [
            // ===== ISI HALAMAN (yang bergeser) =====
            PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _Onboarding1Content(),
                Onboarding2Page(),
                Onboarding3Page(),
                Onboarding4Page(),
              ],
            ),

            // ===== LAPISAN TETAP (tidak ikut bergeser) =====

            // TOMBOL LEWATI (hilang di halaman terakhir)
            if (!isLast)
              Positioned(
                top: 65 * sy,
                right: 17.7 * s,
                child: GestureDetector(
                  onTap: _toRegister,
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
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w600,
                        height: 15 / 13,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

            // INDIKATOR DOT (berubah langsung, tanpa animasi)
            Positioned(
              left: 22.21 * s,
              bottom: 45.43 * sy,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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

            // TOMBOL BACK (halaman 2 dan 3)
            if (showBack)
              Positioned(
                right: 71.68 * s,
                bottom: 25.24 * sy,
                child: GestureDetector(
                  onTap: () => _goTo(_current - 1),
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

            // TOMBOL NEXT (halaman terakhir jadi "Mulai")
            Positioned(
              right: 18.15 * s,
              bottom: 25.24 * sy,
              child: GestureDetector(
                onTap: isLast ? _toRegister : () => _goTo(_current + 1),
                child: isLast
                    ? Container(
                        width: 83.23 * s,
                        height: 50.47 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kMulaiBg,
                          borderRadius: BorderRadius.circular(31.8075 * s),
                        ),
                        child: Text(
                          'Mulai',
                          style: GoogleFonts.inter(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w600,
                            height: 15 / 13,
                            color: _kMulaiText,
                          ),
                        ),
                      )
                    : Container(
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

// ================= ISI HALAMAN 1 =================
class _Onboarding1Content extends StatelessWidget {
  const _Onboarding1Content();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 393;
    final sy = size.height / 852;

    return Stack(
      children: [
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
      ],
    );
  }
}