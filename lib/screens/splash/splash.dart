import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../onboarding/onboarding1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  static const double _box = 390;
  static const double _centerY = 68;

  // Lebar = lebar kanvas asli tiap file (jangan diubah, nanti ukurannya meleset)
  static const double _wDot = 50;
  static const double _wFace = 166;
  static const double _wUtensil = 261; // forkspoon & wink
  static const double _wBig = 387; // melet & final

  // Nama file (tanpa ekstensi)
  static const String _imgDot = 'start-dot1';
  static const String _imgFace = 'start-face';
  static const String _imgForkSpoon = 'start-face-forkspoon';
  static const String _imgWink = 'start-wink';
  static const String _imgMelet = 'start-wink-melet';
  static const String _imgFinal = 'start-final';

  // Posisi dihitung dari posisi kepala di tiap kanvas SVG,
  // supaya semua kepala jatuh di titik yang sama (x=123.3, y=20.3).
  static const double _faceLeft = 113;
  static const double _faceTop = 20;

  static const double _utensilLeft = 63; // forkspoon & wink
  static const double _utensilTop = 20;

  static const double _meletLeft = 0;
  static const double _meletTop = -5.7;

  static const double _finalLeft = 0.2;
  static const double _finalTop = -77;

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadAndStart());
  }

  Future<void> _preloadAndStart() async {
    // Preload SVG. Kalau gagal, animasi tetap jalan.
    try {
      for (final n in [
        _imgFace,
        _imgForkSpoon,
        _imgWink,
        _imgMelet,
        _imgFinal,
      ]) {
        final loader = SvgAssetLoader('assets/images/$n.svg');
        await svg.cache
            .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
      }
    } catch (e) {
      debugPrint('❌ Preload SVG gagal: $e');
    }

    // Preload PNG (titik pink)
    if (!mounted) return;
    try {
      await precacheImage(
        const AssetImage('assets/images/$_imgDot.png'),
        context,
      );
    } catch (e) {
      debugPrint('❌ Preload PNG gagal: $e');
    }
    if (!mounted) return;

    setState(() => _ready = true);

    await _c.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const OnboardingPage(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  // Tahap lama tetap terlihat selama tahap baru memudar di atasnya,
  // lalu disembunyikan begitu tahap baru sudah penuh. Tidak ada tumpukan.
  double _stage(double own, double next) => next >= 1.0 ? 0.0 : own;

  Widget _svg(String name, double width) {
    final path = 'assets/images/$name.svg';
    return SvgPicture.asset(
      path,
      width: width,
      fit: BoxFit.contain,
      clipBehavior: Clip.none,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ SVG gagal load: $path → $error');
        return SizedBox(width: width, height: width);
      },
    );
  }

  Widget _png(String name, double width) {
    final path = 'assets/images/$name.png';
    return Image.asset(
      path,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        debugPrint('❌ PNG gagal load: $path');
        return SizedBox(width: width, height: width);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final k = size.width / _box;

    return Scaffold(
      backgroundColor: Colors.white,
      body: !_ready
          ? const SizedBox.expand()
          : AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                final t = _c.value;

                final rise = _seg(t, 0.02, 0.20);
                final face = _seg(t, 0.22, 0.38);
                final utensil = _seg(t, 0.45, 0.55);
                final wink = _seg(t, 0.62, 0.66);
                final winkmelet = _seg(t, 0.76, 0.80);
                final fin = _seg(t, 0.88, 1.0);

                final top = h / 2 - _centerY * k;

                final dotStartDy = (h - top) / k - 50;
                final dotDy =
                    (1 - Curves.easeOutCubic.transform(rise)) * dotStartDy;

                return Stack(
                  children: [
                    // ===== tahap 1 sampai 5 =====
                    Positioned(
                      top: top,
                      left: 0,
                      right: 0,
                      height: _box * k,
                      child: Opacity(
                        opacity: 1 - fin,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _box,
                            height: _box,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Titik pink (naik dari bawah ke tengah)
                                Positioned(
                                  left: 167,
                                  top: 50,
                                  child: Opacity(
                                    opacity: (1 - face).clamp(0.0, 1.0),
                                    child: Transform.translate(
                                      offset: Offset(0, dotDy),
                                      child: _png(_imgDot, _wDot),
                                    ),
                                  ),
                                ),

                                // Wajah
                                Positioned(
                                  left: _faceLeft,
                                  top: _faceTop,
                                  child: Opacity(
                                    opacity: _stage(face, utensil),
                                    child: Transform.scale(
                                      scale: 0.3 +
                                          0.7 *
                                              Curves.easeOutBack
                                                  .transform(face),
                                      child: _svg(_imgFace, _wFace),
                                    ),
                                  ),
                                ),

                                // Garpu & sendok
                                Positioned(
                                  left: _utensilLeft,
                                  top: _utensilTop,
                                  child: Opacity(
                                    opacity: _stage(utensil, wink),
                                    child: _svg(_imgForkSpoon, _wUtensil),
                                  ),
                                ),

                                // Kedip
                                Positioned(
                                  left: _utensilLeft,
                                  top: _utensilTop,
                                  child: Opacity(
                                    opacity: _stage(wink, winkmelet),
                                    child: _svg(_imgWink, _wUtensil),
                                  ),
                                ),

                                // Lidah (kanvas 387, posisi dihitung supaya
                                // kepalanya sejajar dengan kedip)
                                Positioned(
                                  left: _meletLeft,
                                  top: _meletTop,
                                  child: Opacity(
                                    opacity: winkmelet,
                                    child: _svg(_imgMelet, _wBig),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ===== final (kepala sejajar dengan lidah) =====
                    Positioned(
                      top: top,
                      left: 0,
                      right: 0,
                      height: _box * k,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _box,
                          height: _box,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: _finalLeft,
                                top: _finalTop,
                                child: Opacity(
                                  opacity: fin,
                                  child: _svg(_imgFinal, _wBig),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}