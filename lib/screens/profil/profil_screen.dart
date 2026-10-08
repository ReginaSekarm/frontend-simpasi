import 'package:flutter/material.dart';

import '../../widgets/bottom_nav.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/menu_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'edit_profil_screen.dart';
import 'pengaturan_screen.dart'; 
import '../notifikasi/notifikasi_screen.dart';

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

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // Warna dari Figma
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color bgCream     = Color(0xFFFFF1B5);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textGrey    = Color(0xFF8F8F8F);
  static const Color exitRed     = Color(0xFFFF0000);
  static const Color exitBg      = Color(0x1AFF0000); // rgba(255,0,0,0.1)

  // Data dummy user
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
                  const SizedBox(height: 36),
                  _buildMenuCard(context),
                  const SizedBox(height: 115),
                  _buildKeluarButton(context),
                  const SizedBox(height: 100),
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
      height: topPad + 390,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ---- Background merah melengkung ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topPad + 184,
              decoration: const BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          // ---- Title "Profil" + bell ----
          Positioned(
            top: topPad + 20,
            left: 44,
            right: 16,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Text(
                    'Profil',
                    style: GoogleFonts.inter(
                      fontSize: 24,
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
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),

          // ---- Kartu kuning (avatar + nama) ----
          Positioned(
            top: topPad + 120,
            left: 20,
            right: 20,
            child: Container(
              height: 270,
              decoration: BoxDecoration(
                color: bgCream,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatar_profile.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 65,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _nama,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textBlack,
                      height: 29 / 24,
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          border: Border.all(color: textBlack, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            // ---- Edit Profil ----
            _buildMenuItem(
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
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: Container(height: 2, color: textGrey),
            ),

            // ---- Pengaturan → NAVIGASI KE PengaturanScreen ----
            _buildMenuItem(
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

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 82,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              Icon(icon, size: 26, color: textBlack),
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

  // ================= TOMBOL KELUAR =================
  Widget _buildKeluarButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Keluar'),
              content: const Text('Yakin ingin keluar dari akun?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigator ke halaman login
                  },
                  child: const Text(
                    'Keluar',
                    style: TextStyle(color: exitRed),
                  ),
                ),
              ],
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: exitBg,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                size: 22,
                color: exitRed,
              ),
              const SizedBox(width: 8),
              Text(
                'Keluar',
                style: GoogleFonts.inter(
                  fontSize: 20,
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