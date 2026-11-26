import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/child_store.dart';
import '../../widgets/notification_icon.dart';
import '../home/home_ibu_screen.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/menu_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import 'detail_pemeriksaan_screen.dart';
import '../ai/tanya_ai_screen.dart';

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

// ================= MODEL ANAK RINGKAS =================
class _BabyOption {
  final int id;
  final String nama;
  final String umur;
  final String gender;
  final String alergi;
  final String birthPlace;
  final String birthDate;
  final String parentName;
  final String parentEmail;

  const _BabyOption({
    required this.id,
    required this.nama,
    required this.umur,
    required this.gender,
    required this.alergi,
    this.birthPlace = '',
    this.birthDate = '',
    this.parentName = '',
    this.parentEmail = '',
  });
}

// ================= MODEL RIWAYAT PEMERIKSAAN =================
class RiwayatItem {
  final String tglHari;
  final String tglBulan;
  final String judul;
  final String catatan;
  final String status;
  final String? catatanLengkap;
  final String beratBadan;
  final String tinggiBadan;
  final String lingkarKepala;
  final String lila;
  final String pemeriksaanBerikutnya;
  final String namaBalita;
  final String usiaBalita;
  final String jenisKelamin;
  final String namaOrangTua;
  final String tempatTglLahir;
  final String emailOrangTua;
  final List<String> bahanRekomendasi;

  const RiwayatItem({
    required this.tglHari,
    required this.tglBulan,
    required this.judul,
    required this.catatan,
    required this.status,
    this.catatanLengkap,
    this.beratBadan = '7.2',
    this.tinggiBadan = '66',
    this.lingkarKepala = '43',
    this.lila = '11.4',
    this.pemeriksaanBerikutnya = '12/10/2026',
    this.namaBalita = 'Kentoz Albaiq',
    this.usiaBalita = '10 Bulan',
    this.jenisKelamin = 'Laki-laki',
    this.namaOrangTua = 'Ajeng Febria',
    this.tempatTglLahir = 'Denpasar, 01/12/2025',
    this.emailOrangTua = 'AjengFebria01@gmail.com',
    this.bahanRekomendasi = const ['Ayam', 'Telur', 'Sayuran', 'Buah'],
  });
}

// ================= MODEL PENCARIAN AI =================
class PencarianItem {
  final int? id;
  final List<String> keywords;
  final int jumlahResep;
  final String? childName;
  final String? childAge;
  final String? childGender;
  final String? childAllergy;

  const PencarianItem({
    this.id,
    required this.keywords,
    required this.jumlahResep,
    this.childName,
    this.childAge,
    this.childGender,
    this.childAllergy,
  });
}

class PencarianGroup {
  final String hari;
  final String tanggal;
  final List<PencarianItem> items;

  const PencarianGroup({
    required this.hari,
    required this.tanggal,
    required this.items,
  });
}

class RiwayatScreen extends StatefulWidget {
  final int initialTab;

  const RiwayatScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  static const Color primaryRed    = Color(0xFFD45060);
  static const Color bgCream       = Color(0xFFFCEBD5);
  static const Color bgPinkChip    = Color(0xFFF7A497);
  static const Color chipBg        = Color(0x80F88B92);
  static const Color orangeText    = Color(0xFFE38621);
  static const Color orangeFaded   = Color(0xB3E38621);
  static const Color dividerOrange = Color(0xFFBE6D15);
  static const Color textBlack     = Color(0xFF000000);
  static const Color textDarkDate  = Color(0xFF4B5563);
  static const Color statusRed     = Color(0xFFD45060);
  static const Color statusOrange  = Color(0xFFF1A038);
  static const Color statusGreen   = Color(0xFF76C457);
  static const Color iconCircleBg  = Color(0xA3FFFFFF);

  static const List<String> _bulanPendek = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const List<String> _hariIndo = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  late int _tab;
  bool _loadingAi = false;
  bool _loadingCheckup = false;

  List<_BabyOption> _babies = [];
  int? _selectedBabyId;
  String _activeChildName = '';

