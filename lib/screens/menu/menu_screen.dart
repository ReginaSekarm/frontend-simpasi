import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_text.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_store.dart';
import '../../widgets/filter_menu_sheet.dart';
import '../../widgets/menu_recommendation_card.dart';
import '../../widgets/notification_icon.dart';
import '../koleksi/koleksi_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'detail_resep_screen.dart';
import '../../services/user_service.dart';
import '../../widgets/recipe_store.dart'; 

// ================= DATA MENU =================
class _MenuData {
  final int? id;
  final String title;
  final String imagePath;
  final String badge;
  final List<String> ingredients;
  final bool isNew;

  const _MenuData({
    this.id,
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

  // ================= DATA FALLBACK =================
  static const List<_MenuData> _fallbackMenus = [
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

  // ================= STATE =================
  List<_MenuData> _allMenus = List<_MenuData>.from(_fallbackMenus);
  List<_MenuData> _recommended = [];
  Set<String> _rekomendasiTitleSet = {};
  String _ibuName = 'Aisyah';
  bool _isLoading = true;

  int? _loadedBabyId;
  int _loadToken = 0;
  bool _isTogglingFav = false;

  String _filterAge = 'Semua';
  List<String> _filterIngredients = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _isFilterActive =>
      _filterAge != 'Semua' || _filterIngredients.isNotEmpty;
  bool get _isSearching => _searchQuery.trim().isNotEmpty;

  String get _ibuInitial {
    final trimmed = _ibuName.trim();
    if (trimmed.isEmpty) return 'A';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _normAge(String a) {
    final clean = a.replaceAll(' ', '').toLowerCase();
    if (a == '12 Bulan +' || clean == '12+' || clean == '12+bulan') {
      return '12+ Bulan';
    }
    if (clean == '6' || clean == '6bulan') return '6 Bulan';
    if (clean == '7-8' || clean == '7-8bulan') return '7 - 8 Bulan';
    if (clean == '9-11' || clean == '9-11bulan') return '9 - 11 Bulan';
    return a;
  }

  String _normIng(String s) => s.replaceAll('\n', '').trim();

  int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  String _formatBadge(dynamic rawAge) {
    if (rawAge == null) return 'MPASI';
    final s = rawAge.toString().trim();
    if (s.isEmpty) return 'MPASI';
    final lower = s.toLowerCase();
    if (lower.contains('bulan')) {
      return _normAge(s);
    }
    if (s == '12+') return '12+ Bulan';
    if (s == '7-8') return '7 - 8 Bulan';
    if (s == '9-11') return '9 - 11 Bulan';
    if (s == '6') return '6 Bulan';
    return '$s Bulan';
  }

  int? _hitungBulanUsia(dynamic rawBirthDate) {
    if (rawBirthDate == null) return null;
    final str = rawBirthDate.toString().trim();
    if (str.isEmpty) return null;

    DateTime? birthDate;
    if (str.contains('/')) {
      final parts = str.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          birthDate = DateTime(y, m, d);
        }
      }
    } else {
      birthDate = DateTime.tryParse(str);
    }

    if (birthDate == null) return null;
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return null;

    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months < 0 ? 0 : months;
  }

  bool _matchesAgeCategory(String rawCategory, int? months) {
    if (months == null) return true;
    final cat = rawCategory.trim().toLowerCase();
    if (cat.isEmpty) return true;
    if (months == 6) return cat == '6' || cat.contains('6');
    if (months >= 7 && months <= 8) {
      return cat == '7-8' || cat == '7' || cat == '8' || cat.contains('7 - 8') || cat.contains('7-8');
    }
    if (months >= 9 && months <= 11) {
      return cat == '9-11' || cat.contains('9 - 11') || cat.contains('9-11');
    }
    if (months >= 12) return cat == '12+' || cat.contains('12');
    return true;
  }

  String _pickRecipeImage(Map<String, dynamic> r, [String title = '']) {
    for (final key in ['photo_url','photoUrl','image_url','imageUrl','image_path','imagePath']) {
      final val = (r[key] ?? '').toString().trim();
      if (val.isNotEmpty) return val;
    }
    if (title.toLowerCase().contains('tahu ayam wortel')) return 'assets/images/tahu-ayam-wortel.png';
    if (title.toLowerCase().contains('pepaya')) return 'assets/images/pepaya-lumat.png';
    if (title.toLowerCase().contains('ubi')) return 'assets/images/kue-ubi-keju.png';
    if (title.toLowerCase().contains('pisang')) return 'assets/images/telur-santan-pisang.png';
    if (title.toLowerCase().contains('potato')) return 'assets/images/egg-potato-mash.png';
    return 'assets/images/bubur-hati-ayam.png';
  }

  List<String> _extractIngredients(Map<String, dynamic> map) {
    final raw = map['ingredients'] ?? map['ingredient_categories'] ?? map['ingredientCategories'] ?? map['categories'] ?? map['bahan'];
    if (raw is List) return raw.map((e) => e?.toString().trim() ?? '').where((e) => e.isNotEmpty).toList();
    if (raw is String && raw.trim().isNotEmpty) return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return const [];
  }

  _MenuData _mapRecipe(Map<String, dynamic> map, {String? overrideBadge}) {
    final nestedRecipe = map['recipe'] is Map ? Map<String, dynamic>.from(map['recipe'] as Map) : (map['Recipe'] is Map ? Map<String, dynamic>.from(map['Recipe'] as Map) : <String, dynamic>{});
    final id = _parseId(map['id'] ?? map['recipe_id'] ?? map['recipeId'] ?? nestedRecipe['id'] ?? nestedRecipe['recipe_id']);
    final title = (map['title'] ?? map['name'] ?? map['nama_menu'] ?? nestedRecipe['title'] ?? nestedRecipe['name'] ?? 'Menu MPASI').toString().trim();
    final imagePath = _pickRecipeImage(map.isNotEmpty ? map : nestedRecipe, title);
    final badge = overrideBadge ?? _formatBadge(map['age_category'] ?? map['ageCategory'] ?? map['badge'] ?? nestedRecipe['age_category'] ?? nestedRecipe['badge']);
    final ingredients = _extractIngredients(map.containsKey('ingredients') || map.containsKey('bahan') ? map : nestedRecipe);
    final isNew = map['is_new'] == true || map['isNew'] == true || nestedRecipe['is_new'] == true;
    return _MenuData(id: id, title: title, imagePath: imagePath, badge: badge, ingredients: ingredients, isNew: isNew);
  }

  List<_MenuData> _parseRecipeList(dynamic rawList, {String? overrideBadge}) {
    if (rawList is! List) return const [];
    final parsed = <_MenuData>[];
    for (final item in rawList) {
      if (item is Map) parsed.add(_mapRecipe(Map<String, dynamic>.from(item), overrideBadge: overrideBadge));
    }
    return parsed;
  }

  Future<List<_MenuData>> _fetchRecipesByAgeFallback(int? months, String defaultBadge, List<_MenuData> currentAllMenus) async {
    try {
      final recipesRes = await ApiClient.get('/recipes');
      final rawList = recipesRes['data'];
      if (rawList is List && rawList.isNotEmpty) {
        final results = <_MenuData>[];
        for (final item in rawList) {
          if (item is! Map) continue;
          final r = Map<String, dynamic>.from(item);
          final title = (r['title'] ?? r['name'] ?? '').toString().trim();
          if (title.isEmpty) continue;
          final rawCat = (r['age_category'] ?? r['ageCategory'] ?? r['badge'] ?? '').toString();
          if (!_matchesAgeCategory(rawCat, months)) continue;
          final badge = rawCat.trim().isNotEmpty ? _formatBadge(rawCat) : defaultBadge;
          results.add(_mapRecipe(r, overrideBadge: badge));
        }
        if (results.isNotEmpty) return results;
      }
    } catch (_) {}
    if (months != null) {
      final localAgeMatch = currentAllMenus.where((m) => _matchesAgeCategory(m.badge, months)).toList();
      if (localAgeMatch.isNotEmpty) return localAgeMatch;
    }
    return const [];
  }

  Map<String, dynamic>? _pickActiveBaby(List rawBabies) {
    final targetId = ChildStore.currentId.value;
    final targetName = ChildStore.currentName.value.trim().toLowerCase();
    final babies = <Map<String, dynamic>>[];
    for (final b in rawBabies) {
      if (b is Map) babies.add(Map<String, dynamic>.from(b));
    }
    if (babies.isEmpty) return null;
    if (targetId != null) {
      for (final b in babies) {
        final bId = _parseId(b['id'] ?? b['baby_id'] ?? b['babyId'] ?? b['child_id']);
        if (bId == targetId) return b;
      }
    }
    if (targetName.isNotEmpty) {
      for (final b in babies) {
        final bName = (b['full_name'] ?? b['fullName'] ?? b['name'] ?? b['nama'] ?? '').toString().trim().toLowerCase();
        if (bName == targetName) return b;
      }
    }
    return babies.first;
  }

  Future<void> _syncFavoriteStateFromBackend() async {
    if (_loadedBabyId == null) return;
    try {
      final endpoint = '/collection?babyId=$_loadedBabyId';
      final res = await ApiClient.get(endpoint);
      final rawData = res['data'];
      if (rawData is! List || !mounted) return;
      final Set<String> childFavs = {};
      for (final entry in rawData) {
        if (entry is! Map) continue;
        final map = Map<String, dynamic>.from(entry);
        final nestedRecipe = map['recipe'] is Map ? Map<String, dynamic>.from(map['recipe'] as Map) : <String, dynamic>{};
        final itemTitle = (nestedRecipe['title'] ?? nestedRecipe['name'] ?? map['title'] ?? map['name'] ?? '').toString().trim();
        if (itemTitle.isNotEmpty) childFavs.add(itemTitle);
      }
      RecipeStore.favorites.value = childFavs;
    } catch (_) {}
  }

  Future<void> _loadMenuData() async {
    final token = ++_loadToken;
    if (mounted) setState(() => _isLoading = true);

    List<_MenuData> loadedMenus = List<_MenuData>.from(_fallbackMenus);
    List<_MenuData> loadedReco = [];
    String? detectedIbuName;
    int? activeBabyId;
    String? activeBabyName;
    int? activeBabyMonths;

    try {
      final profileResult = await UserService.getProfile();
      final p = profileResult.profile;
      if (p != null && p.fullName.trim().isNotEmpty) {
        final parts = p.fullName.trim().split(RegExp(r'\s+'));
        if (parts.isNotEmpty) detectedIbuName = parts.first;
      }
    } catch (_) {}

    try {
      final babiesRes = await ApiClient.get('/babies');
      final rawBabies = babiesRes['data'] ?? babiesRes['babies'];
      if (rawBabies is List && rawBabies.isNotEmpty) {
        final chosenBaby = _pickActiveBaby(rawBabies);
        if (chosenBaby != null) {
          activeBabyId = _parseId(chosenBaby['id'] ?? chosenBaby['baby_id'] ?? chosenBaby['babyId'] ?? chosenBaby['child_id']);
          final bNama = (chosenBaby['full_name'] ?? chosenBaby['fullName'] ?? chosenBaby['name'] ?? chosenBaby['nama'])?.toString().trim();
          if (bNama != null && bNama.isNotEmpty) activeBabyName = bNama;
          activeBabyMonths = _hitungBulanUsia(chosenBaby['birth_date'] ?? chosenBaby['birthDate'] ?? chosenBaby['tanggalLahir']);
        }
      }
    } on ApiException {}

    try {
      final recipesRes = await ApiClient.get('/recipes');
      final parsed = _parseRecipeList(recipesRes['data'] ?? recipesRes['recipes'] ?? recipesRes['items']);
      if (parsed.isNotEmpty) loadedMenus = parsed;
    } on ApiException {}

    final defaultBadge = activeBabyMonths != null && activeBabyMonths < 12 ? '$activeBabyMonths Bulan' : 'MPASI';

    if (activeBabyId != null) {
      try {
        final recoRes = await ApiClient.get('/babies/$activeBabyId/recommendations?limit=10');
        final info = recoRes['info'] is Map ? Map<String, dynamic>.from(recoRes['info'] as Map) : <String, dynamic>{};
        final badgeText = info['ageCategory'] != null && info['ageCategory'].toString().trim().isNotEmpty ? _formatBadge(info['ageCategory']) : defaultBadge;
        loadedReco = _parseRecipeList(recoRes['data'] ?? recoRes['recommendations'], overrideBadge: badgeText);
        if (loadedReco.isEmpty) loadedReco = await _fetchRecipesByAgeFallback(activeBabyMonths, badgeText, loadedMenus);
      } on ApiException {
        loadedReco = await _fetchRecipesByAgeFallback(activeBabyMonths, defaultBadge, loadedMenus);
      }
    } else {
      loadedReco = [];
    }

    if (!mounted || token != _loadToken) return;

    _loadedBabyId = activeBabyId;

    if (ChildStore.currentId.value == null && activeBabyId != null) {
      ChildStore.setCurrent(activeBabyName ?? '', id: activeBabyId);
    } else if (ChildStore.currentName.value.trim().isEmpty && activeBabyName != null && activeBabyName.isNotEmpty) {
      ChildStore.setCurrent(activeBabyName, id: ChildStore.currentId.value);
    }

    setState(() {
      if (detectedIbuName != null && detectedIbuName.isNotEmpty) _ibuName = detectedIbuName;
      _allMenus = loadedMenus;
      _recommended = loadedReco;
      _rekomendasiTitleSet = loadedReco.map((e) => e.title).toSet();
      _isLoading = false;
    });

    _syncFavoriteStateFromBackend();
  }

  void _onActiveChildChanged() {
    final newId = ChildStore.currentId.value;
    if (newId == null || newId == _loadedBabyId) return;
    _loadMenuData();
  }

  @override
  void initState() {
    super.initState();
    final init = widget.initialIngredients;
    if (init != null && init.isNotEmpty) {
      _filterIngredients = List<String>.from(init);
    }
    ChildStore.currentId.addListener(_onActiveChildChanged);
    _loadMenuData();
  }

  @override
  void dispose() {
    ChildStore.currentId.removeListener(_onActiveChildChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<_MenuData> get _filteredMenus {
    final query = _searchQuery.trim().toLowerCase();
    return _allMenus.where((m) {
      if (query.isNotEmpty && !m.title.toLowerCase().contains(query)) return false;
      if (_filterAge != 'Semua' && _normAge(_filterAge) != _normAge(m.badge)) return false;
      if (_filterIngredients.isNotEmpty) {
        final wanted = _filterIngredients.map(_normIng).toSet();
        if (!m.ingredients.any((i) => wanted.contains(_normIng(i)))) return false;
      }
      return true;
    }).toList();
  }

  List<_MenuData> get _gridMenus {
    final filtered = _filteredMenus;
    if (_isSearching) return filtered;
    if (!_isFilterActive || widget.fromPemeriksaan) {
      return filtered.where((m) => !_rekomendasiTitleSet.contains(m.title)).toList();
    }
    return filtered;
  }

  void _go(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

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
    _loadMenuData();
  }

  Future<void> _openFilterSheet() async {
    final rawResult = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => FilterMenuSheet(initialAge: _filterAge, initialIngredients: _filterIngredients),
    );
    if (rawResult is Map) {
      final result = Map<String, dynamic>.from(rawResult);
      final rawIngredients = result['ingredients'];
      final nextIngredients = <String>[];
      if (rawIngredients is List) {
        for (final item in rawIngredients) {
          if (item != null) nextIngredients.add(item.toString());
        }
      }
      setState(() {
        _filterAge = (result['age'] as String?) ?? 'Semua';
        _filterIngredients = nextIngredients;
      });
    }
  }

  Future<void> _toggleFavorite(_MenuData m) async {
    if (_isTogglingFav || _loadedBabyId == null) return;
    final favs = Set<String>.from(RecipeStore.favorites.value);
    final isCurrentlyLiked = favs.contains(m.title);
    final nextLiked = !isCurrentlyLiked;

    if (nextLiked) {
      favs.add(m.title);
    } else {
      favs.remove(m.title);
    }
    RecipeStore.favorites.value = favs;
    setState(() => _isTogglingFav = true);

    try {
      if (nextLiked) {
        await ApiClient.post('/collection', data: {'recipeId': m.id, 'babyId': _loadedBabyId});
      } else {
        await ApiClient.delete('/collection/${m.id}?babyId=$_loadedBabyId');
      }
    } catch (e) {
      if (nextLiked) {
        favs.remove(m.title);
      } else {
        favs.add(m.title);
      }
      RecipeStore.favorites.value = favs;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui koleksi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingFav = false);
    }
  }

  Widget _tap(VoidCallback onTap, Widget child) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );

  Widget _card(_MenuData m, {bool border = true}) => MenuRecommendationCard(
        recipeId: m.id,
        title: m.title,
        imagePath: m.imagePath,
        badge: m.badge,
        hasBorder: border,
        isNew: m.isNew,
        borderColor: textGrey,
        onTap: () => _go(
          DetailResepScreen(
            recipeId: m.id,
            title: m.title,
            imagePath: m.imagePath,
            badge: m.badge,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hasBaby = _loadedBabyId != null;
    final showReco = hasBaby && (widget.fromPemeriksaan || (!_isFilterActive && !_isSearching));

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: primaryRed))
                      : RefreshIndicator(
                          color: primaryRed,
                          onRefresh: _loadMenuData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                ),
              ],
            ),
            
