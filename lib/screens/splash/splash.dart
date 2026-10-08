import 'package:flutter/material.dart';
import 'package:frontend_simpasi/screens/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Ukuran kotak desain (acuan). Seluruh isi diskalakan ke lebar layar.
  static const double _box = 390;

  // Titik di dalam kotak (y) yang ditaruh tepat di tengah layar.
  static const double _centerY = 68;

  // Lebar tampil tiap gambar di dalam kotak 390
  static const double _wDot = 50;
  static const double _wFace = 166;
  static const double _wUtensil = 261; // forkspoon & wink
  static const double _wMelet = 387; // melet (file asli 892 px)
  static const double _wFinal = 387;

  // Nama file gambar (tanpa .png). Kalau nama file aslimu beda,
  // cukup ubah di sini saja.
  static const String _imgDot = 'start-dot1';
  static const String _imgFace = 'start-face';
  static const String _imgForkSpoon = 'start-face-forkspoon';
  static const String _imgWink = 'start-wink';
  static const String _imgMelet = 'start-wink-melet';
  static const String _imgFinal = 'start-final';

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    _c.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => const Onboarding(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final n in [
      _imgDot,
      _imgFace,
      _imgForkSpoon,
      _imgWink,
      _imgMelet,
      _imgFinal,
    ]) {
      precacheImage(AssetImage('assets/images/$n.png'), context);
    }
  }

  Widget _img(String name, double width) => Image.asset(
        'assets/images/$name.png',
        width: width,
        fit: BoxFit.contain,
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final k = size.width / _box;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = _c.value;

          final rise = _seg(t, 0.02, 0.20); // titik naik dari bawah ke tengah
          final face = _seg(t, 0.22, 0.38);
          final utensil = _seg(t, 0.45, 0.55);
          final wink = _seg(t, 0.62, 0.66);
          final winkmelet = _seg(t, 0.76, 0.80);
          final fin = _seg(t, 0.88, 1.0);

          final top = h / 2 - _centerY * k;

          // Jarak (dalam satuan kotak) dari posisi titik di tengah
          // sampai di bawah layar.
          final dotStartDy = (h - top) / k - 50;
          final dotDy =
              (1 - Curves.easeOutCubic.transform(rise)) * dotStartDy;

          return Stack(
            children: [
              // ===== start-2 sampai start-7 =====
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
                          // Titik pink: naik dari bawah ke tengah
                          Positioned(
                            left: 167,
                            top: 50,
                            child: Opacity(
                              opacity: (1 - face).clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, dotDy),
                                child: _img(_imgDot, _wDot),
                              ),
                            ),
                          ),

                          // Wajah
                          Positioned(
                            left: 110,
                            top: 20,
                            child: Opacity(
                              opacity: face,
                              child: Transform.scale(
                                scale: 0.3 +
                                    0.7 * Curves.easeOutBack.transform(face),
                                child: _img(_imgFace, _wFace),
                              ),
                            ),
                          ),

                          // Garpu & sendok
                          Positioned(
                            left: 63,
                            top: 20,
                            child: Opacity(
                              opacity: utensil,
                              child: _img(_imgForkSpoon, _wUtensil),
                            ),
                          ),

                          // Kedip
                          Positioned(
                            left: 63,
                            top: 20,
                            child: Opacity(
                              opacity: wink,
                              child: _img(_imgWink, _wUtensil),
                            ),
                          ),

                          // Lidah
                          Positioned(
                            left: -1,
                            top: -1,
                            child: Opacity(
                              opacity: winkmelet,
                              child: _img(_imgMelet, _wMelet),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ===== start-8 (final) =====
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
                          left: -3,
                          top: -75,
                          child: Opacity(
                            opacity: fin,
                            child: _img(_imgFinal, _wFinal),
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