import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../onboarding/onboarding1.dart';

/// Ukuran frame desain (Figma)
const double kW = 393;
const double kH = 852;
const double kCy = 426; // pusat vertikal

enum SplashStage { blank, dotCenter, kecil, besar, forkspoon, wink, melet, text }

// Skala dari wajah besar: 165 / 663
const double kScale = 165 / 663;

// ==========================================
// PENGATURAN UKURAN & POSISI TEKS (SIMPASI)
// ==========================================
const double kTextVisibleW = 148.0; // Lebar teks SiMPASI yang terlihat di layar
const double kTextCx = kW / 2 + 3.0; // Pusat horizontal teks di atas kepala bayi
const double kTextCy = 352.0; // Pusat vertikal teks tepat di atas kepala bayi
// ==========================================

// Menyimpan ukuran asli gambar & batas piksel yang tidak transparan
class _ImgBounds {
  final double iw, ih;
  final double minX, minY, bw, bh;
  const _ImgBounds({
    required this.iw,
    required this.ih,
    required this.minX,
    required this.minY,
    required this.bw,
    required this.bh,
  });
}

Rect _centered(double w, double h, [double cy = kCy]) =>
    Rect.fromLTWH((kW - w) / 2, cy - h / 2, w, h);

Rect _px(double pxW, double pxH, [double cy = kCy]) =>
    _centered(pxW * kScale, pxH * kScale, cy);

const List<String> _allAssets = [
  'assets/images/start-dot1.png',
  'assets/images/start-face.png',
  'assets/images/start-face-forkspoon.png',
  'assets/images/start-wink.png',
  'assets/images/start-wink-melet.png',
  'assets/images/SiMPASI.png',
];

/// Spring "Bouncy" bawaan Figma: stiffness 600, damping 15, mass 1.
class FigmaSpring extends Curve {
  final double stiffness;
  final double damping;
  final double mass;
  final double seconds;

  const FigmaSpring({
    this.stiffness = 600,
    this.damping = 15,
    this.mass = 1,
    required this.seconds,
  });

  @override
  double transformInternal(double t) {
    if (t >= 1) return 1;
    final time = t * seconds;
    final w0 = math.sqrt(stiffness / mass);
    final zeta = damping / (2 * math.sqrt(stiffness * mass));
    final wd = w0 * math.sqrt(1 - zeta * zeta);
    final env = math.exp(-zeta * w0 * time);
    return 1 -
        env * (math.cos(wd * time) + (zeta * w0 / wd) * math.sin(wd * time));
  }
}

