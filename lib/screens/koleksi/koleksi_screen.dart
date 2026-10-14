import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/responsive.dart';
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

class KoleksiScreen extends StatefulWidget {
  const KoleksiScreen({super.key});

  @override
  State<KoleksiScreen> createState() => _KoleksiScreenState();
}

class _KoleksiScreenState extends State<KoleksiScreen> {
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color bgPeachSoft = Color(0x80FCEBD5);
  static const Color badgeYellow = Color(0xFFFFB636);
  static const Color textGrey    = Color(0xFF8F8F8F);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textBlack50 = Color(0x80000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color fireOrange  = Color(0xFFFF8F1F);
  static const Color heartRed    = Color(0xFFDD2E44);

  // STATE: kontrol search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                      final allFavorites = RecipeStore.all
                          .where((r) => favs.contains(r.title))
                          .toList();

                      final query = _searchQuery.trim().toLowerCase();
                      final items = query.isEmpty
                          ? allFavorites
                          : allFavorites
                              .where((r) =>
                                  r.title.toLowerCase().contains(query))
                              .toList();

                      if (allFavorites.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      if (items.isEmpty) {
                        return _buildNoResultsState(context);
                      }

                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          context.w(39),
                          context.w(24),
                          context.w(39),
                          context.w(140),
                        ),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: context.w(33),
                          crossAxisSpacing: context.w(24),
                          childAspectRatio: 144 / 186,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _buildCard(context, items[i]),
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

    // ================= EMPTY STATE (Belum Ada Koleksi) =================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.w(120),
            height: context.w(120),
            decoration: const BoxDecoration(
              color: bgPeachSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              // Icon custom dari assets/images, warna ikut primaryRed
              child: SvgPicture.asset(
                'assets/images/menu-book.svg',
                width: context.w(60),
                height: context.w(60),
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: context.w(23)),
          Text(
            'Belum Ada Koleksi',
            style: GoogleFonts.inter(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 22 / 18,
            ),
          ),
          SizedBox(height: context.w(7)),
          Text(
            'Yuk, simpan resep MPASI favorit di sini!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w500,
              color: textBlack50,
              height: 16 / 13,
            ),
          ),
          SizedBox(height: context.w(29)),
          Material(
            color: primaryRed,
            borderRadius: BorderRadius.circular(context.w(30)),
            child: InkWell(
              borderRadius: BorderRadius.circular(context.w(30)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                );
              },
              child: Container(
                width: context.w(191),
                height: context.w(45),
                alignment: Alignment.center,
                child: Text(
                  'Jelajahi Menu',
                  style: GoogleFonts.inter(
                    fontSize: context.sp(17),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 21 / 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= NO RESULTS STATE =================
  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.w(120),
            height: context.w(120),
            decoration: const BoxDecoration(
              color: bgPeachSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.search_off,
                size: context.w(60),
                color: primaryRed,
              ),
            ),
          ),
          SizedBox(height: context.w(23)),
          Text(
            'Tidak Ditemukan',
            style: GoogleFonts.inter(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 22 / 18,
            ),
          ),
          SizedBox(height: context.w(7)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(40)),
            child: Text(
              'Tidak ada resep dengan nama "${_searchQuery.trim()}".\nCoba kata kunci lain.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w500,
                color: textBlack50,
                height: 16 / 13,
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
      height: topPad + context.w(144),
      decoration: BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.w(25)),
          bottomRight: Radius.circular(context.w(25)),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: topPad + context.w(20),
            left: context.w(28),
            right: context.w(16),
            child: SizedBox(
              height: context.w(50),
              child: Row(
                children: [
                  Text(
                    'Koleksi Saya',
                    style: GoogleFonts.inter(
                      fontSize: context.sp(24),
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
          Positioned(
            top: topPad + context.w(80),
            left: context.w(28),
            right: context.w(28),
            child: Container(
              height: context.w(45),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.w(30)),
              ),
              child: Row(
                children: [
                  SizedBox(width: context.w(22)),
                  Icon(Icons.search, size: context.w(16), color: textBlack71),
                  SizedBox(width: context.w(12)),
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
                        hintText: 'Cari di Koleksi',
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
                          horizontal: context.w(16),
                        ),
                        child: Icon(
                          Icons.close,
                          size: context.w(18),
                          color: textBlack71,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: context.w(22)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU RESEP =================
  Widget _buildCard(BuildContext context, RecipeItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: textGrey, width: context.w(1)),
        borderRadius: BorderRadius.circular(context.w(10)),
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
            child: AspectRatio(
              aspectRatio: 125 / 123,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.w(10)),
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
                        item.badge,
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
                    child: GestureDetector(
                      onTap: () => RecipeStore.toggle(item.title),
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.favorite,
                        color: heartRed,
                        size: context.w(20),
                      ),
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
                  item.title,
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
                    Icon(
                      Icons.local_fire_department,
                      size: context.w(12),
                      color: fireOrange,
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
  }
}