import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_store.dart';
import '../../widgets/recipe_store.dart';
import '../../widgets/notification_icon.dart';
import '../home/home_ibu_screen.dart';
import '../menu/menu_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../profil/profil_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../menu/detail_resep_screen.dart' show DetailResepScreen;

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

class _KoleksiEntry {
  final int? recipeId;
  final RecipeItem item;
  final String caloriesText;

  const _KoleksiEntry({
    this.recipeId,
    required this.item,
    required this.caloriesText,
  });
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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<_KoleksiEntry> _entries = [];
  bool _isLoading = true;
  int? _activeBabyId;
  String _activeChildName = '';

  // Penanda request terbaru, supaya respons lama tidak menimpa yang baru
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _activeChildName = ChildStore.currentName.value;
    ChildStore.currentId.addListener(_onActiveChildChanged);
    _loadCollection();
  }

  // Dipanggil saat anak aktif di ChildStore berubah
  void _onActiveChildChanged() {
    if (!mounted) return;
    final newId = ChildStore.currentId.value;
    if (newId == null || newId == _activeBabyId) return;
    _activeChildName = ChildStore.currentName.value;
    _loadCollection();
  }

  @override
  void dispose() {
    ChildStore.currentId.removeListener(_onActiveChildChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  // Pilih anak aktif: prioritas ID dari store, lalu nama, terakhir anak pertama.
  Future<int?> _resolveActiveBabyId() async {
    try {
      final resBabies = await ApiClient.get('/babies');
      final rawBabies = resBabies['data'] ?? resBabies['babies'];
      if (rawBabies is List && rawBabies.isNotEmpty) {
        final storeId = ChildStore.currentId.value;
        final targetName = _activeChildName.trim().toLowerCase();

        final babies = <Map<String, dynamic>>[];
        for (final b in rawBabies) {
          if (b is Map) babies.add(Map<String, dynamic>.from(b));
        }
        if (babies.isEmpty) return null;

        int? idOf(Map<String, dynamic> m) =>
            _parseId(m['id'] ?? m['baby_id'] ?? m['babyId']);
        String nameOf(Map<String, dynamic> m) =>
            (m['full_name'] ?? m['fullName'] ?? m['name'] ?? m['nama'] ?? '')
                .toString()
                .trim();

        Map<String, dynamic>? selectedMap;

        if (storeId != null) {
          for (final m in babies) {
            if (idOf(m) == storeId) {
              selectedMap = m;
              break;
            }
          }
        }
        if (selectedMap == null && targetName.isNotEmpty) {
          for (final m in babies) {
            if (nameOf(m).toLowerCase() == targetName) {
              selectedMap = m;
              break;
            }
          }
        }
        selectedMap ??= babies.first;

        _activeChildName = nameOf(selectedMap);
        return idOf(selectedMap);
      }
    } catch (_) {
      // Abaikan jika gagal mengambil daftar anak
    }
    return null;
  }

  bool _belongsToActiveChild(
    Map<String, dynamic> map,
    int? activeBabyId,
    String activeChildName,
  ) {
    final entryBabyId = _parseId(
      map['baby_id'] ??
          map['babyId'] ??
          (map['baby'] is Map ? (map['baby'] as Map)['id'] : null),
    );
    final entryBabyName = (map['baby_name'] ??
            map['babyName'] ??
            map['child_name'] ??
            map['childName'] ??
            (map['baby'] is Map
                ? ((map['baby'] as Map)['full_name'] ??
                    (map['baby'] as Map)['name'])
                : '') ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    if (activeBabyId != null) {
      if (entryBabyId != null) {
        return entryBabyId == activeBabyId;
      }
      if (entryBabyName.isNotEmpty && activeChildName.isNotEmpty) {
        return entryBabyName == activeChildName.toLowerCase();
      }
      return false;
    }

    if (entryBabyName.isNotEmpty && activeChildName.isNotEmpty) {
      return entryBabyName == activeChildName.toLowerCase();
    }
    return true;
  }

  Future<void> _loadCollection() async {
    final token = ++_loadToken;
    setState(() => _isLoading = true);
    try {
      final activeBabyId = await _resolveActiveBabyId();
      if (!mounted || token != _loadToken) return;
      _activeBabyId = activeBabyId;
      final activeChildName = _activeChildName.trim();

      final endpoint = activeBabyId != null
          ? '/collection?babyId=$activeBabyId'
          : '/collection';
      final res = await ApiClient.get(endpoint);
      if (!mounted || token != _loadToken) return;

      final rawData = res['data'];
      final List<_KoleksiEntry> loaded = [];
      final Set<String> syncedTitles = {};

      if (rawData is List) {
        for (final entry in rawData) {
          if (entry is! Map) continue;
          final map = Map<String, dynamic>.from(entry);
          if (!_belongsToActiveChild(map, activeBabyId, activeChildName)) {
            continue;
          }

          final nestedRecipe = map['recipe'] is Map
              ? Map<String, dynamic>.from(map['recipe'] as Map)
              : (map['Recipe'] is Map
                  ? Map<String, dynamic>.from(map['Recipe'] as Map)
                  : <String, dynamic>{});

          final recipeId = _parseId(
            map['recipe_id'] ??
                map['recipeId'] ??
                nestedRecipe['id'] ??
                nestedRecipe['recipe_id'] ??
                map['id'],
          );

          final title = (nestedRecipe['title'] ??
                  nestedRecipe['name'] ??
                  map['title'] ??
                  map['name'] ??
                  'Resep MPASI')
              .toString()
              .trim();

String imagePath = '';
for (final src in [nestedRecipe, map]) {
  for (final key in [
    'photo_url',
    'photoUrl',
    'image_url',
    'imageUrl',
    'image_path',
    'imagePath',
  ]) {
    final v = (src[key] ?? '').toString().trim();
    if (v.isNotEmpty) {
      imagePath = v;
      break;
    }
  }
  if (imagePath.isNotEmpty) break;
}
if (imagePath.isEmpty) imagePath = 'assets/images/bubur-hati-ayam.png';

          final rawAge = (nestedRecipe['age_category'] ??
                  nestedRecipe['ageCategory'] ??
                  nestedRecipe['badge'] ??
                  map['age_category'] ??
                  map['badge'] ??
                  'MPASI')
              .toString()
              .trim();

          final badge = rawAge.toLowerCase().contains('bulan')
              ? rawAge
              : '$rawAge Bulan';

          final rawKal = nestedRecipe['calories'] ??
              nestedRecipe['kalori'] ??
              map['calories'] ??
              map['kalori'];
          String caloriesText = '320 kkal';
          if (rawKal != null && rawKal.toString().trim().isNotEmpty) {
            final kalStr = rawKal.toString().trim();
            caloriesText =
                kalStr.toLowerCase().contains('kkal') ? kalStr : '$kalStr kkal';
          }

          syncedTitles.add(title);
          loaded.add(
            _KoleksiEntry(
              recipeId: recipeId,
              item: RecipeItem(
                title: title,
                imagePath: imagePath.isEmpty
                    ? 'assets/images/bubur-hati-ayam.png'
                    : imagePath,
                badge: badge,
              ),
              caloriesText: caloriesText,
            ),
          );
        }
      }

      RecipeStore.favorites.value = syncedTitles;

      setState(() {
        _entries = loaded;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || token != _loadToken) return;
      setState(() => _isLoading = false);
      _snack(e.message.isNotEmpty ? e.message : 'Gagal memuat koleksi resep');
    } catch (_) {
      if (!mounted || token != _loadToken) return;
      setState(() => _isLoading = false);
      _snack('Terjadi kesalahan saat memuat koleksi resep');
    }
  }

  Future<void> _removeFromCollection(_KoleksiEntry entry) async {
    final recipeId = entry.recipeId;

    setState(() {
      _entries.removeWhere((e) =>
          (recipeId != null && e.recipeId == recipeId) ||
          e.item.title == entry.item.title);
    });
    final updatedFavs = Set<String>.from(RecipeStore.favorites.value)
      ..remove(entry.item.title);
    RecipeStore.favorites.value = updatedFavs;

    if (recipeId == null) return;

    try {
      final endpoint = _activeBabyId != null
          ? '/collection/$recipeId?babyId=$_activeBabyId'
          : '/collection/$recipeId';
      await ApiClient.delete(endpoint);
      _snack('Dihapus dari koleksi');
    } on ApiException catch (e) {
      _snack(e.message.isNotEmpty ? e.message : 'Gagal menghapus dari koleksi');
      await _loadCollection();
    }
  }

  Widget _buildRecipeImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: textGrey,
          child: const Icon(Icons.fastfood, color: Colors.white),
        ),
      );
    }

    return Image.asset(
      path,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: textGrey,
        child: const Icon(Icons.fastfood, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredEntries = query.isEmpty
        ? _entries
        : _entries
            .where((e) => e.item.title.toLowerCase().contains(query))
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: primaryRed),
                        )
                      : RefreshIndicator(
                          color: primaryRed,
                          onRefresh: _loadCollection,
                          child: _entries.isEmpty
                              ? SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * 0.65,
                                    child: _buildEmptyState(context),
                                  ),
                                )
                              : filteredEntries.isEmpty
                                  ? SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.65,
                                        child: _buildNoResultsState(context),
                                      ),
                                    )
                                  : GridView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
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
                                      itemCount: filteredEntries.length,
                                      itemBuilder: (_, i) => _buildCard(
                                        context,
                                        filteredEntries[i],
                                      ),
                                    ),
                        ),
                ),
              ],
            ),

            BottomNav(
              currentIndex: 0,
              onTap: (i) {
                if (i == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MenuScreen()),
                  );
                } else if (i == 2) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeIbuScreen()),
                    (r) => false,
                  );
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

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      height: topPad + context.w(170),
      decoration: BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.w(50)),
          bottomRight: Radius.circular(context.w(50)),
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
                  NotificationIconButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: context.w(15)),
                ],
              ),
            ),
          ),
          Positioned(
            top: topPad + context.w(100),
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
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
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

  Widget _buildCard(BuildContext context, _KoleksiEntry entry) {
    final item = entry.item;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailResepScreen(
              title: item.title,
              imagePath: item.imagePath,
              badge: item.badge,
            ),
          ),
        );
        if (mounted) {
          _loadCollection();
        }
      },
      child: Container(
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
                      child: _buildRecipeImage(item.imagePath),
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
                        onTap: () => _removeFromCollection(entry),
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
                      SvgPicture.asset(
                        'assets/images/fire.svg',
                        width: context.w(12),
                        height: context.w(12),
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          fireOrange,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: context.w(2)),
                      Text(
                        entry.caloriesText,
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
      ),
    );
  }
}