class _Step {
  final SplashStage stage;
  final int delayMs;
  final int durationMs;
  final Curve curve;
  final bool dissolve;
  const _Step(
    this.stage,
    this.delayMs,
    this.durationMs,
    this.curve, {
    this.dissolve = false,
  });
}

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _bouncy = FigmaSpring(seconds: 0.8);

  static const List<_Step> _timeline = [
    _Step(SplashStage.dotCenter, 300, 800, _bouncy),
    _Step(SplashStage.kecil, 300, 300, Curves.easeOut, dissolve: true),
    _Step(SplashStage.besar, 300, 800, _bouncy),
    _Step(SplashStage.forkspoon, 300, 300, Curves.easeInOut, dissolve: true),
    _Step(SplashStage.wink, 200, 200, Curves.easeOut),
    _Step(SplashStage.melet, 200, 300, Curves.easeOut),
    _Step(SplashStage.text, 300, 800, _bouncy),
  ];

  final Map<String, _ImgBounds> _bounds = {};
  SplashStage _stage = SplashStage.blank;
  _Step? _current;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _preloadAndRun();
  }

  // Mengukur area piksel yang benar-benar terlihat (tidak transparan) pada PNG
  Future<_ImgBounds?> _measureAsset(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final bytes = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bytes == null) return null;

      final w = img.width;
      final h = img.height;
      int minX = w, minY = h, maxX = -1, maxY = -1;
      for (int y = 0; y < h; y++) {
        final rowOffset = y * w * 4;
        for (int x = 0; x < w; x++) {
          final a = bytes.getUint8(rowOffset + x * 4 + 3);
          if (a > 16) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }
      img.dispose();
      codec.dispose();
      if (maxX < 0) return null;

      return _ImgBounds(
        iw: w.toDouble(),
        ih: h.toDouble(),
        minX: minX.toDouble(),
        minY: minY.toDouble(),
        bw: (maxX - minX + 1).toDouble(),
        bh: (maxY - minY + 1).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  // Menghitung Rect kanvas penuh agar gambar yang terlihat (non-transparan)
  // tampil dengan lebar & posisi yang presisi meskipun kanvas PNG-nya berbeda-beda
  Rect _rectForVisible(
    String assetPath, {
    required double visibleWidth,
    required double cx,
    double? cy,
    double? topY,
    required Rect fallback,
  }) {
    final b = _bounds[assetPath];
    if (b == null) return fallback;

    final scale = visibleWidth / b.bw;
    final canvasW = b.iw * scale;
    final canvasH = b.ih * scale;

    final visibleLeft = cx - visibleWidth / 2;
    final visibleTop = topY ?? ((cy ?? kCy) - (b.bh * scale) / 2);

    final canvasLeft = visibleLeft - b.minX * scale;
    final canvasTop = visibleTop - b.minY * scale;

    return Rect.fromLTWH(canvasLeft, canvasTop, canvasW, canvasH);
  }

  Future<void> _preloadAndRun() async {
    await Future.wait([
      for (final a in _allAssets) precacheImage(AssetImage(a), context),
    ]);
    for (final a in _allAssets) {
      final b = await _measureAsset(a);
      if (b != null) _bounds[a] = b;
    }
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _run();
  }

  Future<void> _run() async {
    for (final step in _timeline) {
      await Future.delayed(Duration(milliseconds: step.delayMs));
      if (!mounted) return;
      setState(() {
        _current = step;
        _stage = step.stage;
      });
      await Future.delayed(Duration(milliseconds: step.durationMs));
      if (!mounted) return;
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Jika ada callback onFinished dari luar, panggil; jika tidak, langsung ke OnboardingPage
    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, _, _) => const OnboardingPage(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ukuran & posisi masing-masing tahap
    final dotBlankRect = _centered(50, 50, kH + 25);
    final dotCenterRect = _centered(50, 50, kCy);

    final kecilRect = _rectForVisible(
      'assets/images/start-face.png',
      visibleWidth: 317 * kScale,
      cx: kW / 2,
      cy: kCy,
      fallback: _px(317, 211),
    );

    final besarRect = _rectForVisible(
      'assets/images/start-face.png',
      visibleWidth: 663 * kScale,
      cx: kW / 2,
      cy: kCy,
      fallback: _px(663, 442),
    );

    // Titik atas kepala bayi pada stage "besar" dijadikan patokan kunci
    // agar kepala bayi di forkspoon, wink, dan melet 100% sejajar dan sama besar
    final faceBounds = _bounds['assets/images/start-face.png'];
    final headTopY = faceBounds != null
        ? besarRect.top + faceBounds.minY * (besarRect.width / faceBounds.iw)
        : _px(663, 442).top;

    final Rect mainRect;
    if (_stage == SplashStage.blank) {
      mainRect = dotBlankRect;
    } else if (_stage == SplashStage.dotCenter) {
      mainRect = dotCenterRect;
    } else if (_stage == SplashStage.kecil) {
      mainRect = kecilRect;
    } else {
      mainRect = besarRect;
    }

    final step = _current;
    final moveDuration = step == null || step.dissolve
        ? Duration.zero
        : Duration(milliseconds: step.durationMs);
    final moveCurve = step?.curve ?? Curves.linear;

    final fade = step == null
        ? Duration.zero
        : Duration(milliseconds: math.min(step.durationMs, 300));

    final Curve fadeCurve =
        (step == null || step.curve is FigmaSpring) ? Curves.easeOut : step.curve;

    final showDot =
        _stage == SplashStage.blank || _stage == SplashStage.dotCenter;
    final showText = _stage == SplashStage.text;

    // Rect untuk teks SiMPASI
    final textTargetRect = _rectForVisible(
      'assets/images/SiMPASI.png',
      visibleWidth: kTextVisibleW,
      cx: kTextCx,
      cy: kTextCy,
      fallback: Rect.fromCenter(
        center: const Offset(kTextCx, kTextCy),
        width: 156.4,
        height: 149.7,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: kW,
            height: kH,
            child: ClipRect(
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    // 1. Dot, kecil, besar
                    AnimatedPositioned(
                      duration: moveDuration,
                      curve: moveCurve,
                      left: mainRect.left,
                      top: mainRect.top,
                      width: mainRect.width,
                      height: mainRect.height,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedOpacity(
                            duration: fade,
                            curve: fadeCurve,
                            opacity: showDot ? 1 : 0,
                            child: Image.asset(
                              'assets/images/start-dot1.png',
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                            ),
                          ),
                          AnimatedOpacity(
                            duration: fade,
                            curve: fadeCurve,
                            opacity: (_stage == SplashStage.kecil ||
                                    _stage == SplashStage.besar)
                                ? 1
                                : 0,
                            child: Image.asset(
                              'assets/images/start-face.png',
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Tulisan SIMPASI: naik dari bawah dengan Bouncy 800ms
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 800),
                      curve: _bouncy,
                      left: textTargetRect.left,
                      top: showText ? textTargetRect.top : kH,
                      width: textTargetRect.width,
                      height: textTargetRect.height,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: showText ? 1 : 0,
                        child: Image.asset(
                          'assets/images/SiMPASI.png',
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),

                    // 3. Sendok+garpu, wink, melet (ukuran & posisi terkunci presisi)
                    for (final l in const [
                      (SplashStage.forkspoon, 'assets/images/start-face-forkspoon.png'),
                      (SplashStage.wink, 'assets/images/start-wink.png'),
                      (SplashStage.melet, 'assets/images/start-wink-melet.png'),
                    ])
                      Builder(
                        builder: (_) {
                          final r = _rectForVisible(
                            l.$2,
                            visibleWidth: 1012 * kScale,
                            cx: kW / 2 + 1.6,
                            topY: headTopY,
                            fallback: _px(1012, 528).shift(const Offset(1.6, 10.7)),
                          );
                          return Positioned.fromRect(
                            rect: r,
                            child: AnimatedOpacity(
                              duration: fade,
                              curve: fadeCurve,
                              opacity: (_stage == l.$1 ||
                                      (l.$1 == SplashStage.melet &&
                                          _stage == SplashStage.text))
                                  ? 1
                                  : 0,
                              child: Image.asset(
                                l.$2,
                                fit: BoxFit.fill,
                                gaplessPlayback: true,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}