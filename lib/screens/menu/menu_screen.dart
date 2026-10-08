import 'package:flutter/material.dart';

import '../../widgets/bottom_nav.dart';
import '../../widgets/filter_menu_sheet.dart';
import '../../widgets/recipe_store.dart';
import '../koleksi/koleksi_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'detail_resep_screen.dart';

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

// ================= DATA MENU =================
class _MenuData {
  final String title;
  final String imagePath;
  final String badge;
  final List<String> ingredients;
  final bool isNew; // 👈 TANDAI MENU BARU

  const _MenuData({
    required this.title,
    required this.imagePath,
    required this.badge,
    required this.ingredients,
    this.isNew = false,
  });
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Warna dari Figma
  static const Color primaryRed   = Color(0xFFD45060);
  static const Color bgCream      = Color(0xFFFFF1B5);
  static const Color bgTeal       = Color(0xFF8BDFDD);
  static const Color badgeYellow  = Color(0xFFFFB636);
  static const Color textGrey     = Color(0xFF8F8F8F);
  static const Color textBlack    = Color(0xFF000000);
  static const Color textBlack71  = Color(0xB5000000);
  static const Color textBlack50  = Color(0x80000000);
  static const Color fireOrange   = Color(0xFFFF8F1F);
  static const Color tealDark     = Color(0xFF1A7772);
  static const Color heartRed     = Color(0xFFDD2E44);

  // ================= SEMUA DATA MENU =================
  static const List<_MenuData> _allMenus = [
    _MenuData(
      title: 'Bubur Hati Ayam',
      imagePath: 'assets/images/bubur-hati-ayam.png',
      badge: '9 - 11 Bulan',
      ingredients: ['Ayam'],
    ),
    _MenuData(
      title: 'Kue ubi keju',
      imagePath: 'assets/images/kue-ubi-keju.png',
      badge: '9 - 11 Bulan',
      ingredients: ['Umbi-umbian', 'Telur'],
    ),
    // 👇 Pepaya lumat = menu baru dari kader
    _MenuData(
      title: 'Pepaya lumat',
      imagePath: 'assets/images/pepaya-lumat.png',
      badge: '6 Bulan',
      ingredients: ['Buah'],
      isNew: true,
    ),
    _MenuData(
      title: 'Telur santan pisang',
      imagePath: 'assets/images/telur-santan-pisang.png',
      badge: '9 - 11 Bulan',
      ingredients: ['Telur', 'Buah'],
    ),
    _MenuData(
      title: 'Tahu ayam wortel',
      imagePath: 'assets/images/tahu-ayam-wortel.png',
      badge: '7 - 8 Bulan',
      ingredients: ['Ayam', 'Sayuran'],
    ),
    _MenuData(
      title: 'Egg potato mash',
      imagePath: 'assets/images/egg-potato-mash.png',
      badge: '12+ Bulan',
      ingredients: ['Telur', 'Umbi-umbian'],
    ),
  ];

  static const Set<String> _rekomendasiTitles = {
    'Bubur Hati Ayam',
    'Kue ubi keju',
  };

  // ================= STATE FILTER =================
  String _filterAge = 'Semua';
  List<String> _filterIngredients = [];

  bool get _isFilterActive =>
      _filterAge != 'Semua' || _filterIngredients.isNotEmpty;

  String _normAge(String a) => a == '12 Bulan +' ? '12+ Bulan' : a;
  String _normIng(String s) => s.replaceAll('\n', '').trim();

  List<_MenuData> get _filteredMenus {
    return _allMenus.where((m) {
      if (_filterAge != 'Semua' && _normAge(_filterAge) != m.badge) {
        return false;
      }
      if (_filterIngredients.isNotEmpty) {
        final wanted = _filterIngredients.map(_normIng).toSet();
        final hit = m.ingredients.any((i) => wanted.contains(_normIng(i)));
        if (!hit) return false;
      }
      return true;
    }).toList();
  }

