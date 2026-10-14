import 'package:flutter/material.dart';

import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_store.dart';
import '../../widgets/filter_menu_sheet.dart';
import '../../widgets/initial_avatar.dart';
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
  final bool isNew;

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
  static const Color bgTeal       = Color(0xFF8BDFDD);
  static const Color badgeYellow  = Color(0xFFFFB636);
  static const Color textGrey     = Color(0xFF8F8F8F);
  static const Color textBlack    = Color(0xFF000000);
  static const Color textBlack71  = Color(0xB5000000);
  static const Color textBlack50  = Color(0x80000000);
  static const Color tealDark     = Color(0xFF1A7772);
  static const Color heartRed     = Color(0xFFDD2E44);

  // Warna gradasi border untuk Menu Baru
  static const Color borderGradTop    = Color(0xFFE76D73);
  static const Color borderGradBottom = Color(0xFFFF8F1F);

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

  // STATE SEARCH
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _isFilterActive =>
      _filterAge != 'Semua' || _filterIngredients.isNotEmpty;

  bool get _isSearching => _searchQuery.trim().isNotEmpty;

  String _normAge(String a) => a == '12 Bulan +' ? '12+ Bulan' : a;
  String _normIng(String s) => s.replaceAll('\n', '').trim();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MenuData> get _filteredMenus {
    final query = _searchQuery.trim().toLowerCase();
    return _allMenus.where((m) {
      if (query.isNotEmpty && !m.title.toLowerCase().contains(query)) {
        return false;
      }
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
    if (_isSearching) return filtered;
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
                  if (!_isFilterActive && !_isSearching) ...[
                    SizedBox(height: context.w(18)),
                    _buildRecommendationBox(context),
                    SizedBox(height: context.w(36)),
                  ] else ...[
                    SizedBox(height: context.w(22)),
                  ],
                  _buildFilteredGrid(context),
                  SizedBox(height: context.w(140)),
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
                    Navigator.of(context).popUntil((r) => r.isFirst);
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
  Widget _buildFilteredGrid(BuildContext context) {
    final items = _gridMenus;

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(37),
          vertical: context.w(60),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                _isSearching ? Icons.search_off : Icons.filter_alt_off,
                size: context.w(60),
                color: textGrey,
              ),
              SizedBox(height: context.w(12)),
              Text(
                _isSearching
                    ? 'Resep tidak ditemukan'
                    : 'Tidak ada resep yang cocok',
                style: GoogleFonts.inter(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: textGrey,
                  height: 17 / 14,
                ),
              ),
              SizedBox(height: context.w(4)),
              Text(
                _isSearching
                    ? 'Coba kata kunci lain'
                    : 'Coba ubah atau reset filter',
                style: GoogleFonts.inter(
                  fontSize: context.sp(12),
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

      final needExtraTop = left.isNew || (right?.isNew ?? false);

      rows.add(
        Padding(
          padding: EdgeInsets.only(
            left: context.w(37),
            right: context.w(37),
            top: needExtraTop ? context.w(14) : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuCard(
                context,
                title: left.title,
                imagePath: left.imagePath,
                badge: left.badge,
                hasBorder: true,
                isNew: left.isNew,
              ),
              if (right != null)
                _buildMenuCard(
                  context,
                  title: right.title,
                  imagePath: right.imagePath,
                  badge: right.badge,
                  hasBorder: true,
                  isNew: right.isNew,
                )
              else
                SizedBox(width: context.w(144)),
            ],
          ),
        ),
      );

      if (i + 2 < items.length) {
        rows.add(SizedBox(height: context.w(31)));
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
      height: topPad + context.w(190),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topPad + context.w(190),
              decoration: BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.w(50)),
                  bottomRight: Radius.circular(context.w(50)),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + context.w(20),
            left: context.w(16),
            right: context.w(16),
            child: SizedBox(
              height: context.w(50),
              child: Row(
                children: [
                  const InitialAvatar(initial: 'A'),
                  SizedBox(width: context.w(18)),
                  const Expanded(
                    child: Text(
                      'Aisyah',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 29 / 24,
                      ),
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
                        size: context.w(26),
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(15)),
                ],
              ),
            ),
          ),
          Positioned(
            top: topPad + context.w(106),
            left: context.w(37),
            right: context.w(22),
            child: SizedBox(
              height: context.w(45),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: context.w(45),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.w(30)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: context.w(19)),
                          Icon(
                            Icons.search,
                            size: context.w(16),
                            color: textBlack71,
                          ),
                          SizedBox(width: context.w(13)),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                              style: GoogleFonts.inter(
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.w400,
                                color: textBlack,
                                height: 15 / 12,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Mau masak apa hari ini?',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: context.sp(12),
                                  fontWeight: FontWeight.w400,
                                  color: textBlack50,
                                  height: 15 / 12,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                FocusScope.of(context).unfocus();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(14),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: context.w(18),
                                  color: textBlack71,
                                ),
                              ),
                            )
                          else
                            SizedBox(width: context.w(19)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(6)),
                  GestureDetector(
                    onTap: _openFilterSheet,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: context.w(42),
                          height: context.w(45),
                          decoration: BoxDecoration(
                            color: bgTeal,
                            borderRadius: BorderRadius.circular(context.w(10)),
                          ),
                          child: Icon(
                            Icons.tune,
                            size: context.w(20),
                            color: tealDark,
                          ),
                        ),
                        if (_isFilterActive)
                          Positioned(
                            top: context.w(-2),
                            right: context.w(-2),
                            child: Container(
                              width: context.w(12),
                              height: context.w(12),
                              decoration: BoxDecoration(
                                color: primaryRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: context.w(2),
                                ),
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
  Widget _buildRecommendationBox(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: context.w(23)),
      padding: EdgeInsets.fromLTRB(
        context.w(26),
        context.w(18),
        context.w(26),
        context.w(30),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x80FFD444),
            Color(0xFFFFB636),
          ],
          stops: [0.0, 0.9279],
        ),
        borderRadius: BorderRadius.circular(context.w(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: ChildStore.currentName,
            builder: (_, childName, __) {
              final label = childName.trim().isEmpty
                  ? 'REKOMENDASI'
                  : 'UNTUK ${childName.toUpperCase()}';
              return Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w700,
                  color: primaryRed,
                  height: 17 / 14,
                ),
              );
            },
          ),
          SizedBox(height: context.w(4)),
          Text(
            'Rekomendasi Menu',
            style: GoogleFonts.inter(
              fontSize: context.sp(20),
              fontWeight: FontWeight.w700,
              color: textBlack.withValues(alpha: 0.7),
              height: 24 / 20,
            ),
          ),
          SizedBox(height: context.w(22)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMenuCard(
                context,
                title: 'Bubur Hati Ayam',
                imagePath: 'assets/images/bubur-hati-ayam.png',
                badge: '9 - 11 Bulan',
                hasBorder: false,
              ),
              _buildMenuCard(
                context,
                title: 'Kue Ubi Keju',
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
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required String badge,
    bool hasBorder = true,
    bool isNew = false,
  }) {
    Widget cardBody = Container(
      width: context.w(144),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(10)),
        border: (hasBorder && !isNew)
            ? Border.all(color: textGrey, width: context.w(1))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(9.5),
              context.w(14),
              context.w(9.5),
              0,
            ),
            child: SizedBox(
              width: context.w(125),
              height: context.w(123),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.w(10)),
                    child: Image.asset(
                      imagePath,
                      width: context.w(125),
                      height: context.w(123),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: context.w(125),
                        height: context.w(123),
                        color: textGrey,
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: context.w(7),
                    left: context.w(6),
                    child: Container(
                      height: context.w(16),
                      padding: EdgeInsets.symmetric(horizontal: context.w(8)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeYellow,
                        borderRadius: BorderRadius.circular(context.w(9)),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(10),
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 12 / 10,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: context.w(6),
                    right: context.w(10),
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: RecipeStore.favorites,
                      builder: (_, favs, __) {
                        final liked = favs.contains(title);
                        return GestureDetector(
                          onTap: () => RecipeStore.toggle(title),
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            liked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: liked ? heartRed : textBlack,
                            size: context.w(20),
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
            padding: EdgeInsets.fromLTRB(
              context.w(13),
              context.w(8),
              context.w(9),
              context.w(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w400,
                    color: textBlack,
                    height: 12 / 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.w(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 👇 ICON FIRE dari asset, ukuran tetap
                    Image.asset(
                      'assets/images/icon-fire.png',
                      width: context.w(12),
                      height: context.w(12),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.local_fire_department,
                        size: context.w(12),
                        color: const Color(0xFFFF8F1F),
                      ),
                    ),
                    SizedBox(width: context.w(2)),
                    Text(
                      '320 kkal',
                      style: GoogleFonts.inter(
                        fontSize: context.sp(10),
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

    // KARTU BIASA
    if (!isNew) {
      return GestureDetector(
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
        child: cardBody,
      );
    }

    // KARTU MENU BARU — dengan BORDER GRADASI
    return GestureDetector(
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(1.5)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [borderGradTop, borderGradBottom],
              ),
              borderRadius: BorderRadius.circular(context.w(11.5)),
            ),
            child: cardBody,
          ),
          Positioned(
            top: context.w(-12),
            left: context.w(22),
            child: Container(
              height: context.w(25),
              padding: EdgeInsets.symmetric(horizontal: context.w(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.w(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: context.w(10),
                    color: primaryRed,
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    'Menu Baru',
                    style: GoogleFonts.inter(
                      fontSize: context.sp(12.22),
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
      ),
    );
  }
}