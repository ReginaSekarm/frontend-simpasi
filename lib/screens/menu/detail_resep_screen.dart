import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/recipe_store.dart';
import '../../widgets/komentar_sheet.dart';
import '../koleksi/koleksi_screen.dart';
import '../home/home_ibu_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../profil/profil_screen.dart';

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

// ================= DATA DETAIL RESEP =================
class RecipeDetailData {
  final int? recipeId;
  final String title;
  final String imagePath;
  final String badge;
  final List<String> bahan;
  final List<String> langkah;
  final String kalori;
  final String protein;
  final String karbohidrat;
  final String lemak;
  final String tips;

  const RecipeDetailData({
    this.recipeId,
    required this.title,
    required this.imagePath,
    required this.badge,
    required this.bahan,
    required this.langkah,
    required this.kalori,
    required this.protein,
    required this.karbohidrat,
    required this.lemak,
    required this.tips,
  });

  RecipeDetailData copyWith({
    int? recipeId,
    String? title,
    String? imagePath,
    String? badge,
    List<String>? bahan,
    List<String>? langkah,
    String? kalori,
    String? protein,
    String? karbohidrat,
    String? lemak,
    String? tips,
  }) {
    return RecipeDetailData(
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      badge: badge ?? this.badge,
      bahan: bahan ?? this.bahan,
      langkah: langkah ?? this.langkah,
      kalori: kalori ?? this.kalori,
      protein: protein ?? this.protein,
      karbohidrat: karbohidrat ?? this.karbohidrat,
      lemak: lemak ?? this.lemak,
      tips: tips ?? this.tips,
    );
  }

  static RecipeDetailData fromTitle(
    String title, {
    int? recipeId,
    String? imagePath,
    String? badge,
  }) {
    final resolvedImage = (imagePath != null && imagePath.trim().isNotEmpty)
        ? imagePath.trim()
        : 'assets/images/bubur-hati-ayam.png';
    final resolvedBadge = (badge != null && badge.trim().isNotEmpty)
        ? badge.trim()
        : '9 - 11 Bulan';

    if (title.toLowerCase().contains('pepaya')) {
      return RecipeDetailData(
        recipeId: recipeId,
        title: title,
        imagePath: resolvedImage,
        badge: resolvedBadge,
        bahan: const [
          'Pepaya matang: 30–50 gram (pilih yang manis dan matang sempurna)',
        ],
        langkah: const [
          'Kupas kulit pepaya dan buang bijinya hingga bersih.',
          'Potong kecil-kecil, lalu lumatkan menggunakan sendok/garpu atau saring menggunakan saringan kawat hingga bertekstur halus.',
          'Siap disajikan sebagai camilan/menu pendamping',
        ],
        kalori: '80',
        protein: '3,5',
        karbohidrat: '8',
        lemak: '3,5',
        tips:
            'Buah pepaya lumat sebaiknya disajikan segar dan tidak disimpan terlalu lama karena dapat mengalami oksidasi (berubah warna/rasa) dan nutrisinya berkurang. Jika ada sisa pepaya utuh, simpan dalam wadah tertutup di kulkas maksimal 1–2 hari.',
      );
    }

    return RecipeDetailData(
      recipeId: recipeId,
      title: title,
      imagePath: resolvedImage,
      badge: resolvedBadge,
      bahan: const [
        '130gr ubi ungu',
        '50 ml santan kelapa',
        '1 butir telur ayam',
        'Keju parut secukupnya',
      ],
      langkah: const [
        'Potong ubi ungu',
        'Kukus selama 15 menit',
        'Haluskan ubi ungu',
        'Tambahkan santan dan telur, aduk rata',
        'Masukkan ke dalam food container',
        'Kukus kembali selama 10 menit',
        'Kue ubi keju siap disajikan',
      ],
      kalori: '58',
      protein: '2.2',
      karbohidrat: '4.8',
      lemak: '3.2',
      tips:
          'Simpan sisa kue dalam wadah kedap udara di kulkas maksimal 2 hari. Perkenalkan keju secara bertahap di awal untuk memantau reaksi alergi pada bayi.',
    );
  }
}

