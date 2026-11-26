import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../models/child_data.dart';
import '../../services/user_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_store.dart';
import '../../widgets/child_switch_group.dart';
import '../../widgets/data_menu_dropdown.dart';
import '../../widgets/hapus_data_dialog.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/menu_recommendation_card.dart';
import '../../widgets/notification_icon.dart';
import '../../widgets/tambah_data_anak_sheet.dart';
import '../ai/tanya_ai_screen.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/detail_resep_screen.dart';
import '../menu/menu_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import '../riwayat/riwayat_screen.dart';

class HomeIbuScreen extends StatefulWidget {
  final bool showLoginSuccess;

  const HomeIbuScreen({super.key, this.showLoginSuccess = false});

  @override
  State<HomeIbuScreen> createState() => _HomeIbuScreenState();
}

class _HomeIbuScreenState extends State<HomeIbuScreen> {
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgPeach = Color(0xFFFCEBD5);
  static const Color bgTeal = Color(0xFF8BDFDD);
  static const Color textBrown = Color(0xFF785862);
  static const Color textGrey = Color(0xFF8F8F8F);

  static const Color textBlack = Color(0xFF000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color textBlack50 = Color(0x80000000);

  // 👇 BARU: warna kartu "Mulai dalam 3 langkah"
  static const Color bgMint = Color(0xFFDDF3F1);
  static const Color tealDark = Color(0xFF1A7772);

  static const String _babiesPath = '/babies';

  final List<ChildData> _children = [];
  final List<int?> _childIds = [];

  String _parentFirstName = 'Pengguna';
  String _parentInitial = 'P';
  String _preferredChildName = '';

  List<Map<String, String>> _recommendedMenus = [];
  String _recommendationMessage = '';
  bool _isLoadingData = false;

  int _currentChildIndex = 0;
  bool _showDataMenu = false;

  bool get _hasChild => _children.isNotEmpty;
  ChildData get _currentChild => _children[_currentChildIndex];
  int? get _currentChildId =>
      (_currentChildIndex >= 0 && _currentChildIndex < _childIds.length)
          ? _childIds[_currentChildIndex]
          : null;

  String _extractFirstName(String? fullName) {
    final cleaned = (fullName ?? '').trim();
    if (cleaned.isEmpty) return 'Pengguna';
    final parts = cleaned.split(RegExp(r'\s+'));
    return parts.first.isNotEmpty ? parts.first : 'Pengguna';
  }

  String _extractInitial(String firstName) {
    final cleaned = firstName.trim();
    if (cleaned.isEmpty) return 'P';
    return cleaned.characters.first.toUpperCase();
  }

  // Sinkronkan anak aktif ke ChildStore supaya halaman lain
  // (Menu, Koleksi, Riwayat) ikut memakai anak yang sama.
  void _syncCurrentChild() {
    if (_hasChild) {
      _preferredChildName = _currentChild.nama;
      ChildStore.setCurrent(_currentChild.nama, id: _currentChildId);
    } else {
      _preferredChildName = '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stunting':
        return const Color(0xFFD45060);
      case 'berisiko':
        return const Color(0xFFF1A038);
      case 'normal':
      default:
        return const Color(0x80006199);
    }
  }

  String _formatDecimal(dynamic raw, {String fallback = '-'}) {
    if (raw == null) return fallback;
    if (raw is num) {
      final str = raw.toString();
      final cleaned = str.contains('.')
          ? str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
          : str;
      return cleaned.replaceAll('.', ',');
    }
    final text = raw.toString().trim();
    if (text.isEmpty) return fallback;
    return text.replaceAll('.', ',');
  }

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty || normalized == '-') return null;
    return double.tryParse(normalized);
  }

  String _formatBirthDate(dynamic raw) {
    if (raw == null) return '-';
    final str = raw.toString().trim();
    if (str.isEmpty) return '-';

    final datePart = str.contains('T') ? str.split('T').first : str;
    if (datePart.contains('-')) {
      final parts = datePart.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1].padLeft(2, '0');
        final day = parts[2].padLeft(2, '0');
        return '$day/$month/$year';
      }
    }
    return datePart;
  }

  String _toIsoDate(String ddMmYyyy) {
    final parts = ddMmYyyy.split('/');
    if (parts.length != 3) return ddMmYyyy;
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    return '$year-$month-$day';
  }

  String _normalizeGenderToCode(dynamic raw) {
    final val = (raw ?? '').toString().trim().toLowerCase();
    if (val == 'p' || val == 'perempuan' || val == 'female' || val == 'f') {
      return 'P';
    }
    return 'L';
  }

  String _normalizeConditionLabel(dynamic raw) {
    final val = (raw ?? '').toString().trim().toLowerCase();
    if (val.isEmpty) return 'Normal';
    if (val.contains('stunt')) return 'Stunting';
    if (val.contains('risiko')) return 'Berisiko';
    if (val == 'normal') return 'Normal';
    return raw.toString().trim();
  }

  String? _normalizeConditionForApi(String status) {
    final lower = status.trim().toLowerCase();
    if (lower == 'normal' || lower == 'berisiko' || lower == 'stunting') {
      return lower;
    }
    return null;
  }

  String _formatAgeCategoryBadge(dynamic rawCategory) {
    final cat = (rawCategory ?? '').toString().trim();
    if (cat.isEmpty) return 'MPASI';
    if (cat == '6') return '6 Bulan';
    if (cat == '7') return '7 Bulan';
    if (cat == '7-8') return '7 - 8 Bulan';
    if (cat == '9-11') return '9 - 11 Bulan';
    if (cat == '12+') return '12+ Bulan';
    return cat.toLowerCase().contains('bulan') ? cat : '$cat Bulan';
  }

  int? _hitungBulanUsia(String tglLahir) {
    try {
      final parts = tglLahir.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      if (birthDate.day != day ||
          birthDate.month != month ||
          birthDate.year != year) {
        return null;
      }

      final now = DateTime.now();
      if (birthDate.isAfter(now)) return null;

      int months =
          (now.year - birthDate.year) * 12 + now.month - birthDate.month;
      if (now.day < birthDate.day) months--;
      return months < 0 ? 0 : months;
    } catch (_) {
      return null;
    }
  }

  String _hitungUmur(String tglLahir) {
    final months = _hitungBulanUsia(tglLahir);
    if (months == null) return '-';
    if (months < 12) return '$months Bulan';

    final years = months ~/ 12;
    final remainingMonths = months % 12;
    return remainingMonths == 0
        ? '$years Tahun'
        : '$years Tahun $remainingMonths Bulan';
  }

  String _extractBirthPlace(Map<String, dynamic> json, {String fallback = ''}) {
    for (final key in [
      'birth_place',
      'birthPlace',
      'tempat_lahir',
      'tempatLahir',
      'tempat',
    ]) {
      final raw = json[key];
      if (raw != null) {
        final cleaned = raw.toString().trim();
        if (cleaned.isNotEmpty && cleaned != '-') {
          return cleaned;
        }
      }
    }
    return fallback;
  }

  ChildData _mapBabyFromJson(Map<String, dynamic> json) {
    final tglLahir = _formatBirthDate(
      json['birth_date'] ?? json['birthDate'] ?? json['tanggalLahir'],
    );
    final rawUmur = json['umur'] ?? json['age'];
    final umurText = (rawUmur != null && rawUmur.toString().trim().isNotEmpty)
        ? rawUmur.toString().trim()
        : _hitungUmur(tglLahir);

    final tempatLahir = _extractBirthPlace(json, fallback: '');

    return ChildData(
      nama: (json['full_name'] ?? json['fullName'] ?? json['nama'] ?? 'Anak')
          .toString(),
      gender: _normalizeGenderToCode(
        json['gender'] ?? json['jenisKelamin'],
      ),
      umur: umurText,
      status: _normalizeConditionLabel(
        json['condition'] ??
            json['condition_note'] ??
            json['conditionNote'] ??
            json['status'],
      ),
      berat: _formatDecimal(
        json['weight_kg'] ?? json['weightKg'] ?? json['berat'],
      ),
      tinggi: _formatDecimal(
        json['height_cm'] ?? json['heightCm'] ?? json['tinggi'],
      ),
      kepala: _formatDecimal(
        json['head_circumference_cm'] ??
            json['headCircumferenceCm'] ??
            json['kepala'],
      ),
      lila: _formatDecimal(
        json['lila_cm'] ?? json['lilaCm'] ?? json['lila'],
      ),
      alergi: (json['allergies'] ?? json['alergi'] ?? '').toString(),
      tempat: tempatLahir.isEmpty ? '-' : tempatLahir,
      tanggalLahir: tglLahir,
    );
  }

  int? _extractBabyId(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['baby_id'] ?? json['babyId'];
    if (rawId is int) return rawId;
    if (rawId is num) return rawId.toInt();
    if (rawId != null) return int.tryParse(rawId.toString());
    return null;
  }

  Future<void> _fetchParentProfile() async {
    try {
      final result = await UserService.getProfile();
      final p = result.profile;
      if (p != null && p.fullName.trim().isNotEmpty && mounted) {
        final firstName = _extractFirstName(p.fullName);
        setState(() {
          _parentFirstName = firstName;
          _parentInitial = _extractInitial(firstName);
        });
      }
    } catch (_) {
      // Pertahankan nama bawaan bila gagal memuat profil
    }
  }

  Future<void> _fetchHomeData({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() => _isLoadingData = true);
    }

    try {
      await _fetchParentProfile();

      final babiesRes = await ApiClient.get(_babiesPath);
      final rawList = babiesRes['data'];

      if (rawList is List) {
        final parsedChildren = <ChildData>[];
        final parsedIds = <int?>[];

        for (final item in rawList) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            parsedChildren.add(_mapBabyFromJson(map));
            parsedIds.add(_extractBabyId(map));
          }
        }

        if (mounted) {
          // Prioritas: ID di store, lalu nama pilihan, lalu index sekarang
          final storeId = ChildStore.currentId.value;
          final preferredName = _preferredChildName.trim().toLowerCase();
          final storeName = ChildStore.currentName.value.trim().toLowerCase();

          int resolvedIndex = _currentChildIndex;
          int foundIndex = -1;

          if (storeId != null) {
            foundIndex = parsedIds.indexWhere((id) => id == storeId);
          }
          if (foundIndex < 0) {
            final wantedName =
                preferredName.isNotEmpty ? preferredName : storeName;
            if (wantedName.isNotEmpty) {
              foundIndex = parsedChildren.indexWhere(
                (c) => c.nama.trim().toLowerCase() == wantedName,
              );
            }
          }
          if (foundIndex >= 0) {
            resolvedIndex = foundIndex;
          }
          if (resolvedIndex >= parsedChildren.length) {
            resolvedIndex = 0;
          }

          setState(() {
            _children
              ..clear()
              ..addAll(parsedChildren);
            _childIds
              ..clear()
              ..addAll(parsedIds);
            _currentChildIndex = resolvedIndex;
          });
          _syncCurrentChild();
        }
      }

      await _fetchRecommendationsForCurrentChild();
    } on ApiException catch (_) {
      // Pertahankan data awal agar tampilan Home tetap muncul stabil
    } catch (_) {
      // Pertahankan data yang sudah tampil bila terjadi error tak terduga
    } finally {
      if (mounted && showLoading) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  String _pickRecipeImage(Map<String, dynamic> r, [String title = '']) {
    for (final key in [
      'photo_url',
      'photoUrl',
      'image_url',
      'imageUrl',
      'image_path',
      'imagePath',
    ]) {
      final val = (r[key] ?? '').toString().trim();
      if (val.isNotEmpty) return val;
    }
    if (title.toLowerCase().contains('tahu ayam wortel')) {
      return 'assets/images/tahu-ayam-wortel.png';
    }
    return 'assets/images/bubur-hati-ayam.png';
  }

  bool _matchesAgeCategory(String rawCategory, int? months) {
    if (months == null) return true;
    final cat = rawCategory.trim().toLowerCase();
    if (cat.isEmpty) return true;
    if (months == 6) {
      return cat == '6' || cat.contains('6');
    }
    if (months >= 7 && months <= 8) {
      return cat == '7-8' ||
          cat == '7' ||
          cat == '8' ||
          cat.contains('7 - 8') ||
          cat.contains('7-8');
    }
    if (months >= 9 && months <= 11) {
      return cat == '9-11' || cat.contains('9 - 11') || cat.contains('9-11');
    }
    if (months >= 12) {
      return cat == '12+' || cat.contains('12');
    }
    return true;
  }

  Future<List<Map<String, String>>> _fetchRecipesByAgeFallback(
    int? months,
    String defaultBadge,
  ) async {
    try {
      final recipesRes = await ApiClient.get('/recipes');
      final rawList = recipesRes['data'];
      if (rawList is! List) return [];

      final results = <Map<String, String>>[];
      for (final item in rawList) {
        if (item is! Map) continue;
        final r = Map<String, dynamic>.from(item);
        final title = (r['title'] ?? r['name'] ?? '').toString().trim();
        if (title.isEmpty) continue;
        final rawCat =
            (r['age_category'] ?? r['ageCategory'] ?? r['badge'] ?? '').toString();
        if (!_matchesAgeCategory(rawCat, months)) continue;

        final badge = rawCat.trim().isNotEmpty
            ? _formatAgeCategoryBadge(rawCat)
            : defaultBadge;
        results.add({
          'title': title,
          'imagePath': _pickRecipeImage(r, title),
          'badge': badge,
        });
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  Future<void> _fetchRecommendationsForCurrentChild() async {
    final babyId = _currentChildId;
    if (!_hasChild || babyId == null) {
      if (mounted) {
        setState(() {
          _recommendedMenus = [];
          _recommendationMessage = '';
        });
      }
      return;
    }

    final months = _hitungBulanUsia(_currentChild.tanggalLahir);
    final defaultBadge =
        months != null && months < 12 ? '$months Bulan' : 'MPASI';

    try {
      final res = await ApiClient.get(
        '$_babiesPath/$babyId/recommendations?limit=10',
      );

      final info = res['info'] is Map
          ? Map<String, dynamic>.from(res['info'] as Map)
          : <String, dynamic>{};
      final conditionLabel = _normalizeConditionLabel(info['condition']);
      final badgeText = info['ageCategory'] != null &&
              info['ageCategory'].toString().trim().isNotEmpty
          ? _formatAgeCategoryBadge(info['ageCategory'])
          : defaultBadge;
      final rawData = res['data'];

      final mappedMenus = <Map<String, String>>[];
      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map) {
            final r = Map<String, dynamic>.from(item);
            final title = (r['title'] ?? r['name'] ?? 'Menu MPASI').toString();
            mappedMenus.add({
              'title': title,
              'imagePath': _pickRecipeImage(r, title),
              'badge': badgeText,
            });
          }
        }
      }

      if (mappedMenus.isEmpty) {
        final ageFallback =
            await _fetchRecipesByAgeFallback(months, badgeText);
        mappedMenus.addAll(ageFallback);
      }

      if (mounted) {
        setState(() {
          if (_currentChildIndex >= 0 &&
              _currentChildIndex < _children.length &&
              info['condition'] != null) {
            _children[_currentChildIndex].status = conditionLabel;
          }
          _recommendationMessage = (res['message'] ?? '').toString();
          _recommendedMenus = mappedMenus;
        });
      }
    } on ApiException catch (_) {
      final ageFallback =
          await _fetchRecipesByAgeFallback(months, defaultBadge);
      if (mounted) {
        setState(() {
          _recommendedMenus = ageFallback;
        });
      }
    } catch (_) {
      final ageFallback =
          await _fetchRecipesByAgeFallback(months, defaultBadge);
      if (mounted) {
        setState(() {
          _recommendedMenus = ageFallback;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _syncCurrentChild();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.showLoginSuccess) {
        _showLoginSuccessSnackBar();
      }
      _fetchHomeData(showLoading: false);
    });
  }

  void _switchChild() {
    if (!_hasChild) return;
    setState(() {
      _currentChildIndex = (_currentChildIndex + 1) % _children.length;
    });
    // Memperbarui ChildStore -> Menu, Koleksi, Riwayat ikut berganti anak
    _syncCurrentChild();
    _fetchRecommendationsForCurrentChild();
  }

  Future<void> _openTambahAnak() async {
    if (_children.length >= 2) {
      _snack('Maksimal 2 data anak');
      return;
    }

    final rawResult = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const TambahDataAnakSheet(),
    );

    if (rawResult is Map) {
      final result = Map<String, dynamic>.from(rawResult);
      final newTglLahir = (result['tanggalLahir'] ?? '-').toString();
      final tempatInput = _extractBirthPlace(result, fallback: '');
      final newChild = ChildData(
        nama: (result['nama'] ?? 'Anak Baru').toString(),
        gender: _normalizeGenderToCode(result['gender'] ?? 'L'),
        umur: _hitungUmur(newTglLahir),
        status: _normalizeConditionLabel(result['status'] ?? 'Normal'),
        berat: (result['berat'] ?? '-').toString(),
        tinggi: (result['tinggi'] ?? '-').toString(),
        kepala: (result['kepala'] ?? '-').toString(),
        lila: (result['lila'] ?? '-').toString(),
        alergi: (result['alergi'] ?? '').toString(),
        tempat: tempatInput.isEmpty ? '-' : tempatInput,
        tanggalLahir: newTglLahir,
      );

      int? createdId;
      String tempatTersimpan = newChild.tempat;
      try {
        final createRes = await ApiClient.post(
          _babiesPath,
          data: {
            'fullName': newChild.nama,
            'gender': newChild.gender,
            'birthPlace': tempatInput.isEmpty ? null : tempatInput,
            'birthDate': _toIsoDate(newChild.tanggalLahir),
            'weightKg': _parseDouble(newChild.berat),
            'heightCm': _parseDouble(newChild.tinggi),
            'headCircumferenceCm': _parseDouble(newChild.kepala),
            'lilaCm': _parseDouble(newChild.lila),
            'conditionNote': _normalizeConditionForApi(newChild.status),
            'allergies':
                newChild.alergi.trim().isEmpty ? null : newChild.alergi.trim(),
          },
        );
        final resData = createRes['data'];
        if (resData is Map) {
          final resMap = Map<String, dynamic>.from(resData);
          createdId = _extractBabyId(resMap);
          final serverPlace =
              _extractBirthPlace(resMap, fallback: tempatInput);
          if (serverPlace.isNotEmpty) {
            tempatTersimpan = serverPlace;
          }
        }
      } on ApiException catch (e) {
        if (mounted) _snack(e.message);
      }

      if (!mounted) return;
      setState(() {
        _children.add(
          ChildData(
            nama: newChild.nama,
            gender: newChild.gender,
            umur: newChild.umur,
            status: newChild.status,
            berat: newChild.berat,
            tinggi: newChild.tinggi,
            kepala: newChild.kepala,
            lila: newChild.lila,
            alergi: newChild.alergi,
            tempat: tempatTersimpan,
            tanggalLahir: newChild.tanggalLahir,
          ),
        );
        _childIds.add(createdId);
        _currentChildIndex = _children.length - 1;
      });
      _syncCurrentChild();
      if (createdId != null) {
        await _fetchRecommendationsForCurrentChild();
      }
    }
  }

  Future<void> _openUbahAnak() async {
    setState(() => _showDataMenu = false);

    final currentPlace =
        _currentChild.tempat.trim() == '-' ? '' : _currentChild.tempat.trim();

    final rawResult = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => TambahDataAnakSheet(
        initialData: InitialChildData(
          nama: _currentChild.nama,
          gender: _currentChild.gender,
          tempat: currentPlace,
          tanggalLahir: _currentChild.tanggalLahir,
          bb: _currentChild.berat,
          tb: _currentChild.tinggi,
          kepala: _currentChild.kepala,
          lila: _currentChild.lila,
          kondisi: _currentChild.status,
        ),
      ),
    );

    if (rawResult is Map) {
      final result = Map<String, dynamic>.from(rawResult);
      final newTglLahir =
          (result['tanggalLahir'] ?? _currentChild.tanggalLahir).toString();
      final tempatDiubah =
          _extractBirthPlace(result, fallback: currentPlace);
      final updatedChild = ChildData(
        nama: (result['nama'] ?? _currentChild.nama).toString(),
        gender: _normalizeGenderToCode(result['gender'] ?? _currentChild.gender),
        umur: _hitungUmur(newTglLahir),
        status:
            _normalizeConditionLabel(result['status'] ?? _currentChild.status),
        berat: (result['berat'] ?? _currentChild.berat).toString(),
        tinggi: (result['tinggi'] ?? _currentChild.tinggi).toString(),
        kepala: (result['kepala'] ?? _currentChild.kepala).toString(),
        lila: (result['lila'] ?? _currentChild.lila).toString(),
        alergi: (result['alergi'] ?? _currentChild.alergi).toString(),
        tempat: tempatDiubah.isEmpty ? '-' : tempatDiubah,
        tanggalLahir: newTglLahir,
      );

      final babyId = _currentChildId;
      if (babyId != null) {
        try {
          await ApiClient.put(
            '$_babiesPath/$babyId',
            data: {
              'fullName': updatedChild.nama,
              'gender': updatedChild.gender,
              'birthPlace': tempatDiubah.isEmpty ? null : tempatDiubah,
              'birthDate': _toIsoDate(updatedChild.tanggalLahir),
              'weightKg': _parseDouble(updatedChild.berat),
              'heightCm': _parseDouble(updatedChild.tinggi),
              'headCircumferenceCm': _parseDouble(updatedChild.kepala),
              'lilaCm': _parseDouble(updatedChild.lila),
              'conditionNote': _normalizeConditionForApi(updatedChild.status),
              'allergies': updatedChild.alergi.trim().isEmpty
                  ? null
                  : updatedChild.alergi.trim(),
            },
          );
        } on ApiException catch (e) {
          if (mounted) _snack(e.message);
        }
      }

      if (!mounted) return;
      setState(() {
        _children[_currentChildIndex] = updatedChild;
      });
      _syncCurrentChild();
      if (babyId != null) {
        await _fetchRecommendationsForCurrentChild();
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _showLoginSuccessSnackBar() {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottomInset),
          content: Center(
            child: Container(
              width: context.w(275),
              height: context.w(44),
              decoration: BoxDecoration(
                color: const Color(0xFF77B255),
                borderRadius: BorderRadius.circular(context.w(17)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: context.w(26),
                  ),
                  SizedBox(width: context.w(10)),
                  Text(
                    'Login Berhasil',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 21 / 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Future<void> _hapusAnak() async {
    setState(() => _showDataMenu = false);

    final confirmed = await HapusDataDialog.show(context);
    if (!confirmed) return;

    final babyId = _currentChildId;
    if (babyId != null) {
      try {
        await ApiClient.delete('$_babiesPath/$babyId');
      } on ApiException catch (e) {
        if (mounted) _snack(e.message);
      }
    }

    if (!mounted) return;
    setState(() {
      _children.removeAt(_currentChildIndex);
      if (_currentChildIndex < _childIds.length) {
        _childIds.removeAt(_currentChildIndex);
      }
      _currentChildIndex = 0;
    });
    _syncCurrentChild();
    if (!_hasChild) ChildStore.clear();
    await _fetchRecommendationsForCurrentChild();
  }

  Future<void> _openAi() async {
    if (!_hasChild) {
      _snack('Tambahkan data anak dulu ya');
      return;
    }

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => TanyaAiScreen(
          child: AiChildInfo(
            id: _currentChildId,
            nama: _currentChild.nama,
            umur: _hitungUmur(_currentChild.tanggalLahir),
            gender: _currentChild.gender,
            status: _currentChild.status,
            alergi: _currentChild.alergi,
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _currentChild.alergi = result);
      await _fetchRecommendationsForCurrentChild();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),

                  // 👇 DIUBAH: tampilan berbeda saat belum / sudah ada data anak
                  if (_hasChild) ...[
                    _buildMenuSection(),
                    SizedBox(height: context.w(20)),
                    _buildStuntingBanner(),
                  ] else ...[
                    // Belum ada data anak (Figma: home-blm isi data)
                    SizedBox(height: context.w(29)),
                    _buildStuntingBanner(empty: true),
                    SizedBox(height: context.w(18)),
                    _buildStepsCard(),
                  ],

                  SizedBox(height: context.w(90) + bottomPad),
                ],
              ),
            ),

            if (_isLoadingData)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(
                      color: primaryRed,
                      backgroundColor: bgPeach,
                    ),
                  ),
                ),
              ),

            Positioned(
              bottom: context.w(90) + bottomPad,
              right: context.w(15),
              child: GestureDetector(
                onTap: _openAi,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: context.w(63),
                  height: context.w(63),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: textBlack.withValues(alpha: 0.25),
                        blurRadius: context.w(4),
                        offset: Offset(0, context.w(4)),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.w(12)),
                    child: Image.asset(
                      'assets/images/AI.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            BottomNav(
              currentIndex: 2,
              onTap: (i) {
                if (i == 0) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const KoleksiScreen()));
                } else if (i == 1) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MenuScreen()));
                } else if (i == 3) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const RiwayatScreen()));
                } else if (i == 4) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProfilScreen()));
                }
              },
            ),

            if (_showDataMenu)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showDataMenu = false),
                  behavior: HitTestBehavior.opaque,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ),
              ),

            if (_showDataMenu && _hasChild)
              Positioned(
                top: topPad + context.w(96),
                left: context.w(186),
                child: DataMenuDropdown(
                  onEdit: _openUbahAnak,
                  onDelete: _hapusAnak,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // 👇 DIUBAH: ukuran header & posisi kartu berbeda saat belum ada data anak.
    // Figma (belum ada data): header merah berakhir di y=160, kartu y=138..373.
    // Dihitung relatif terhadap status bar (±39px di Figma):
    //   header = topPad + 121, kartu = topPad + 99, total section = topPad + 334.
    final redHeight = topPad + context.w(_hasChild ? 170 : 121);
    final cardTop = topPad + context.w(_hasChild ? 116 : 99);
    final sectionHeight = topPad + context.w(_hasChild ? 286 : 334);

    return SizedBox(
      height: sectionHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: redHeight,
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
            right: _hasChild ? context.w(130) : context.w(70),
            child: SizedBox(
              height: context.w(50),
              child: Row(
                children: [
                  InitialAvatar(initial: _parentInitial),
                  SizedBox(width: context.w(18)),
                  Expanded(
                    child: Text(
                      _parentFirstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: context.sp(24),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 29 / 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_hasChild)
            Positioned(
              top: topPad + context.w(24),
              right: context.w(61),
              child: ChildSwitchGroup(
                childGender: _currentChild.gender,
                showAddButton: _children.length < 2,
                onSwitch: _switchChild,
                onAdd: _openTambahAnak,
              ),
            ),

          Positioned(
            top: topPad + context.w(28),
            right: context.w(27),
            child: NotificationIconButton(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NotifikasiScreen()));
              },
            ),
          ),

          Positioned(
            top: cardTop,
            left: context.w(26),
            right: context.w(26),
            child: _hasChild
                ? Container(
                    height: context.w(170),
                    padding: EdgeInsets.fromLTRB(
                      context.w(14),
                      context.w(18),
                      context.w(14),
                      context.w(14),
                    ),
                    decoration: BoxDecoration(
                      color: bgPeach,
                      borderRadius: BorderRadius.circular(context.w(30)),
                    ),
                    child: _buildChildDataContent(),
                  )
                : _buildEmptyStateCard(),
          ),

          if (_hasChild)
            Positioned(
              top: topPad + context.w(100),
              left: context.w(8),
              child: SizedBox(
                width: context.w(96),
                height: context.w(74),
                child: SvgPicture.asset(
                  _currentChild.gender == 'P'
                      ? 'assets/images/kepala_b.cewe.svg'
                      : 'assets/images/kepala_b.cowo.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= KARTU "TAMBAH DATA ANAK" (belum ada data) =================
  // Figma: 337 x 235, radius 30, plus 52.15 (alpha .8), judul 14 w600,
  // deskripsi 13/16 selebar 284 rata tengah.
  Widget _buildEmptyStateCard() {
    return Material(
      color: bgPeach,
      borderRadius: BorderRadius.circular(context.w(30)),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.w(30)),
        onTap: _openTambahAnak,
        child: SizedBox(
          height: context.w(235),
          child: Column(
            children: [
              SizedBox(height: context.w(42)),
              SvgPicture.asset(
                'assets/images/plus.svg',
                width: context.w(52.15),
                height: context.w(52.15),
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  primaryRed.withValues(alpha: 0.8),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: context.w(14)),
              Text(
                'Tambah Data Anak',
                style: google_fonts.GoogleFonts.inter(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: textBlack71,
                  height: 17 / 14,
                ),
              ),
              SizedBox(height: context.w(11)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(26.5)),
                child: Text(
                  'Belum ada data anak. Tambahkan data si kecil untuk mulai memantau tinggi, berat, lingkar kepala, LiLA, dan risiko stunting.',
                  textAlign: TextAlign.center,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w400,
                    color: textBlack71,
                    height: 16 / 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildDataContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.w(69)),
          child: SizedBox(
            height: context.w(26),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _currentChild.nama,
                            maxLines: 1,
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: context.sp(20),
                              fontWeight: FontWeight.w700,
                              color: textBrown,
                              height: 24 / 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      Container(
                        height: context.w(17),
                        padding: EdgeInsets.symmetric(horizontal: context.w(8)),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(context.w(5)),
                        ),
                        child: Text(
                          _currentChild.status,
                          maxLines: 1,
                          style: google_fonts.GoogleFonts.inter(
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(_currentChild.status),
                            height: 12 / 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => _showDataMenu = !_showDataMenu),
                  child: SizedBox(
                    width: context.w(26),
                    height: context.w(26),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/settings.svg',
                        width: context.w(25),
                        height: context.w(25),
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          textBlack71,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: context.w(69)),
          child: Row(
            children: [
              Text(
                _currentChild.gender,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w700,
                  color: textBlack71,
                  height: 13 / 11,
                ),
              ),
              SizedBox(width: context.w(4)),
              Container(
                width: context.w(4),
                height: context.w(4),
                decoration: const BoxDecoration(
                  color: textGrey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.w(4)),
              Flexible(
                child: Text(
                  _hitungUmur(_currentChild.tanggalLahir),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w700,
                    color: textBlack71,
                    height: 13 / 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(17)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Berat', _currentChild.berat, 'kg'),
              _buildStatItem('Tinggi', _currentChild.tinggi, 'cm'),
              _buildStatItem('Kepala', _currentChild.kepala, 'cm'),
              _buildStatItem('LiLA', _currentChild.lila, 'cm'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          style: google_fonts.GoogleFonts.inter(
            fontSize: context.sp(10),
            fontWeight: FontWeight.w500,
            color: textBlack71,
            height: 12 / 10,
          ),
        ),
        SizedBox(height: context.w(8)),
        Container(
          width: context.w(60),
          height: context.w(60),
          padding: EdgeInsets.symmetric(horizontal: context.w(4)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.w(5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w700,
                    color: textBlack,
                    height: 24 / 20,
                  ),
                ),
              ),
              Text(
                unit,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: context.sp(9),
                  fontWeight: FontWeight.w500,
                  color: textGrey,
                  height: 11 / 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    final menus = _recommendedMenus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.w(20)),
        Padding(
          padding: EdgeInsets.only(
            left: context.w(30),
            right: context.w(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Rekomendasi Menu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    color: textBlack,
                    height: 19 / 16,
                  ),
                ),
              ),
              SizedBox(width: context.w(8)),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MenuScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(4),
                    vertical: context.w(4),
                  ),
                  child: Text(
                    'Jelajahi Menu',
                    maxLines: 1,
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w400,
                      color: textBlack,
                      height: 13 / 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.w(21)),
        SizedBox(
          height: context.w(192),
          child: menus.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(30)),
                    child: Text(
                      _recommendationMessage.isNotEmpty
                          ? _recommendationMessage
                          : 'Belum ada rekomendasi menu untuk anak ini.',
                      textAlign: TextAlign.center,
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w500,
                        color: textBlack71,
                      ),
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: context.w(30)),
                  children: [
                    for (int i = 0; i < menus.length; i++) ...[
                      if (i > 0) SizedBox(width: context.w(9)),
                      MenuRecommendationCard(
                        title: menus[i]['title']!,
                        imagePath: menus[i]['imagePath']!,
                        badge: menus[i]['badge']!,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => DetailResepScreen(
                              title: menus[i]['title']!,
                              imagePath: menus[i]['imagePath']!,
                              badge: menus[i]['badge']!,
                            ),
                          ));
                        },
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  // ================= BANNER RIWAYAT PEMERIKSAAN =================
  // empty = true  -> versi Figma "belum ada data":
  //   judul "Riwayat pemeriksaan" (lebar 223), tinggi min 168, jarak 16 & 19.
  Widget _buildStuntingBanner({bool empty = false}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: context.w(37)),
      constraints: BoxConstraints(minHeight: context.w(empty ? 168 : 160)),
      decoration: BoxDecoration(
        color: bgTeal,
        borderRadius: BorderRadius.circular(context.w(30)),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: context.w(3),
            top: 0,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/penggaris.png',
                width: context.w(143),
                height: context.w(143),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(25),
              context.w(25),
              context.w(25),
              context.w(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: context.w(empty ? 223 : 200),
                  child: Text(
                    empty
                        ? 'Riwayat pemeriksaan'
                        : 'Riwayat pemeriksaan stunting',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w700,
                      color: textBlack,
                      height: 19 / 16,
                    ),
                  ),
                ),
                SizedBox(height: context.w(empty ? 16 : 9)),
                SizedBox(
                  width: context.w(157),
                  child: Text(
                    'Update dan Check History',
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w500,
                      color: textBlack50,
                      height: 16 / 13,
                    ),
                  ),
                ),
                SizedBox(height: context.w(empty ? 19 : 14)),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.w(20)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(context.w(20)),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              const RiwayatScreen(initialTab: 1)));
                    },
                    child: Container(
                      width: context.w(171),
                      height: context.w(35),
                      alignment: Alignment.center,
                      child: Text(
                        'Cek Detail',
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: textBlack50,
                          height: 18 / 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU "MULAI DALAM 3 LANGKAH" (belum ada data) =================
  // Figma: 317 x 174, radius 20, warna #DDF3F1, judul 16 w600 #1A7772,
  // 3 baris langkah (lingkaran 22 + teks 12), tiap baris setinggi 35.
  Widget _buildStepsCard() {
    TextStyle stepStyle({FontWeight weight = FontWeight.w400}) =>
        google_fonts.GoogleFonts.inter(
          fontSize: context.sp(12),
          fontWeight: weight,
          color: tealDark,
        );

    Widget step(String no, List<InlineSpan> spans) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: context.w(35)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: context.w(22),
              height: context.w(22),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: tealDark,
                shape: BoxShape.circle,
              ),
              child: Text(
                no,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
            SizedBox(width: context.w(4)),
            Expanded(
              child: Text.rich(
                TextSpan(style: stepStyle(), children: spans),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: context.w(36.5)),
      constraints: BoxConstraints(minHeight: context.w(174)),
      padding: EdgeInsets.fromLTRB(
        context.w(12),
        context.w(24),
        context.w(12),
        context.w(24),
      ),
      decoration: BoxDecoration(
        color: bgMint,
        borderRadius: BorderRadius.circular(context.w(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: context.w(2)),
            child: Text(
              'Mulai dalam 3 langkah',
              style: google_fonts.GoogleFonts.inter(
                fontSize: context.sp(16),
                fontWeight: FontWeight.w600,
                color: tealDark,
                height: 19 / 16,
              ),
            ),
          ),
          SizedBox(height: context.w(2)),
          step('1', const [TextSpan(text: 'Tambah data anak')]),
          step('2', const [
            TextSpan(text: 'Isi tinggi dan berat, atau periksa di posyandu'),
          ]),
          step('3', [
            const TextSpan(text: 'Lihat hasil: '),
            TextSpan(
              text: 'Cek Detail Riwayat Pemeriksaan',
              style: stepStyle(weight: FontWeight.w600),
            ),
          ]),
        ],
      ),
    );
  }
}