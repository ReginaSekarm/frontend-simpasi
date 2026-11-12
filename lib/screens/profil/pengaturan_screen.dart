import 'package:flutter/material.dart';
import 'ganti_kata_sandi.dart';
import 'pusat_bantuan_screen.dart';
import 'tentang_kami_screen.dart';

class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  // Warna dari Figma
  static const Color textBlack   = Color(0xFF000000);
  static const Color dividerGrey = Color(0xFF8F8F8F);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER =================
          _buildHeader(topPad),

          const SizedBox(height: 46),

          // ================= KARTU MENU =================
          _buildMenuCard(),

          const Spacer(),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(double topPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, topPad + 60, 15, 0),
      child: SizedBox(
        height: 32,
        child: Stack(
          children: [
            // Back arrow (kiri)
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

            // Title (tengah)
            Center(
              child: Text(
                'Pengaturan',
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
    );
  }

  // ================= KARTU MENU =================
  Widget _buildMenuCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          border: Border.all(color: textBlack, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.lock_outline,
              label: 'Ganti Kata Sandi',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GantiKataSandiScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),

            _buildMenuItem(
              icon: Icons.help_outline,
              label: 'Pusat Bantuan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PusatBantuanScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),

            _buildMenuItem(
              icon: Icons.info_outline,
              label: 'Tentang Kami',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TentangKamiScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Container(height: 2, color: dividerGrey),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 86,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              Icon(icon, size: 24, color: textBlack),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textBlack,
                    height: 22 / 18,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 26,
                color: textBlack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}