  List<RiwayatItem> _riwayat = [];
  List<PencarianGroup> _pencarian = [];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _selectedBabyId = ChildStore.currentId.value;
    _activeChildName = ChildStore.currentName.value;
    ChildStore.currentId.addListener(_onActiveChildChanged);
    _initData();
  }

  // Dipanggil saat anak aktif di ChildStore berubah
  void _onActiveChildChanged() {
    if (!mounted) return;
    final newId = ChildStore.currentId.value;
    if (newId == null || newId == _selectedBabyId) return;
    _selectedBabyId = newId;
    _activeChildName = ChildStore.currentName.value;
    _initData();
  }

  @override
  void dispose() {
    ChildStore.currentId.removeListener(_onActiveChildChanged);
    super.dispose();
  }

  Future<void> _initData() async {
    await _loadBabiesAndCheckups();
    await _loadAiHistory();
  }

  int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.toLocal();
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s)?.toLocal();
  }

  String _formatHariTanggal(DateTime? dt) {
    if (dt == null) return '12 Sep 2026';
    final bulan = _bulanPendek[(dt.month - 1).clamp(0, 11)];
    return '${dt.day} $bulan ${dt.year}';
  }

  String _formatHari(DateTime? dt) {
    if (dt == null) return 'Hari Ini';
    return _hariIndo[(dt.weekday - 1).clamp(0, 6)];
  }

  String _formatTanggalPendek(DateTime? dt) {
    if (dt == null) return '12/10/2026';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  String _strVal(Map<String, dynamic> map, List<String> keys, String fallback) {
    for (final k in keys) {
      final v = map[k];
      if (v != null && v.toString().trim().isNotEmpty && v.toString() != 'null') {
        return v.toString().trim();
      }
    }
    return fallback;
  }

  List<String> _parseBahanRekomendasi(dynamic raw) {
    if (raw is List) {
      final list = raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return list;
    } else if (raw is String && raw.trim().isNotEmpty) {
      final list = raw
          .split(RegExp(r'[,;\n]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return list;
    }
    return const ['Ayam', 'Telur', 'Sayuran', 'Buah'];
  }

  String _formatGender(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'l' || lower == 'laki-laki' || lower == 'male' || lower == 'm') {
      return 'Laki-laki';
    }
    if (lower == 'p' || lower == 'perempuan' || lower == 'female' || lower == 'f') {
      return 'Perempuan';
    }
    return raw.isNotEmpty ? raw : 'Laki-laki';
  }

  // Ambil list dari berbagai kemungkinan bentuk response backend
  List? _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map) {
      const keys = ['data', 'history', 'histories', 'items', 'results', 'rows'];
      for (final k in keys) {
        final v = res[k];
        if (v is List) return v;
        if (v is Map) {
          final inner = _extractList(v);
          if (inner != null) return inner;
        }
      }
    }
    return null;
  }

  Future<void> _loadAiHistory() async {
    setState(() => _loadingAi = true);
    try {
      final activeBaby = _currentBaby;
      final activeBabyId = activeBaby?.id ?? _selectedBabyId;
      final activeChildName =
          (activeBaby?.nama ?? _activeChildName).trim().toLowerCase();

      final endpoint = activeBabyId != null
          ? '/ai/history?babyId=$activeBabyId'
          : '/ai/history';
      final res = await ApiClient.get(endpoint);
      debugPrint('[Riwayat] GET $endpoint -> $res');
      final rawList = _extractList(res);
      if (rawList != null) {
        final Map<String, List<PencarianItem>> groupedMap = {};
        final Map<String, String> hariByKey = {};

        for (final entry in rawList) {
          if (entry is! Map) continue;
          final map = Map<String, dynamic>.from(entry);

          final entryBabyId = _parseId(
            map['baby_id'] ??
                map['babyId'] ??
                (map['baby'] is Map ? (map['baby'] as Map)['id'] : null),
          );
          final entryBabyName = _strVal(
            map,
            ['child_name', 'childName', 'baby_name', 'babyName'],
            map['baby'] is Map
                ? _strVal(
                    Map<String, dynamic>.from(map['baby'] as Map),
                    ['full_name', 'fullName', 'name', 'nama'],
                    '',
                  )
                : '',
          ).toLowerCase();

          if (entryBabyId != null && activeBabyId != null) {
            if (entryBabyId != activeBabyId) continue;
          } else if (entryBabyName.isNotEmpty && activeChildName.isNotEmpty) {
            if (entryBabyName != activeChildName) continue;
          }

          final id = _parseId(map['id'] ?? map['history_id'] ?? map['historyId']);
          final dt = _parseDate(
            map['created_at'] ?? map['createdAt'] ?? map['tanggal'] ?? map['date'],
          );
          final tglLabel = _formatHariTanggal(dt);
          final hariLabel = _formatHari(dt);

          List<String> keywords = [];
          final rawKw = map['keywords'] ??
              map['ingredients'] ??
              map['bahan'] ??
              map['query'] ??
              map['prompt'];
          if (rawKw is List) {
            keywords = rawKw
                .map((e) => e?.toString().trim() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          } else if (rawKw is String && rawKw.trim().isNotEmpty) {
            // Query berupa prompt panjang (data lama) bukan daftar bahan
            if (rawKw.length <= 80) {
              keywords = rawKw
                  .split(RegExp(r'[,;\n]+'))
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }
          }
          if (keywords.isEmpty) {
            final resp = (map['response'] ?? '').toString();
            final m = RegExp(r'Nama Menu:\s*(.+)').firstMatch(resp);
            final menuName = m?.group(1)?.trim() ?? '';
            keywords = [menuName.isNotEmpty ? menuName : 'Rekomendasi AI'];
          }

          int jumlahResep = 0;
          final rawCount = map['recipe_count'] ??
              map['total_recipes'] ??
              map['jumlah_resep'] ??
              map['jumlahResep'];
          if (rawCount != null) {
            jumlahResep = int.tryParse(rawCount.toString()) ?? 0;
          }
          if (jumlahResep <= 0) {
            final rawRecipes =
                map['recipes'] ?? map['recommendations'] ?? map['menus'];
            if (rawRecipes is List && rawRecipes.isNotEmpty) {
              jumlahResep = rawRecipes.length;
            } else {
              jumlahResep = keywords.length;
            }
          }

          final item = PencarianItem(
            id: id,
            keywords: keywords,
            jumlahResep: jumlahResep,
            childName: _strVal(
              map,
              ['child_name', 'childName', 'baby_name', 'babyName'],
              activeBaby?.nama ?? 'Anak',
            ),
            childAge: _strVal(
              map,
              ['child_age', 'childAge', 'age_months', 'age'],
              activeBaby?.umur ?? '-',
            ),
            childGender: _strVal(
              map,
              ['child_gender', 'childGender', 'gender'],
              activeBaby?.gender ?? 'P',
            ),
            childAllergy: _strVal(
              map,
              ['child_allergy', 'childAllergy', 'allergy', 'alergi'],
              activeBaby?.alergi ?? '-',
            ),
          );

          groupedMap.putIfAbsent(tglLabel, () => []).add(item);
          hariByKey.putIfAbsent(tglLabel, () => hariLabel);
        }

        if (mounted) {
          final groups = groupedMap.entries
              .map(
                (e) => PencarianGroup(
                  hari: hariByKey[e.key] ?? 'Hari Ini',
                  tanggal: e.key,
                  items: e.value,
                ),
              )
              .toList();
          setState(() => _pencarian = groups);
        }
      } else {
        debugPrint('[Riwayat] Format response /ai/history tidak dikenali');
      }
    } on ApiException catch (e) {
      debugPrint('[Riwayat] ApiException /ai/history: $e');
      if (mounted) {
        setState(() => _pencarian = []);
      }
    } catch (e) {
      debugPrint('[Riwayat] Error /ai/history: $e');
      if (mounted) {
        setState(() => _pencarian = []);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingAi = false);
      }
    }
  }

  Future<void> _loadBabiesAndCheckups() async {
    setState(() => _loadingCheckup = true);
    try {
      final resBabies = await ApiClient.get('/babies');
      final rawBabies = resBabies['data'] ?? resBabies['babies'];
      if (rawBabies is List && rawBabies.isNotEmpty) {
        final parsedBabies = <_BabyOption>[];
        for (final b in rawBabies) {
          if (b is! Map) continue;
          final map = Map<String, dynamic>.from(b);
          final id = _parseId(map['id'] ?? map['baby_id'] ?? map['babyId']);
          if (id == null) continue;
          final nama = _strVal(
            map,
            ['full_name', 'name', 'nama', 'fullName'],
            'Anak',
          );
          final umurRaw = _strVal(
            map,
            ['age_months', 'ageMonths', 'age', 'umur'],
            '6',
          );
          final umur = umurRaw.toLowerCase().contains('bulan')
              ? umurRaw
              : '$umurRaw Bulan';
          final gender = _strVal(
            map,
            ['gender', 'jenis_kelamin', 'sex'],
            'Laki-laki',
          );
          final alergi = _strVal(
            map,
            ['allergies', 'allergy', 'alergi'],
            '-',
          );
          final birthPlace = _strVal(
            map,
            ['birth_place', 'birthPlace', 'tempat_lahir'],
            '',
          );
          final birthDate = _strVal(
            map,
            ['birth_date_str', 'birth_date', 'birthDate', 'tanggal_lahir'],
            '',
          );
          final parentName = _strVal(
            map,
            ['parent_name', 'parentName', 'nama_orang_tua'],
            '',
          );
          final parentEmail = _strVal(
            map,
            ['parent_email', 'parentEmail', 'email'],
            '',
          );
          parsedBabies.add(
            _BabyOption(
              id: id,
              nama: nama,
              umur: umur,
              gender: gender,
              alergi: alergi,
              birthPlace: birthPlace,
              birthDate: birthDate,
              parentName: parentName,
              parentEmail: parentEmail,
            ),
          );
        }

        if (parsedBabies.isNotEmpty && mounted) {
          // Prioritas: ID di store, lalu nama, terakhir anak pertama
          final storeId = ChildStore.currentId.value;
          final activeName = _activeChildName.trim().toLowerCase();
          _BabyOption selectedBaby = parsedBabies.first;

          bool found = false;
          if (storeId != null) {
            for (final b in parsedBabies) {
              if (b.id == storeId) {
                selectedBaby = b;
                found = true;
                break;
              }
            }
          }
          if (!found && activeName.isNotEmpty) {
            for (final b in parsedBabies) {
              if (b.nama.trim().toLowerCase() == activeName) {
                selectedBaby = b;
                break;
              }
            }
          }

          setState(() {
            _babies = parsedBabies;
            _selectedBabyId = selectedBaby.id;
            _activeChildName = selectedBaby.nama;
          });
          await _loadCheckupsForBaby(selectedBaby.id);
          return;
        }
      }
      if (mounted) {
        setState(() {
          _babies = [];
          _selectedBabyId = null;
          _activeChildName = '';
          _riwayat = [];
        });
      }
    } on ApiException {
      if (mounted) {
        setState(() {
          _babies = [];
          _selectedBabyId = null;
          _activeChildName = '';
          _riwayat = [];
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _babies = [];
          _selectedBabyId = null;
          _activeChildName = '';
          _riwayat = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCheckup = false);
      }
    }
  }

  Future<void> _loadCheckupsForBaby(int babyId) async {
    setState(() => _loadingCheckup = true);
    try {
      final res = await ApiClient.get('/babies/$babyId/checkups');
      final rawList = res['data'] ?? res['checkups'] ?? res['items'];
      if (rawList is List) {
        _BabyOption? matchedBaby;
        for (final b in _babies) {
          if (b.id == babyId) {
            matchedBaby = b;
            break;
          }
        }

        final parsed = <RiwayatItem>[];
        for (final entry in rawList) {
          if (entry is! Map) continue;
          final map = Map<String, dynamic>.from(entry);
          final dt = _parseDate(
            map['checkup_date_str'] ??
                map['checkup_date'] ??
                map['checkupDate'] ??
                map['date'] ??
                map['created_at'],
          );
          final tglHari = dt != null ? dt.day.toString() : '12';
          final tglBulan = dt != null
              ? _bulanPendek[(dt.month - 1).clamp(0, 11)]
              : 'Sep';

          final ageMonthsRaw = _strVal(
            map,
            ['baby_age_months', 'babyAgeMonths', 'age_months', 'umur'],
            '',
          );
          final usiaLabel = ageMonthsRaw.isNotEmpty
              ? (ageMonthsRaw.toLowerCase().contains('bulan')
                  ? ageMonthsRaw
                  : '$ageMonthsRaw Bulan')
              : (matchedBaby?.umur ?? '10 Bulan');

          final judul = _strVal(
            map,
            ['title', 'judul', 'checkup_title'],
            ageMonthsRaw.isNotEmpty
                ? 'Pemeriksaan bulan ke-$ageMonthsRaw'
                : 'Pemeriksaan anak',
          );

          final statusRaw = _strVal(
            map,
            ['condition_status', 'conditionStatus', 'status'],
            'Normal',
          );
          String status = 'Normal';
          final lowerStatus = statusRaw.toLowerCase();
          if (lowerStatus.contains('stunting') &&
              !lowerStatus.contains('risiko')) {
            status = 'Stunting';
          } else if (lowerStatus.contains('risiko') ||
              lowerStatus.contains('kurang')) {
            status = 'Berisiko';
          } else if (statusRaw.isNotEmpty) {
            status = statusRaw[0].toUpperCase() +
                statusRaw.substring(1).toLowerCase();
          }

          final catatanFull = _strVal(
            map,
            ['kader_notes', 'kaderNotes', 'notes', 'catatan', 'follow_up'],
            '-',
          );
          final ringkas =
              catatanFull == '-' ? 'Catatan: -' : 'Catatan: $catatanFull';

          final berat = _strVal(
            map,
            ['weight_kg', 'weightKg', 'weight', 'berat_badan'],
            '7.2',
          );
          final tinggi = _strVal(
            map,
            ['height_cm', 'heightCm', 'height', 'tinggi_badan'],
            '66',
          );
          final lingkarKepala = _strVal(
            map,
            [
              'head_circumference_cm',
              'headCircumferenceCm',
              'lingkar_kepala',
            ],
            '43',
          );
          final lila = _strVal(
            map,
            ['lila_cm', 'lilaCm', 'lila', 'arm_circumference_cm'],
            '11.4',
          );

          final nextDateStr = _strVal(
            map,
            ['next_checkup_date_str', 'nextCheckupDateStr'],
            '',
          );
          final nextDateParsed = _parseDate(
            map['next_checkup_date'] ?? map['nextCheckupDate'],
          );
          final pemeriksaanBerikutnya = nextDateStr.isNotEmpty
              ? nextDateStr
              : (nextDateParsed != null
                  ? _formatTanggalPendek(nextDateParsed)
                  : '12/10/2026');

          final namaBalita = _strVal(
            map,
            ['baby_name', 'babyName', 'full_name'],
            matchedBaby?.nama ?? 'Kentoz Albaiq',
          );
          final jenisKelamin = _formatGender(
            _strVal(
              map,
              ['baby_gender', 'babyGender', 'gender'],
              matchedBaby?.gender ?? 'Laki-laki',
            ),
          );
          final namaOrangTua = _strVal(
            map,
            ['parent_name', 'parentName'],
            matchedBaby?.parentName.isNotEmpty == true
                ? matchedBaby!.parentName
                : 'Ajeng Febria',
          );
          final emailOrangTua = _strVal(
            map,
            ['parent_email', 'parentEmail'],
            matchedBaby?.parentEmail.isNotEmpty == true
                ? matchedBaby!.parentEmail
                : 'AjengFebria01@gmail.com',
          );

          final birthPlace = _strVal(
            map,
            ['baby_birth_place', 'babyBirthPlace'],
            matchedBaby?.birthPlace ?? '',
          );
          final birthDate = _strVal(
            map,
            ['baby_birth_date_str', 'babyBirthDateStr', 'baby_birth_date'],
            matchedBaby?.birthDate ?? '',
          );
          final tempatTglLahir =
              (birthPlace.isNotEmpty && birthDate.isNotEmpty)
                  ? '$birthPlace, $birthDate'
                  : (birthPlace.isNotEmpty
                      ? birthPlace
                      : (birthDate.isNotEmpty
                          ? birthDate
                          : 'Denpasar, 01/12/2025'));

          final bahanRekomendasi = _parseBahanRekomendasi(
            map['recommended_food'] ?? map['recommendedFood'],
          );

          parsed.add(
            RiwayatItem(
              tglHari: tglHari,
              tglBulan: tglBulan,
              judul: judul,
              catatan: ringkas,
              status: status,
              catatanLengkap: catatanFull,
              beratBadan: berat,
              tinggiBadan: tinggi,
              lingkarKepala: lingkarKepala,
              lila: lila,
              pemeriksaanBerikutnya: pemeriksaanBerikutnya,
              namaBalita: namaBalita,
              usiaBalita: usiaLabel,
              jenisKelamin: jenisKelamin,
              namaOrangTua: namaOrangTua,
              tempatTglLahir: tempatTglLahir,
              emailOrangTua: emailOrangTua,
              bahanRekomendasi: bahanRekomendasi,
            ),
          );
        }

        if (mounted) {
          setState(() => _riwayat = parsed);
        }
      }
    } on ApiException {
      if (mounted) {
        setState(() => _riwayat = []);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _riwayat = []);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCheckup = false);
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Stunting':
        return statusRed;
      case 'Berisiko':
        return statusOrange;
      default:
        return statusGreen;
    }
  }

  _BabyOption? get _currentBaby {
    if (_babies.isEmpty) return null;
    for (final b in _babies) {
      if (b.id == _selectedBabyId) return b;
    }
    return _babies.first;
  }

  @override
  Widget build(BuildContext context) {
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
                  child: LayoutBuilder(
                    builder: (context, viewportConstraints) {
                      final isEmptyState = (_tab == 1 &&
                              !_loadingCheckup &&
                              _riwayat.isEmpty) ||
                          (_tab == 0 && !_loadingAi && _pencarian.isEmpty);

                      return RefreshIndicator(
                        color: primaryRed,
                        onRefresh: () async {
                          await _loadBabiesAndCheckups();
                          await _loadAiHistory();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: isEmptyState
                              ? ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: viewportConstraints.maxHeight,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: context.w(115),
                                    ),
                                    child: Center(
                                      child: _tab == 1
                                          ? _buildEmptyPemeriksaan(context)
                                          : _buildEmptyResepAi(context),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_tab == 1) ...[
                                      if (_loadingCheckup && _riwayat.isEmpty) ...[
                                        SizedBox(height: context.w(80)),
                                        const Center(
                                          child: CircularProgressIndicator(
                                            color: primaryRed,
                                          ),
                                        ),
                                      ] else ...[
                                        SizedBox(height: context.w(32)),
                                        for (int i = 0; i < _riwayat.length; i++) ...[
                                          if (i > 0) SizedBox(height: context.w(27)),
                                          _buildRiwayatCard(context, _riwayat[i]),
                                        ],
                                      ],
                                    ] else ...[
                                      if (_loadingAi && _pencarian.isEmpty) ...[
                                        SizedBox(height: context.w(80)),
                                        const Center(
                                          child: CircularProgressIndicator(
                                            color: primaryRed,
                                          ),
                                        ),
                                      ] else ...[
                                        SizedBox(height: context.w(32)),
                                        for (int i = 0; i < _pencarian.length; i++) ...[
                                          if (i > 0) SizedBox(height: context.w(28)),
                                          _buildPencarianGroup(context, _pencarian[i]),
                                        ],
                                      ],
                                    ],
                                    SizedBox(height: context.w(140)),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            BottomNav(
              currentIndex: 3,
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
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeIbuScreen()),
                    (r) => false,
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

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      height: topPad + context.w(210),
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
            top: topPad + context.w(30),
            left: context.w(28),
            right: context.w(16),
            child: SizedBox(
              height: context.w(50),
              child: Row(
                children: [
                  Text(
                    'Riwayat',
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
            top: topPad + context.w(110),
            left: context.w(38),
            right: context.w(38),
            child: Container(
              height: context.w(75),
              padding: EdgeInsets.all(context.w(8)),
              decoration: BoxDecoration(
                color: bgCream,
                borderRadius: BorderRadius.circular(context.w(20)),
              ),
              child: Row(
                children: [
                  _buildTab(context, 0, 'Resep AI', 'Resep yang kamu buat'),
                  _buildTab(context, 1, 'Pemeriksaan', 'Hasil ukur dari posyandu'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String title, String subtitle) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _tab = index);
          // Muat ulang histori AI tiap kali tab Resep AI dibuka
          if (index == 0) _loadAiHistory();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: context.w(16)),
          decoration: BoxDecoration(
            color: active ? bgPinkChip : Colors.transparent,
            borderRadius: BorderRadius.circular(context.w(15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w600,
                  color: textBlack,
                  height: 18 / 15,
                ),
              ),
              SizedBox(height: context.w(4)),
              Text(
                subtitle,
                textAlign: TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: context.sp(8.47),
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: 0.5),
                  height: 10 / 8.47,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATE: RESEP AI =================
  Widget _buildEmptyResepAi(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.w(112),
            height: context.w(112),
            decoration: const BoxDecoration(
              color: Color(0x80FCEBD5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/riwayat-ai.svg',
                width: context.w(62),
                height: context.w(62),
                colorFilter: const ColorFilter.mode(
                  primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: context.w(22)),
          Text(
            'Belum Ada Resep AI',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 22 / 18,
            ),
          ),
          SizedBox(height: context.w(8)),
          SizedBox(
            width: context.w(290),
            child: Text(
              'Yuk, buat resep MPASI praktis sesuai kebutuhan si kecil sekarang!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.5),
                height: 17 / 13,
              ),
            ),
          ),
          SizedBox(height: context.w(20)),
          SizedBox(
            height: context.w(44),
            child: ElevatedButton(
              onPressed: () {
                final baby = _currentBaby;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TanyaAiScreen(
                      child: AiChildInfo(
                        id: baby?.id,
                        nama: baby?.nama ?? 'Anak',
                        umur: baby?.umur ?? '-',
                        gender: baby?.gender ?? 'P',
                        alergi: baby?.alergi ?? '',
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: context.w(26)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.w(30)),
                ),
              ),
              child: Text(
                'Mulai Buat Resep',
                style: GoogleFonts.inter(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 20 / 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY STATE: PEMERIKSAAN =================
  Widget _buildEmptyPemeriksaan(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.w(112),
            height: context.w(112),
            decoration: const BoxDecoration(
              color: Color(0x80FCEBD5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/riwayat-pemeriksaan.svg',
                width: context.w(62),
                height: context.w(62),
                colorFilter: const ColorFilter.mode(
                  primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: context.w(22)),
          Text(
            'Belum Ada Catatan Pemeriksaan',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 22 / 18,
            ),
          ),
          SizedBox(height: context.w(8)),
          SizedBox(
            width: context.w(295),
            child: Text(
              'Pantau terus berat, tinggi, dan tumbuh kembang si kecil dari tiap kunjungan posyandu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.5),
                height: 17 / 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PENCARIAN GROUP CARD =================
  Widget _buildPencarianGroup(BuildContext context, PencarianGroup group) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(31)),
      child: Container(
        decoration: BoxDecoration(
          color: bgCream,
          borderRadius: BorderRadius.circular(context.w(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          context.w(7),
          context.w(12),
          context.w(7),
          context.w(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: context.w(7),
                bottom: context.w(10),
              ),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w700,
                    color: orangeText,
                    height: 19 / 15,
                  ),
                  children: [
                    TextSpan(text: group.hari),
                    TextSpan(
                      text: '  ${group.tanggal}',
                      style: GoogleFonts.inter(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w400,
                        color: orangeFaded,
                        height: 19 / 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: context.w(1), color: dividerOrange),
            for (int i = 0; i < group.items.length; i++) ...[
              _buildPencarianItem(context, group.items[i]),
              if (i < group.items.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: context.w(37)),
                  child: Container(height: context.w(1), color: dividerOrange),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= PENCARIAN ITEM =================
  Widget _buildPencarianItem(BuildContext context, PencarianItem item) {
    return GestureDetector(
      onTap: () async {
        var bahanText = item.keywords.join(', ');
        if (item.id != null) {
          try {
            final detailRes = await ApiClient.get('/ai/history/${item.id}');
            final dataMap = detailRes['data'] is Map
                ? Map<String, dynamic>.from(detailRes['data'] as Map)
                : detailRes;
            final rawIng = dataMap['ingredients'] ??
                dataMap['bahan'] ??
                dataMap['keywords'];
            if (rawIng is List && rawIng.isNotEmpty) {
              bahanText = rawIng
                  .map((e) => e?.toString().trim() ?? '')
                  .where((e) => e.isNotEmpty)
                  .join(', ');
            } else if (rawIng is String && rawIng.trim().isNotEmpty) {
              bahanText = rawIng.trim();
            }
          } on ApiException {
            // Gunakan bahan dari item histori jika request detail gagal
          } catch (_) {
            // Abaikan error tak terduga
          }
        }

        if (!context.mounted) return;
        final baby = _currentBaby;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TanyaAiScreen(
              child: AiChildInfo(
                id: baby?.id,
                nama: baby?.nama ?? item.childName ?? 'Anak',
                umur: baby?.umur ?? item.childAge ?? '-',
                gender: baby?.gender ?? item.childGender ?? 'P',
                alergi: baby?.alergi ?? item.childAllergy ?? '',
              ),
              initialBahan: bahanText,
              initialHistoryId: item.id,
            ),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, context.w(12), 0, context.w(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: context.w(30),
              height: context.w(30),
              decoration: const BoxDecoration(
                color: iconCircleBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/AI.png',
                  width: context.w(20),
                  height: context.w(20),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: context.w(13)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: context.w(6),
                    runSpacing: context.w(6),
                    children: item.keywords.map((k) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(12),
                          vertical: context.w(4),
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          border: Border.all(
                            color: primaryRed,
                            width: context.w(0.35),
                          ),
                          borderRadius: BorderRadius.circular(context.w(21)),
                        ),
                        child: Text(
                          k,
                          style: GoogleFonts.inter(
                            fontSize: context.sp(8.5),
                            fontWeight: FontWeight.w600,
                            color: textBlack,
                            height: 10 / 8.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.w(6)),
                  Text(
                    '${item.jumlahResep} Resep ditemukan',
                    style: GoogleFonts.inter(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w500,
                      color: textBlack,
                      height: 10 / 8.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: context.w(26),
              color: textBlack,
            ),
            SizedBox(width: context.w(8)),
          ],
        ),
      ),
    );
  }

  // ================= KARTU RIWAYAT PEMERIKSAAN =================
  Widget _buildRiwayatCard(BuildContext context, RiwayatItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(31)),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailPemeriksaanScreen(
                tglHari: item.tglHari,
                tglBulan: item.tglBulan,
                judul: item.judul,
                status: item.status,
                beratBadan: item.beratBadan,
                tinggiBadan: item.tinggiBadan,
                lingkarKepala: item.lingkarKepala,
                lila: item.lila,
                catatan: item.catatanLengkap ?? '-',
                pemeriksaanBerikutnya: item.pemeriksaanBerikutnya,
              ),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: BoxConstraints(minHeight: context.w(105)),
          padding: EdgeInsets.symmetric(
            horizontal: context.w(18),
            vertical: context.w(21),
          ),
          decoration: BoxDecoration(
            color: bgCream,
            borderRadius: BorderRadius.circular(context.w(20)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: context.w(63)),
                width: context.w(59),
                padding: EdgeInsets.symmetric(vertical: context.w(6)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.w(10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.tglHari,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w600,
                        color: textDarkDate,
                        height: 18 / 15,
                      ),
                    ),
                    Text(
                      item.tglBulan,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w600,
                        color: textDarkDate,
                        height: 18 / 15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.w(15)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.judul,
                            style: GoogleFonts.inter(
                              fontSize: context.sp(15),
                              fontWeight: FontWeight.w600,
                              color: textBlack,
                              height: 18 / 15,
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(12),
                            vertical: context.w(3),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(context.w(10)),
                          ),
                          child: Text(
                            item.status,
                            style: GoogleFonts.inter(
                              fontSize: context.sp(11),
                              fontWeight: FontWeight.w500,
                              color: _statusColor(item.status),
                              height: 13 / 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.w(9)),
                    Text(
                      item.catatan,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w400,
                        color: textBlack,
                        height: 13 / 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.w(12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Detail',
                          style: GoogleFonts.inter(
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.w500,
                            color: textBlack,
                            height: 13 / 11,
                          ),
                        ),
                        SizedBox(width: context.w(4)),
                        Icon(
                          Icons.chevron_right,
                          size: context.w(18),
                          color: textBlack,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}