  List<_MenuData> get _gridMenus {
    final filtered = _filteredMenus;
    if (!_isFilterActive) {
      return filtered
          .where((m) => !_rekomendasiTitles.contains(m.title))
          .toList();
    }
    return filtered;
  }

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
                  _buildHeader(context),
                  if (!_isFilterActive) ...[
                    const SizedBox(height: 18),
                    _buildRecommendationBox(),
                    const SizedBox(height: 36), // 👈 diperbesar untuk kasih ruang badge
                  ] else ...[
                    const SizedBox(height: 22),
                  ],
                  _buildFilteredGrid(),
                  const SizedBox(height: 140),
                ],
              ),
            ),

            // ================= BOTTOM NAV =================
            BottomNav(
              currentIndex: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KoleksiScreen()),
                  );
                } else if (i == 2) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
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

  // ================= GRID =================
  Widget _buildFilteredGrid() {
    final items = _gridMenus;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 60),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 60, color: textGrey),
              const SizedBox(height: 12),
              Text(
                'Tidak ada resep yang cocok',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textGrey,
                  height: 17 / 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coba ubah atau reset filter',
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
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = (i + 1 < items.length) ? items[i + 1] : null;

      // 👇 cek apakah baris ini perlu ruang ekstra (ada badge "Menu Baru")
      final needExtraTop = left.isNew || (right?.isNew ?? false);

      rows.add(
        Padding(
          padding: EdgeInsets.only(
            left: 37,
            right: 37,
            top: needExtraTop ? 14 : 0, // 👈 beri ruang buat badge yang nongol
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuCard(
                title: left.title,
                imagePath: left.imagePath,
                badge: left.badge,
                hasBorder: true,
                isNew: left.isNew,
              ),
              if (right != null)
                _buildMenuCard(
                  title: right.title,
                  imagePath: right.imagePath,
                  badge: right.badge,
                  hasBorder: true,
                  isNew: right.isNew,
                )
              else
                const SizedBox(width: 144),
            ],
          ),
        ),
      );

      if (i + 2 < items.length) {
        rows.add(const SizedBox(height: 31));
      }
    }

    return Column(children: rows);
  }

  // ================= OPEN FILTER SHEET =================
  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const FilterMenuSheet(),
    );

    if (result != null) {
      setState(() {
        _filterAge = (result['age'] as String?) ?? 'Semua';
        _filterIngredients =
            List<String>.from(result['ingredients'] ?? const []);
      });
      debugPrint('Filter aktif → age: $_filterAge, ing: $_filterIngredients');
    }
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: topPad + 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topPad + 190,
              decoration: const BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + 20,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textBlack,
                        height: 29 / 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    'Aisyah',
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
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
          Positioned(
            top: topPad + 106,
            left: 37,
            right: 22,
            child: SizedBox(
              height: 45,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 19),
                          const Icon(Icons.search, size: 16, color: textBlack71),
                          const SizedBox(width: 13),
                          Text(
                            'Mau masak apa hari ini?',
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
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _openFilterSheet,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42,
                          height: 45,
                          decoration: BoxDecoration(
                            color: bgTeal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune, size: 20, color: tealDark),
                        ),
                        if (_isFilterActive)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: primaryRed,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
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

  // ================= KOTAK REKOMENDASI =================
  Widget _buildRecommendationBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 23),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 43),
      decoration: BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekomendasi Menu',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 24 / 20,
            ),
          ),
          const SizedBox(height: 23),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMenuCard(
                title: 'Bubur Hati Ayam',
                imagePath: 'assets/images/bubur-hati-ayam.png',
                badge: '9 - 11 Bulan',
                hasBorder: false,
              ),
              _buildMenuCard(
                title: 'Kue ubi keju',
                imagePath: 'assets/images/kue-ubi-keju.png',
                badge: '9 - 11 Bulan',
                hasBorder: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= KARTU MENU =================
  Widget _buildMenuCard({
    required String title,
    required String imagePath,
    required String badge,
    bool hasBorder = true,
    bool isNew = false,
  }) {
    // Kartu utama (sama seperti sebelumnya)
    final card = GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailResepScreen(
              title: title,
              imagePath: imagePath,
              badge: badge,
            ),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 144,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: hasBorder ? Border.all(color: textGrey, width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(9.5, 14, 9.5, 0),
              child: SizedBox(
                width: 125,
                height: 123,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath,
                        width: 125,
                        height: 123,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 125,
                          height: 123,
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
                          badge,
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
                      child: ValueListenableBuilder<Set<String>>(
                        valueListenable: RecipeStore.favorites,
                        builder: (_, favs, __) {
                          final liked = favs.contains(title);
                          return GestureDetector(
                            onTap: () => RecipeStore.toggle(title),
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                              color: liked ? heartRed : textBlack,
                              size: 20,
                            ),
                          );
                        },
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
                    title,
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
      ),
    );

    // Kalau bukan menu baru → return kartu biasa
    if (!isNew) return card;

    // Kalau menu baru → wrap pakai Stack + badge "⭐ Menu Baru"
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,

        // 👇 Badge "⭐ Menu Baru" — overlap di atas kiri kartu
        Positioned(
          top: -12,
          left: 22,
          child: Container(
            height: 25,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  size: 10,
                  color: primaryRed,
                ),
                const SizedBox(width: 4),
                Text(
                  'Menu Baru',
                  style: GoogleFonts.inter(
                    fontSize: 12.22,
                    fontWeight: FontWeight.w700,
                    color: primaryRed,
                    height: 15 / 12.22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}