// ================= DETAIL RESEP SCREEN =================
class DetailResepScreen extends StatefulWidget {
  final int? recipeId;
  final String title;
  final String imagePath;
  final String badge;
  final bool openComments;

  const DetailResepScreen({
    super.key,
    this.recipeId,
    required this.title,
    required this.imagePath,
    required this.badge,
    this.openComments = false,
  });

  @override
  State<DetailResepScreen> createState() => _DetailResepScreenState();
}

class _DetailResepScreenState extends State<DetailResepScreen> {
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color bgCream     = Color(0xFFFFF1B5);
  static const Color badgeText   = Color(0xFFDE801A);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color textBlack50 = Color(0x80000000);
  static const Color greyToggle  = Color(0x80AAA6A6);
  static const Color heartRed    = Color(0xFFDD2E44);
  static const Color lampOrange  = Color(0xFFF1A038);

  int _tab = 0;
  late RecipeDetailData _data;
  int? _resolvedRecipeId;
  int? _activeBabyId;
  String _activeChildName = '';
  bool _isLoading = false;
  bool _isTogglingFav = false;

  @override
  void initState() {
    super.initState();
    _resolvedRecipeId = widget.recipeId;
    _data = RecipeDetailData.fromTitle(
      widget.title,
      recipeId: widget.recipeId,
      imagePath: widget.imagePath,
      badge: widget.badge,
    );

    _loadRecipeDetail();
    _syncFavoriteStateFromBackend();

    if (widget.openComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openKomentarSheet();
      });
    }
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

  Future<int?> _resolveActiveBabyId() async {
    if (_activeBabyId != null) return _activeBabyId;
    try {
      final resBabies = await ApiClient.get('/babies');
      final rawBabies = resBabies['data'] ?? resBabies['babies'];
      if (rawBabies is List && rawBabies.isNotEmpty) {
        final targetName = _activeChildName.trim().toLowerCase();
        Map<String, dynamic>? selectedMap;

        if (targetName.isNotEmpty) {
          for (final b in rawBabies) {
            if (b is! Map) continue;
            final map = Map<String, dynamic>.from(b);
            final nama = (map['full_name'] ??
                    map['fullName'] ??
                    map['name'] ??
                    map['nama'] ??
                    '')
                .toString()
                .trim()
                .toLowerCase();
            if (nama == targetName) {
              selectedMap = map;
              break;
            }
          }
        }

        selectedMap ??= Map<String, dynamic>.from(rawBabies.first as Map);
        _activeChildName = (selectedMap['full_name'] ??
                selectedMap['fullName'] ??
                selectedMap['name'] ??
                selectedMap['nama'] ??
                '')
            .toString()
            .trim();
        _activeBabyId = _parseId(
          selectedMap['id'] ??
              selectedMap['baby_id'] ??
              selectedMap['babyId'],
        );
      }
    } catch (_) {
      // Abaikan jika gagal memuat daftar anak
    }
    return _activeBabyId;
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

    if (entryBabyId != null && activeBabyId != null) {
      return entryBabyId == activeBabyId;
    }
    if (entryBabyName.isNotEmpty && activeChildName.isNotEmpty) {
      return entryBabyName == activeChildName.toLowerCase();
    }
    return true;
  }

  List<String> _splitLinesOrList(dynamic raw, List<String> fallback) {
    if (raw is List) {
      final list = raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      return list.isNotEmpty ? list : fallback;
    }
    if (raw is String && raw.trim().isNotEmpty) {
      final normalized = raw.replaceAll('\r\n', '\n');
      final parts = normalized.contains('\n')
          ? normalized.split('\n')
          : normalized.split(',');
      final list = parts
          .map((e) => e.replaceFirst(RegExp(r'^[\-\*\•\d\.\)\s]+'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return list.isNotEmpty ? list : fallback;
    }
    return fallback;
  }

  String _formatNutritionValue(dynamic raw, String fallback) {
    if (raw == null) return fallback;
    final s = raw.toString().trim();
    if (s.isEmpty) return fallback;
    return s
        .replaceAll(RegExp(r'\s*(kkal|g|gr)\s*$', caseSensitive: false), '')
        .trim();
  }

  String _formatBadge(dynamic rawAge, String fallback) {
    if (rawAge == null) return fallback;
    final s = rawAge.toString().trim();
    if (s.isEmpty) return fallback;
    final lower = s.toLowerCase();
    if (lower.contains('bulan')) return s;
    if (s == '12+') return '12+ Bulan';
    if (s == '7-8') return '7 - 8 Bulan';
    if (s == '9-11') return '9 - 11 Bulan';
    if (s == '6') return '6 Bulan';
    return '$s Bulan';
  }

  RecipeDetailData _mapRecipeDetail(Map<String, dynamic> map) {
    final id = _parseId(map['id'] ?? map['recipe_id'] ?? map['recipeId']) ??
        _resolvedRecipeId;

    final title = (map['title'] ?? map['name'] ?? map['nama_menu'] ?? _data.title)
        .toString()
        .trim();

    final image = (map['photo_url'] ??
            map['image_url'] ??
            map['imageUrl'] ??
            map['imagePath'] ??
            _data.imagePath)
        .toString()
        .trim();

    final badge = _formatBadge(
      map['age_category'] ?? map['ageCategory'] ?? map['badge'],
      _data.badge,
    );

    final bahan = _splitLinesOrList(
      map['ingredients'] ?? map['bahan'],
      _data.bahan,
    );

    final langkah = _splitLinesOrList(
      map['steps'] ?? map['instructions'] ?? map['langkah'],
      _data.langkah,
    );

    final kalori = _formatNutritionValue(
      map['calories'] ?? map['kalori'],
      _data.kalori,
    );
    final protein = _formatNutritionValue(
      map['protein_g'] ?? map['protein'],
      _data.protein,
    );
    final karbohidrat = _formatNutritionValue(
      map['carbs_g'] ?? map['carbohydrates'] ?? map['karbohidrat'],
      _data.karbohidrat,
    );
    final lemak = _formatNutritionValue(
      map['fat_g'] ?? map['fat'] ?? map['lemak'],
      _data.lemak,
    );

    final tipsRaw = (map['tips'] ??
            map['storage_tips'] ??
            map['storageTips'] ??
            '')
        .toString()
        .trim();
    final tips = tipsRaw.isNotEmpty ? tipsRaw : _data.tips;

    return RecipeDetailData(
      recipeId: id,
      title: title.isEmpty ? _data.title : title,
      imagePath: image.isEmpty ? _data.imagePath : image,
      badge: badge,
      bahan: bahan,
      langkah: langkah,
      kalori: kalori,
      protein: protein,
      karbohidrat: karbohidrat,
      lemak: lemak,
      tips: tips,
    );
  }

  Future<int?> _findRecipeIdByTitle(String targetTitle) async {
    final res = await ApiClient.get('/recipes');
    final rawList = res['data'];
    if (rawList is! List) return null;

    final cleanTarget = targetTitle.trim().toLowerCase();
    for (final item in rawList) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final itemTitle =
          (map['title'] ?? map['name'] ?? map['nama_menu'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      if (itemTitle == cleanTarget ||
          itemTitle.contains(cleanTarget) ||
          cleanTarget.contains(itemTitle)) {
        final foundId =
            _parseId(map['id'] ?? map['recipe_id'] ?? map['recipeId']);
        if (foundId != null) return foundId;
      }
    }
    return null;
  }

  Future<void> _syncFavoriteStateFromBackend() async {
    try {
      final activeBabyId = await _resolveActiveBabyId();
      final activeChildName = _activeChildName.trim();
      final endpoint = activeBabyId != null
          ? '/collection?babyId=$activeBabyId'
          : '/collection';
      final res = await ApiClient.get(endpoint);
      final rawData = res['data'];
      if (rawData is! List || !mounted) return;

      final Set<String> childFavs = {};
      bool matched = false;
      final cleanTitle = _data.title.trim().toLowerCase();

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

        final itemId = _parseId(
          map['recipe_id'] ??
              map['recipeId'] ??
              nestedRecipe['id'] ??
              nestedRecipe['recipe_id'],
        );
        final itemTitle = (nestedRecipe['title'] ??
                nestedRecipe['name'] ??
                map['title'] ??
                map['name'] ??
                '')
            .toString()
            .trim();

        if (itemTitle.isNotEmpty) {
          childFavs.add(itemTitle);
        }

        if ((_resolvedRecipeId != null && itemId == _resolvedRecipeId) ||
            (itemTitle.isNotEmpty && itemTitle.toLowerCase() == cleanTitle)) {
          matched = true;
          if (_resolvedRecipeId == null && itemId != null) {
            _resolvedRecipeId = itemId;
          }
          childFavs.add(_data.title);
        }
      }

      if (!matched) {
        childFavs.remove(_data.title);
      }
      RecipeStore.favorites.value = childFavs;
    } catch (_) {
      // Abaikan jika gagal menyinkronkan status awal koleksi
    }
  }

  Future<void> _loadRecipeDetail() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic>? recipeMap;

      if (_resolvedRecipeId != null) {
        final res = await ApiClient.get('/recipes/$_resolvedRecipeId');
        if (res['data'] is Map) {
          recipeMap = Map<String, dynamic>.from(res['data'] as Map);
        } else if (res['recipe'] is Map) {
          recipeMap = Map<String, dynamic>.from(res['recipe'] as Map);
        } else if (res['title'] != null || res['name'] != null) {
          recipeMap = Map<String, dynamic>.from(res);
        }
      } else {
        final res = await ApiClient.get('/recipes');
        final rawList = res['data'];
        if (rawList is List) {
          final targetTitle = _data.title.trim().toLowerCase();
          for (final item in rawList) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            final itemTitle =
                (map['title'] ?? map['name'] ?? map['nama_menu'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase();
            if (itemTitle == targetTitle) {
              recipeMap = map;
              break;
            }
          }
        }
      }

      if (recipeMap != null && mounted) {
        final mapped = _mapRecipeDetail(recipeMap);
        setState(() {
          _resolvedRecipeId = mapped.recipeId ?? _resolvedRecipeId;
          _data = mapped;
        });
      }
    } on ApiException {
      // Pertahankan data awal/fallback jika gagal mengambil detail dari API
    } catch (_) {
      // Abaikan error tak terduga agar UI tetap tampil
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFav) return;
    _isTogglingFav = true;

    final currentFavs = Set<String>.from(RecipeStore.favorites.value);
    final currentlyLiked = currentFavs.contains(_data.title);
    final nextLiked = !currentlyLiked;

    if (nextLiked) {
      currentFavs.add(_data.title);
    } else {
      currentFavs.remove(_data.title);
    }
    RecipeStore.favorites.value = currentFavs;

    try {
      int? id = _resolvedRecipeId;
      id ??= await _findRecipeIdByTitle(_data.title);
      final activeBabyId = await _resolveActiveBabyId();

      if (id == null) {
        _snack('ID resep tidak ditemukan di server');
        return;
      }

      _resolvedRecipeId = id;

      if (nextLiked) {
        await ApiClient.post(
          '/collection',
          data: {
            'recipeId': id,
            if (activeBabyId != null) 'babyId': activeBabyId,
          },
        );
        _snack('Resep disimpan ke koleksi');
      } else {
        final deleteEndpoint = activeBabyId != null
            ? '/collection/$id?babyId=$activeBabyId'
            : '/collection/$id';
        await ApiClient.delete(deleteEndpoint);
        _snack('Resep dihapus dari koleksi');
      }
    } on ApiException catch (e) {
      final reverted = Set<String>.from(RecipeStore.favorites.value);
      if (currentlyLiked) {
        reverted.add(_data.title);
      } else {
        reverted.remove(_data.title);
      }
      RecipeStore.favorites.value = reverted;
      _snack(
        e.message.isNotEmpty ? e.message : 'Gagal memperbarui koleksi resep',
      );
    } catch (_) {
      final reverted = Set<String>.from(RecipeStore.favorites.value);
      if (currentlyLiked) {
        reverted.add(_data.title);
      } else {
        reverted.remove(_data.title);
      }
      RecipeStore.favorites.value = reverted;
      _snack('Terjadi kesalahan saat memperbarui koleksi resep');
    } finally {
      _isTogglingFav = false;
    }
  }

  void _openKomentarSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => KomentarSheet(recipeTitle: _data.title),
    );
  }

  Widget _buildHeaderImage() {
    final cleanPath = _data.imagePath.trim();
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return Image.network(
        cleanPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: const Color(0xFFD9D9D9)),
      );
    }

    return Image.asset(
      cleanPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Container(color: const Color(0xFFD9D9D9)),
    );
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
                  _buildImageHeader(context),
                  const SizedBox(height: 17),
                  _buildTitleRow(),
                  if (_isLoading) ...[
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 31),
                      child: LinearProgressIndicator(
                        color: primaryRed,
                        backgroundColor: bgCream,
                        minHeight: 2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _buildTabs(),
                  const SizedBox(height: 22),
                  _buildListContent(),
                  const SizedBox(height: 42),
                  _buildNutritionBox(),
                  const SizedBox(height: 140),
                ],
              ),
            ),

            Positioned(
              bottom: 90,
              right: 15,
              child: GestureDetector(
                onTap: _openKomentarSheet,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 63,
                  height: 63,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: textBlack.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/chat-komentar.svg',
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        textBlack,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            BottomNav(
              currentIndex: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KoleksiScreen()),
                  );
                } else if (i == 1) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
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

  Widget _buildImageHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28.4),
        bottomRight: Radius.circular(28.4),
      ),
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: _buildHeaderImage()),
            Positioned(
              top: topPad + 10,
              left: 5,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 22,
                    color: textBlack,
                  ),
                ),
              ),
            ),
            Positioned(
              top: topPad + 10,
              right: 18,
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: RecipeStore.favorites,
                builder: (_, favs, __) {
                  final liked = favs.contains(_data.title);
                  return GestureDetector(
                    onTap: _toggleFavorite,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        size: 22,
                        color: liked ? heartRed : textBlack,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 0, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              _data.title,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textBlack,
                height: 29 / 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
            decoration: BoxDecoration(
              color: bgCream,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              _data.badge,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: badgeText,
                height: 17 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 43,
      decoration: BoxDecoration(
        color: greyToggle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Bahan'),
          _buildTabItem(1, 'Langkah'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : textBlack,
              height: 18 / 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    final items = _tab == 0 ? _data.bahan : _data.langkah;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((t) => _buildBulletItem(t)).toList(),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 30),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SizedBox(
              width: 16,
              height: 16,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textBlack,
                height: 20 / 15,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildNutritionBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      decoration: BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail nutrisi & tips',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 18 / 15,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildNutritionCard('Kalori', _data.kalori)),
              const SizedBox(width: 12),
              Expanded(child: _buildNutritionCard('Protein', _data.protein)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildNutritionCard('Karbohidrat', _data.karbohidrat)),
              const SizedBox(width: 12),
              Expanded(child: _buildNutritionCard('Lemak', _data.lemak)),
            ],
          ),
          const SizedBox(height: 27),
          Container(height: 3, color: textBlack50),
          const SizedBox(height: 13),
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 0, bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 24,
                  color: lampOrange,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips penyimpanan',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textBlack71,
                          height: 18 / 13,
                        ),
                      ),
                      Text(
                        _data.tips,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: textBlack,
                          height: 18 / 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: label == 'Karbohidrat' ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: textBlack71,
              height: 18 / (label == 'Karbohidrat' ? 10 : 12),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 18 / 24,
            ),
          ),
        ],
      ),
    );
  }
}