            // PERBAIKAN BOTTOM NAV AGAR TIDAK ERROR SAAT PINDAH HALAMAN
            BottomNav(
              currentIndex: 1,
              onTap: (i) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                switch (i) {
                  case 0:
                    _go(const KoleksiScreen());
                  case 2:
                    if (Navigator.of(context).canPop()) {
                      Future.microtask(() {
                        if (mounted) {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        }
                      });
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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(context.w(50))),
            ),
          ),
          Positioned(
            top: topPad + 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(color: Color(0xFFFCEBD5), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        _ibuInitial,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9E5665)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _ibuName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  NotificationIconButton(
                    onTap: () => _go(const NotifikasiScreen()),
                    size: 26,
                  ),
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
            decoration: BoxDecoration(color: bgTeal, borderRadius: BorderRadius.circular(context.w(10))),
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

  Widget _slidersIcon(BuildContext context, Color color, double size) => SvgPicture.asset(
        'assets/images/sliders-bold.svg',
        width: context.w(size),
        height: context.w(size),
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );

  Widget _buildPemeriksaanChips(BuildContext context) {
    final items = widget.initialIngredients;
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    final selected = _filterIngredients.map(_normIng).toSet();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Berdasarkan Hasil Pemeriksaan', style: context.txt(12, w: 700, c: textGrey, h: 15 / 12)),
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

  Widget _buildRecommendationBox(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: context.w(23)),
      padding: EdgeInsets.fromLTRB(context.w(26), context.w(18), context.w(26), context.w(30)),
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
          Text('Rekomendasi Menu', style: context.txt(20, w: 700, c: Colors.black.withValues(alpha: 0.7), h: 24 / 20)),
          SizedBox(height: context.w(22)),
          SizedBox(
            height: context.w(186),
            child: _recommended.isEmpty
                ? Center(
                    child: Text('Belum ada rekomendasi menu', style: context.txt(12, w: 500, c: Colors.black.withValues(alpha: 0.6))),
                  )
                : ListView(
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

  Widget _buildGrid(BuildContext context) {
    final items = _gridMenus;
    if (items.isEmpty) return _buildEmpty(context);

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      final needTop = left.isNew || (right?.isNew ?? false);

      rows.add(Padding(
        padding: EdgeInsets.only(left: context.w(37), right: context.w(37), top: needTop ? context.w(14) : 0),
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
              decoration: const BoxDecoration(color: bgPeachSoft, shape: BoxShape.circle),
              child: Icon(_isSearching ? Icons.search_off : Icons.filter_alt_off, size: context.w(60), color: primaryRed),
            ),
            SizedBox(height: context.w(23)),
            Text('Tidak Ditemukan', style: context.txt(18, w: 600, h: 22 / 18)),
            SizedBox(height: context.w(7)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(40)),
              child: Text(msg, textAlign: TextAlign.center, style: context.txt(13, w: 500, c: textBlack50, h: 16 / 13)),
            ),
            SizedBox(height: context.w(28)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tap(
                  _resetFilterAndSearch,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.w(8)),
                    child: Row(children: [
                      _slidersIcon(context, textBlack71, 20),
                      SizedBox(width: context.w(8)),
                      Text('Reset Filter', style: context.txt(14, w: 600, c: textBlack71, h: 17 / 14)),
                    ]),
                  ),
                ),
                SizedBox(width: context.w(16)),
                _tap(
                  _resetFilterAndSearch,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.w(9)),
                    decoration: BoxDecoration(color: badgeYellow, borderRadius: BorderRadius.circular(context.w(22))),
                    child: Row(children: [
                      Icon(Icons.refresh, size: context.w(18), color: Colors.white),
                      SizedBox(width: context.w(6)),
                      Text('Refresh', style: context.txt(14, w: 700, c: Colors.white, h: 17 / 14)),
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