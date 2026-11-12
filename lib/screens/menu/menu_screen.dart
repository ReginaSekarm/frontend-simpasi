import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_text.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_store.dart';
import '../../widgets/filter_menu_sheet.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/menu_recommendation_card.dart';
import '../../widgets/notification_icon.dart'; 
import '../koleksi/koleksi_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import '../riwayat/riwayat_screen.dart';

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
  final List<String>? initialIngredients;
  final bool fromPemeriksaan;

  const MenuScreen({
    super.key,
    this.initialIngredients,
    this.fromPemeriksaan = false,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Warna dari Figma
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color bgPeachSoft = Color(0x80FCEBD5);
  static const Color bgTeal      = Color(0xFF8BDFDD);
  static const Color badgeYellow = Color(0xFFFFB636);
  static const Color textGrey    = Color(0xFF8F8F8F);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color textBlack50 = Color(0x80000000);
  static const Color tealDark    = Color(0xFF1A7772);

  // ================= DATA =================
  static const List<_MenuData> _allMenus = [
    _MenuData(
      title: 'Bubur Hati Ayam',
      imagePath: 'assets/images/bubur-hati-ayam.png',
      badge: '9 - 11 Bulan',
      ingredients: ['Ayam'],
    ),
    _MenuData(
      title: 'Kue Ubi Keju',
      imagePath: 'assets/images/kue-ubi-keju.png',
      badge: '9 - 11 Bulan',
      ingredients: ['Umbi-umbian', 'Telur'],
    ),
    _MenuData(
      title: 'Pepaya Lumat',
      imagePath: 'assets/images/pepaya-lumat.png',
      badge: '6 Bulan',
      ingredients: ['Buah'],
      isNew: true,
    ),
    _MenuData(
      title: 'Telur Santan Pisang',
      imagePath: 'assets/images/telur-santan-pisang.png',
      badge: '9 - 11 Bulan',
      ingredients: ['Telur', 'Buah'],
    ),
    _MenuData(
      title: 'Tahu Ayam Wortel',
      imagePath: 'assets/images/tahu-ayam-wortel.png',
      badge: '7 - 8 Bulan',
      ingredients: ['Ayam', 'Sayuran'],
    ),
    _MenuData(
      title: 'Egg Potato Mash',
      imagePath: 'assets/images/egg-potato-mash.png',
      badge: '12+ Bulan',
      ingredients: ['Telur', 'Umbi-umbian'],
    ),
  ];

  static const List<_MenuData> _recommended = [
    _MenuData(
      title: 'Bubur Hati Ayam',
      imagePath: 'assets/images/bubur-hati-ayam.png',
      badge: '9 - 11 Bulan',
      ingredients: [],
    ),
    _MenuData(
      title: 'Kue Ubi Keju',
      imagePath: 'assets/images/kue-ubi-keju.png',
      badge: '9 - 11 Bulan',
      ingredients: [],
    ),
    _MenuData(
      title: 'Jagung Kukus',
      imagePath: 'assets/images/jagung-kukus.png',
      badge: '9 - 11 Bulan',
      ingredients: [],
    ),
  ];

  static const Set<String> _rekomendasiTitles = {
    'Bubur Hati Ayam',
    'Kue Ubi Keju',
  };

  // ================= STATE =================
  String _filterAge = 'Semua';
  List<String> _filterIngredients = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _isFilterActive =>
      _filterAge != 'Semua' || _filterIngredients.isNotEmpty;
  bool get _isSearching => _searchQuery.trim().isNotEmpty;

  String _normAge(String a) => a == '12 Bulan +' ? '12+ Bulan' : a;
  String _normIng(String s) => s.replaceAll('\n', '').trim();

  @override
  void initState() {
    super.initState();
    final init = widget.initialIngredients;
    if (init != null && init.isNotEmpty) {
      _filterIngredients = List<String>.from(init);
    }
  }

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
        if (!m.ingredients.any((i) => wanted.contains(_normIng(i)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<_MenuData> get _gridMenus {
    final filtered = _filteredMenus;
    if (_isSearching) return filtered;
    if (!_isFilterActive || widget.fromPemeriksaan) {
      return filtered
          .where((m) => !_rekomendasiTitles.contains(m.title))
          .toList();
    }
    return filtered;
  }

  // ================= AKSI =================
  void _go(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    FocusScope.of(context).unfocus();
  }

  void _resetFilterAndSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filterAge = 'Semua';
      _filterIngredients = [];
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => FilterMenuSheet(
        initialAge: _filterAge,
        initialIngredients: _filterIngredients,
      ),
    );

    if (result != null) {
      setState(() {
        _filterAge = (result['age'] as String?) ?? 'Semua';
        _filterIngredients =
            List<String>.from(result['ingredients'] ?? const []);
      });
    }
  }

  Widget _tap(VoidCallback onTap, Widget child) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );

    Widget _card(_MenuData m, {bool border = true}) => MenuRecommendationCard(
        title: m.title,
        imagePath: m.imagePath,
        badge: m.badge,
        hasBorder: border,
        isNew: m.isNew,
        borderColor: textGrey,
      );

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final showReco =
        widget.fromPemeriksaan || (!_isFilterActive && !_isSearching);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Header Fixed, Pink Card & Grid ikut Scroll
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER MERAH (DIAM DI ATAS)
                _buildHeader(context),

                // 2. AREA SCROLL (PINK CARD & GRID)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.fromPemeriksaan) ...[
                          SizedBox(height: context.w(18)),
                          _buildPemeriksaanChips(context),
                        ],
                        SizedBox(height: context.w(showReco ? 18 : 22)),
                        if (showReco) ...[
                          _buildRecommendationBox(context),
                          SizedBox(height: context.w(36)),
                        ],
                        _buildGrid(context),
                        SizedBox(height: context.w(140)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 👆 ========================================================= 👆
            
            // ================= BOTTOM NAV =================
            BottomNav(
              currentIndex: 1,
              onTap: (i) {
                switch (i) {
                  case 0:
                    _go(const KoleksiScreen());
                  case 2:
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    }
                  case 3:
                    _go(const RiwayatScreen());
                  case 4:
                    _go(const ProfilScreen());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final h = topPad + context.w(190);

    return SizedBox(
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: h,
            decoration: BoxDecoration(
              color: primaryRed,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(context.w(50)),
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
                  Expanded(
                    child: Text(
                      'Aisyah',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.txt(24, w: 700, c: Colors.white, h: 29 / 24),
                    ),
                  ),
                  NotificationIconButton(
                    onTap: () => _go(const NotifikasiScreen()),
                    size: 26,
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
                  Expanded(child: _buildSearchBar(context)),
                  SizedBox(width: context.w(6)),
                  _buildFilterButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final hint = context.txt(12, c: textBlack50, h: 15 / 12);

    return Container(
      height: context.w(45),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(30)),
      ),
      child: Row(
        children: [
          SizedBox(width: context.w(19)),
          Icon(Icons.search, size: context.w(16), color: textBlack71),
          SizedBox(width: context.w(13)),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: context.txt(12, h: 15 / 12),
              decoration: InputDecoration(
                hintText: 'Mau masak apa hari ini?',
                hintStyle: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            _tap(
              _clearSearch,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(14)),
                child: Icon(Icons.close, size: context.w(18), color: textBlack71),
              ),
            )
          else
            SizedBox(width: context.w(19)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return _tap(
      _openFilterSheet,
      Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: context.w(42),
            height: context.w(45),
            decoration: BoxDecoration(
              color: bgTeal,
              borderRadius: BorderRadius.circular(context.w(10)),
            ),
            child: Center(child: _slidersIcon(context, tealDark, 20)),
          ),
          if (_isFilterActive)
            Positioned(
              top: context.w(-2),
              right: context.w(-2),
              child: Container(
                width: context.w(12),
                height: context.w(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE60E0E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: context.w(2)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _slidersIcon(BuildContext context, Color color, double size) =>
      SvgPicture.asset(
        'assets/images/sliders-bold.svg',
        width: context.w(size),
        height: context.w(size),
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );

  // ================= CHIPS DARI PEMERIKSAAN =================
  Widget _buildPemeriksaanChips(BuildContext context) {
    final items = widget.initialIngredients;
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    final selected = _filterIngredients.map(_normIng).toSet();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Berdasarkan Hasil Pemeriksaan',
            style: context.txt(12, w: 700, c: textGrey, h: 15 / 12),
          ),
          SizedBox(height: context.w(12)),
          Wrap(
            spacing: context.w(12),
            runSpacing: context.w(8),
            children: items.map((b) {
              final normB = _normIng(b);
              final isSelected = selected.contains(normB);

              return _tap(
                () => setState(() {
                  if (isSelected) {
                    _filterIngredients.removeWhere((i) => _normIng(i) == normB);
                  } else {
                    _filterIngredients.add(b);
                  }
                }),
                Container(
                  width: context.w(82.45),
                  height: context.w(31.51),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0x80F88B92) : Colors.white,
                    border: Border.all(color: primaryRed),
                    borderRadius: BorderRadius.circular(context.w(31.5)),
                  ),
                  child: Text(b, style: context.txt(12.6, w: 600, h: 15 / 12.6)),
                ),
              );
            }).toList(),
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
          colors: [Color(0x80FFD444), Color(0xFFFFB636)],
          stops: [0.0, 0.9279],
        ),
        borderRadius: BorderRadius.circular(context.w(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: ChildStore.currentName,
            builder: (_, name, _) => Text(
              name.trim().isEmpty ? 'REKOMENDASI' : 'UNTUK ${name.toUpperCase()}',
              style: context.txt(14, w: 700, c: primaryRed, h: 17 / 14),
            ),
          ),
          SizedBox(height: context.w(4)),
          Text(
            'Rekomendasi Menu',
            style: context.txt(
              20,
              w: 700,
              c: Colors.black.withValues(alpha: 0.7),
              h: 24 / 20,
            ),
          ),
          SizedBox(height: context.w(22)),
          SizedBox(
            height: context.w(186),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: [
                for (int i = 0; i < _recommended.length; i++) ...[
                  if (i > 0) SizedBox(width: context.w(9)),
                  _card(_recommended[i], border: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= GRID =================
  Widget _buildGrid(BuildContext context) {
    final items = _gridMenus;
    if (items.isEmpty) return _buildEmpty(context);

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      final needTop = left.isNew || (right?.isNew ?? false);

      rows.add(Padding(
        padding: EdgeInsets.only(
          left: context.w(37),
          right: context.w(37),
          top: needTop ? context.w(14) : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(left),
            right != null ? _card(right) : SizedBox(width: context.w(144)),
          ],
        ),
      ));

      if (i + 2 < items.length) rows.add(SizedBox(height: context.w(31)));
    }
    return Column(children: rows);
  }

  // ================= TIDAK DITEMUKAN =================
  Widget _buildEmpty(BuildContext context) {
    final msg = _isSearching
        ? 'Tidak ada resep dengan nama "${_searchQuery.trim()}".\nCoba kata kunci lain.'
        : 'Tidak ada resep yang cocok dengan filter.\nCoba ubah atau reset filter.';

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35, 
      child: Center(
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
              child: Icon(
                _isSearching ? Icons.search_off : Icons.filter_alt_off,
                size: context.w(60),
                color: primaryRed,
              ),
            ),
            SizedBox(height: context.w(23)),
            Text(
              'Tidak Ditemukan',
              style: context.txt(18, w: 600, h: 22 / 18),
            ),
            SizedBox(height: context.w(7)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(40)),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: context.txt(13, w: 500, c: textBlack50, h: 16 / 13),
              ),
            ),
            SizedBox(height: context.w(28)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tap(
                  _resetFilterAndSearch,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(10),
                      vertical: context.w(8),
                    ),
                    child: Row(children: [
                      _slidersIcon(context, textBlack71, 20),
                      SizedBox(width: context.w(8)),
                      Text(
                        'Reset Filter',
                        style: context.txt(14, w: 600, c: textBlack71, h: 17 / 14),
                      ),
                    ]),
                  ),
                ),
                SizedBox(width: context.w(16)),
                _tap(
                  _resetFilterAndSearch,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(20),
                      vertical: context.w(9),
                    ),
                    decoration: BoxDecoration(
                      color: badgeYellow,
                      borderRadius: BorderRadius.circular(context.w(22)),
                    ),
                    child: Row(children: [
                      Icon(Icons.refresh, size: context.w(18), color: Colors.white),
                      SizedBox(width: context.w(6)),
                      Text(
                        'Refresh',
                        style: context.txt(14, w: 700, c: Colors.white, h: 17 / 14),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}