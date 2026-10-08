import 'package:flutter/material.dart';

import '../../widgets/bottom_nav.dart';
import '../../widgets/recipe_store.dart';
import '../home/home_ibu_screen.dart';
import '../menu/menu_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../profil/profil_screen.dart';
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

class KoleksiScreen extends StatelessWidget {
  const KoleksiScreen({super.key});

  static const Color primaryRed  = Color(0xFFD45060);
  static const Color bgPeachSoft = Color(0x80FCEBD5);
  static const Color badgeYellow = Color(0xFFFFB636);
  static const Color textGrey    = Color(0xFF8F8F8F);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textBlack50 = Color(0x80000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color fireOrange  = Color(0xFFFF8F1F);
  static const Color heartRed    = Color(0xFFDD2E44);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: RecipeStore.favorites,
                    builder: (_, favs, __) {
                      final items = RecipeStore.all
                          .where((r) => favs.contains(r.title))
                          .toList();

                      if (items.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(39, 24, 39, 140),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 33,
                          crossAxisSpacing: 24,
                          childAspectRatio: 144 / 186,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _buildCard(items[i]),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ================= BOTTOM NAV =================
            BottomNav(
              currentIndex: 0,
              onTap: (i) {
                if (i == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MenuScreen()),
                  );
                } else if (i == 2) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeIbuScreen()),
                    );
                  }
                } else if (i == 3) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RiwayatScreen()),
                  );
                } else if (i == 4) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: bgPeachSoft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.menu_book_outlined,
                size: 60,
                color: primaryRed,
              ),
            ),
          ),
          const SizedBox(height: 23),
          Text(
            'Belum Ada Koleksi',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 22 / 18,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Yuk, simpan resep MPASI favorit di sini!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textBlack50,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 29),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              );
            },
            child: Container(
              width: 191,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Jelajahi Menu',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 21 / 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      height: topPad + 144,
      decoration: const BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: topPad + 20,
            left: 28,
            right: 16,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Text(
                    'Koleksi Saya',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 32 / 24,
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
          Positioned(
            top: topPad + 80,
            left: 28,
            right: 28,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 22),
                  const Icon(Icons.search, size: 16, color: textBlack71),
                  const SizedBox(width: 12),
                  Text(
                    'Cari di Koleksi',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textBlack50,
                      height: 15 / 12,
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

  // ================= KARTU RESEP =================
  Widget _buildCard(RecipeItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: textGrey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(9.5, 14, 9.5, 0),
            child: AspectRatio(
              aspectRatio: 125 / 123,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item.imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: textGrey,
                        child: const Icon(Icons.fastfood, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    left: 6,
                    child: Container(
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeYellow,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        item.badge,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 12 / 10,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => RecipeStore.toggle(item.title),
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(
                        Icons.favorite,
                        color: heartRed,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 8, 9, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: textBlack,
                    height: 12 / 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: fireOrange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '320 kkal',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: textBlack,
                        height: 12 / 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}