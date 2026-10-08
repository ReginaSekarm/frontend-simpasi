import 'package:flutter/material.dart';

class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

class TentangKamiScreen extends StatelessWidget {
  const TentangKamiScreen({super.key});

  // Warna dari Figma
  static const Color primaryRed = Color(0xFFD45060);
  static const Color textBlack  = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= HEADER =================
            Padding(
              padding: EdgeInsets.fromLTRB(15, topPad + 60, 15, 0),
              child: SizedBox(
                height: 32,
                child: Stack(
                  children: [
                    // Back arrow
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.chevron_left,
                            size: 32,
                            color: textBlack,
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Center(
                      child: Text(
                        'Tentang Kami',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textBlack,
                          height: 29 / 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 31),

            // ================= ILLUSTRATION =================
            // Cukup pakai gambar tentang-kami.png
            // (gambar sudah include starburst + maskot + mangkuk)
            Center(
              child: Image.asset(
                'assets/images/tentang-kami.png',
                width: 300,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 300,
                  height: 200,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= APP NAME =================
            Center(
              child: Text(
                'SiMPASI',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: textBlack,
                  height: 44 / 36,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ================= TAGLINE =================
            Center(
              child: Text(
                'Sistem Informasi Mencegah Stunting · Versi 1.0.0',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textBlack,
                  height: 15 / 12,
                ),
              ),
            ),

            const SizedBox(height: 29),

            // ================= TENTANG APLIKASI =================
            Center(
              child: Text(
                'TENTANG APLIKASI',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryRed,
                  height: 15 / 12,
                ),
              ),
            ),

            const SizedBox(height: 11),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'SiMpasi (Sistem Informasi Mencegah Stunting) adalah platform '
                'digital yang menyediakan panduan resep makanan bergizi, '
                'rekomendasi menu MPASI berbasis AI sesuai bahan yang '
                'tersedia, profil tumbuh kembang bayi, serta forum diskusi '
                'antarpengguna untuk mencegah risiko gagal tumbuh pada balita.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textBlack,
                  height: 17 / 14,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ================= MISI KAMI =================
            Center(
              child: Text(
                'MISI KAMI',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryRed,
                  height: 15 / 12,
                ),
              ),
            ),

            const SizedBox(height: 11),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Membantu setiap orang tua dan kader posyandu di Indonesia '
                'mencegah risiko stunting pada balita, dengan cara yang '
                'mudah, terstruktur, dan berbasis komunitas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textBlack,
                  height: 17 / 14,
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}