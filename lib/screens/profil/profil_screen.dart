import 'package:flutter/material.dart';

import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/menu_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'edit_profil_screen.dart';
import 'pengaturan_screen.dart';
import '../notifikasi/notifikasi_screen.dart';

// Mock GoogleFonts (Jika kamu menggunakan package google_fonts asli, hapus class ini dan import package-nya)
class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Inter', // Tambahkan ini agar font Inter terbaca
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // Warna dari Figma
  static const Color primaryRed   = Color(0xFFD45060);
  static const Color bgCream      = Color(0xFFFCEBD5);
  static const Color textBlack    = Color(0xFF000000);
  static const Color textGrey     = Color(0xFF8F8F8F);
  static const Color textBrown    = Color(0xFF9E5665);
  static const Color exitRed      = Color(0xFFFF0000);
  static const Color exitBg       = Color(0x1AFF0000);

  String _nama = 'Aisyah';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopSection(context),
                  SizedBox(height: context.w(93)),
                  _buildMenuCard(context),
                  SizedBox(height: context.w(115)),
                  _buildKeluarButton(context),
                  SizedBox(height: context.w(100)), // Space untuk bottom nav
                ],
              ),
            ),

            // ================= BOTTOM NAV =================
            BottomNav(
              currentIndex: 4,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KoleksiScreen()),
                  );
                } else if (i == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MenuScreen()),
                  );
                } else if (i == 2) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                } else if (i == 3) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RiwayatScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOP SECTION =================
  Widget _buildTopSection(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: topPad + context.w(290),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ---- Background merah melengkung ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topPad + context.w(200),
              decoration: BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.w(50)),
                  bottomRight: Radius.circular(context.w(50)),
                ),
              ),
            ),
          ),

          // ---- Title "Profil" + bell ----
          Positioned(
            top: topPad + context.w(20),
            left: context.w(44),
            right: context.w(16),
            child: SizedBox(
              height: context.w(40),
              child: Row(
                children: [
                  Text(
                    'Profil',
                    style: GoogleFonts.inter(
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 29 / 24,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(context.w(4)),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: context.w(25),
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(15)),
                ],
              ),
            ),
          ),

          // ---- Kartu putih (nama + badge) ----
          Positioned(
            top: topPad + context.w(109),
            left: context.w(23),
            right: context.w(23),
            child: Container(
              height: context.w(180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.w(25)),
                boxShadow: [
                  BoxShadow(
                    color: textBlack.withValues(alpha: 0.25),
                    blurRadius: context.w(4),
                    offset: Offset(0, context.w(4)),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: context.w(40)),
                  Text(
                    _nama,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w700,
                      color: textBlack,
                      height: 29 / 24,
                    ),
                  ),
                  SizedBox(height: context.w(8)),
                  Container(
                    width: context.w(108),
                    height: context.w(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgCream,
                      borderRadius: BorderRadius.circular(context.w(20)),
                    ),
                    child: Text(
                      'Orang Tua',
                      style: GoogleFonts.inter(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w700,
                        color: primaryRed,
                        height: 17 / 14,
                      ),
                    ),
                  ),
                  SizedBox(height: context.w(16)),
                ],
              ),
            ),
          ),

          // ---- Avatar "A" (overlap atas kartu putih) ----
          Positioned(
            top: topPad + context.w(58),
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: context.w(102),
                height: context.w(102),
                decoration: const BoxDecoration(
                  color: bgCream,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'A',
                  style: GoogleFonts.inter(
                    fontSize: context.sp(49),
                    fontWeight: FontWeight.w700,
                    color: textBrown,
                    height: 59 / 49,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU MENU =================
  Widget _buildMenuCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          border: Border.all(color: textBlack, width: context.w(1)),
          borderRadius: BorderRadius.circular(context.w(30)),
        ),
        child: Column(
          children: [
            // ---- Edit Profil ----
            _buildMenuItem(
              context,
              icon: Icons.account_circle,
              label: 'Edit profil',
              onTap: () async {
                final result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => EditProfilScreen(namaLengkap: _nama),
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  setState(() => _nama = result);
                }
              },
            ),

            // Divider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(27)),
              child: Container(height: context.w(1.5), color: textGrey),
            ),

            // ---- Pengaturan ----
            _buildMenuItem(
              context,
              icon: Icons.settings,
              label: 'Pengaturan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PengaturanScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: context.w(83),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(28)),
          child: Row(
            children: [
              Icon(icon, size: context.w(26), color: textBlack),
              SizedBox(width: context.w(15)),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.w500,
                    color: textBlack,
                    height: 22 / 18,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: context.w(26),
                color: textBlack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOMBOL KELUAR (DIPERBAIKI) =================
  Widget _buildKeluarButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: GestureDetector(
        onTap: () {
          // ================= POPUP KONFIRMASI KUSTOM SESUAI FIGMA =================
          showDialog(
            context: context,
            barrierDismissible: true, // Klik di luar popup untuk menutup
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent, // Menghilangkan background bawaan dialog
              elevation: 0,
              child: Container(
                width: context.w(259), // Lebar sesuai Figma (259px)
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(32), 
                  vertical: context.w(30)
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.w(10)), // Radius 10px
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Judul Popup
                    Text(
                      'Keluar',
                      style: GoogleFonts.inter(
                        fontSize: context.sp(17.76),
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withValues(alpha: 0.71),
                      ),
                    ),
                    SizedBox(height: context.w(15)),
                    
                    // Deskripsi Popup
                    Text(
                      'Yakin ingin keluar dari akun?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(13.32),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8F8F8F),
                        height: 16 / 13.32,
                      ),
                    ),
                    SizedBox(height: context.w(25)),
                    
                    // Tombol Aksi (Batal & Keluar)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Batal
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: context.w(92.5),
                            height: context.w(29.6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(context.w(11.02)),
                            ),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.inter(
                                fontSize: context.sp(13.32),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8F8F8F),
                              ),
                            ),
                          ),
                        ),
                        
                        // Tombol Keluar
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Tambahkan logika navigasi ke halaman login di sini
                          },
                          child: Container(
                            width: context.w(92.5),
                            height: context.w(29.6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0020), // Warna merah sesuai Figma
                              borderRadius: BorderRadius.circular(context.w(11.02)),
                            ),
                            child: Text(
                              'Keluar',
                              style: GoogleFonts.inter(
                                fontSize: context.sp(13.32),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          // ========================================================================
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: context.w(50),
          decoration: BoxDecoration(
            color: exitBg,
            borderRadius: BorderRadius.circular(context.w(15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                size: context.w(24),
                color: exitRed,
              ),
              SizedBox(width: context.w(8)),
              Text(
                'Keluar',
                style: GoogleFonts.inter(
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w500,
                  color: exitRed,
                  height: 24 / 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}