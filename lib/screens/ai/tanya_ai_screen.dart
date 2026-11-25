import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/network/api_client.dart';
import '../../services/ai_service.dart';

// ================= MODEL CHILD (untuk AI) =================
class AiChildInfo {
  /// id anak di backend (opsional; kalau kosong, dicari lewat nama anak)
  final int? id;
  final String nama;
  final String umur;
  final String gender;
  final String status;
  final String alergi;

  const AiChildInfo({
    this.id,
    required this.nama,
    required this.umur,
    required this.gender,
    this.status = '',
    this.alergi = '',
  });
}

// ================= MODEL CHAT SESSION =================
class _ChatSession {
  String bahan;
  final String alergi;
  DateTime waktu;
  final bool isDetail;
  bool isLoading;
  String? error;
  AiMenu? menu;

  _ChatSession({
    required this.bahan,
    required this.alergi,
    DateTime? waktu,
    this.isDetail = false,
    this.isLoading = true,
    this.error,
    this.menu,
  }) : waktu = waktu ?? DateTime.now();
}

// ================= STATE =================
enum _AiStep { formEmpty, formFilled, result, detail }

class TanyaAiScreen extends StatefulWidget {
  final AiChildInfo child;

  /// Dipakai kalau layar dibuka dari Riwayat (mencocokkan riwayat lewat bahan)
  final String? initialBahan;

  /// Dipakai kalau id riwayat diketahui (lebih tepat daripada initialBahan)
  final int? initialHistoryId;

  const TanyaAiScreen({
    super.key,
    required this.child,
    this.initialBahan,
    this.initialHistoryId,
  });

  @override
  State<TanyaAiScreen> createState() => _TanyaAiScreenState();
}

class _TanyaAiScreenState extends State<TanyaAiScreen> {
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgInput = Color(0x4DD9D9D9);
  static const Color textBlack = Color(0xFF000000);
  static const Color textGrey = Color(0xFF8F8F8F);
  static const Color textMuted = Color(0xFF9E5665);
  static const Color chipBg = Color(0x80F88B92);

  static const List<String> _namaHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const List<String> _namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  final _alergiC = TextEditingController();
  final _bahanC = TextEditingController();

  late _AiStep _step;
  String _alergiFinal = '';

  final List<_ChatSession> _chatHistory = [];

  // Data anak dari backend
  int? _babyId;
  String? _babyError;
  String? _kondisi; // normal / berisiko / stunting
  String _umur = ''; // umur yang tampil (diselaraskan dengan Home)

  // Riwayat dari backend
  List<AiHistoryItem> _history = [];
  bool _historyLoading = false;
  String? _historyError;
  final ValueNotifier<int> _historyTick = ValueNotifier<int>(0);

  final ScrollController _scroll = ScrollController();
  bool _showScrollDown = false;

  /// True kalau layar ini dibuka dari Riwayat (bukan dari "New chat").
  bool _openedFromHistory = false;

  @override
  void initState() {
    super.initState();

    _umur = widget.child.umur;
    if (widget.child.status.trim().isNotEmpty) {
      _kondisi = widget.child.status.trim();
    }
    _syncAnak(); // selaraskan data anak dari backend

    // 1) Inisialisasi alergi & step awal
    if (widget.child.alergi.isNotEmpty) {
      _alergiC.text = widget.child.alergi;
      _alergiFinal = widget.child.alergi;
      _step = _AiStep.formFilled;
    } else {
      _step = _AiStep.formEmpty;
    }

    // 2) Kalau dibuka dari Riwayat -> langsung tampilkan detail riwayat
    final init = widget.initialBahan?.trim() ?? '';
    if (init.isNotEmpty || widget.initialHistoryId != null) {
      _openedFromHistory = true;
      _alergiFinal = widget.child.alergi;
      _alergiC.text = widget.child.alergi;
      final session = _ChatSession(
        bahan: init.isEmpty ? '-' : init,
        alergi: _alergiFinal,
        isDetail: true,
        isLoading: true,
      );
      _chatHistory
        ..clear()
        ..add(session);
      _step = _AiStep.detail;
      _loadInitial(session);
    }

    _bahanC.addListener(() => setState(() {}));
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _alergiC.dispose();
    _bahanC.dispose();
    _scroll.dispose();
    _historyTick.dispose();
    super.dispose();
  }

  // ================= HELPER TAMPILAN =================
  String get _kondisiLabel {
    final raw = (_kondisi ?? '').trim();
    switch (raw.toLowerCase()) {
      case 'normal':
        return 'Normal';
      case 'berisiko':
        return 'Berisiko';
      case 'stunting':
        return 'Stunting';
      default:
        return raw.isEmpty ? '-' : raw;
    }
  }

  Color get _kondisiColor {
    switch ((_kondisi ?? '').trim().toLowerCase()) {
      case 'normal':
        return const Color(0xFF88BBDC);
      case 'berisiko':
        return const Color(0xFFFFD444);
      case 'stunting':
        return const Color(0xFFDD2E44);
      default:
        return const Color(0xFFD9D9D9);
    }
  }

  bool get _sedangMemuat => _chatHistory.any((s) => s.isLoading);

  String _formatBahan(String input) {
    if (input.isEmpty) return 'Bahan Utama';
    final parts = input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Bahan Utama';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase() + parts[0].substring(1).toLowerCase();
    } else if (parts.length == 2) {
      final p1 =
          parts[0][0].toUpperCase() + parts[0].substring(1).toLowerCase();
      final p2 =
          parts[1][0].toUpperCase() + parts[1].substring(1).toLowerCase();
      return '$p1 dan $p2';
    }
    return input;
  }

  // "10.20 AM"
  String _formatJam(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.hour < 12 ? 'AM' : 'PM';
    return '$h.$m $ap';
  }

  // "Hari Ini", "Kemarin", "Sabtu, 12 Sep"
  String _labelTanggal(DateTime? d) {
    if (d == null) return 'Sebelumnya';
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    final hari = DateTime(d.year, d.month, d.day);
    final selisih = hariIni.difference(hari).inDays;
    if (selisih == 0) return 'Hari Ini';
    if (selisih == 1) return 'Kemarin';
    final base = '${_namaHari[d.weekday - 1]}, ${d.day} ${_namaBulan[d.month - 1]}';
    return d.year == now.year ? base : '$base ${d.year}';
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    final show = p.maxScrollExtent - p.pixels > 60;
    if (show != _showScrollDown) setState(() => _showScrollDown = show);
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void _scrollToBottomDelayed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= DATA DARI BACKEND =================

  Future<void> _syncAnak() async {
    if (widget.child.id != null) {
      _babyId ??= widget.child.id;
      return;
    }

    final r = await AiService.cariBabyId(widget.child.nama);
    if (!mounted) return;

    if (r.id != null) {
      setState(() {
        _babyId ??= r.id;
        _babyError = null;
      });
    } else if (_babyId == null) {
      _babyError = r.error;
    }
  }

  Future<int?> _resolveBabyId() async {
    if (_babyId != null) return _babyId;
    if (widget.child.id != null) {
      _babyId = widget.child.id;
      return _babyId;
    }
    final r = await AiService.cariBabyId(widget.child.nama);
    if (r.id != null) {
      _babyId = r.id;
      _babyError = null;
    } else {
      _babyError = r.error;
    }
    return _babyId;
  }

  int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  Future<Set<int>> _fetchAllowedHistoryIdsForChild(int? babyId) async {
    final ids = <int>{};
    try {
      final res = await ApiClient.get(
        '/ai/history',
        query: babyId != null ? {'babyId': babyId} : null,
      );
      final rawList = res['data'] ?? res['history'] ?? res['items'];
      if (rawList is! List) return ids;

      final targetName = widget.child.nama.trim().toLowerCase();
      for (final entry in rawList) {
        if (entry is! Map) continue;
        final map = Map<String, dynamic>.from(entry);
        final id = _parseId(map['id'] ?? map['history_id'] ?? map['historyId']);
        if (id == null) continue;

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

        if (babyId != null) {
          if (entryBabyId != null) {
            if (entryBabyId == babyId) ids.add(id);
          } else if (entryBabyName.isNotEmpty && targetName.isNotEmpty) {
            if (entryBabyName == targetName) ids.add(id);
          }
        } else if (entryBabyName.isNotEmpty && targetName.isNotEmpty) {
          if (entryBabyName == targetName) ids.add(id);
        } else {
          ids.add(id);
        }
      }
    } catch (_) {
      // Abaikan jika gagal menyaring riwayat per anak
    }
    return ids;
  }

  Future<void> _loadHistory() async {
    if (_historyLoading) return;
    _historyLoading = true;
    _historyError = null;
    _historyTick.value++;

    final babyId = await _resolveBabyId();
    final allowedIds = await _fetchAllowedHistoryIdsForChild(babyId);
    final result = await AiService.riwayat();
    if (!mounted) return;

    _historyLoading = false;
    if (result.error != null) {
      _historyError = result.error;
    } else {
      _history = result.items
          .where((item) => allowedIds.contains(item.id))
          .toList();
    }
    _historyTick.value++;
  }

  // Memuat detail riwayat saat layar dibuka dari halaman Riwayat
  Future<void> _loadInitial(_ChatSession session) async {
    AiHistoryItem? item;
    String? error;

    if (widget.initialHistoryId != null) {
      final r = await AiService.detailRiwayat(widget.initialHistoryId!);
      item = r.item;
      error = r.error;
    } else {
      final babyId = await _resolveBabyId();
      final allowedIds = await _fetchAllowedHistoryIdsForChild(babyId);
      final r = await AiService.riwayat();
      error = r.error;
      final filteredItems = r.items
          .where((h) => allowedIds.contains(h.id))
          .toList();
      final cari = session.bahan.trim().toLowerCase();
      for (final h in filteredItems) {
        if (h.bahan.trim().toLowerCase() == cari) {
          item = h; // riwayat terbaru yang bahannya sama
          break;
        }
      }
      if (r.error == null) _history = filteredItems;
    }

    if (!mounted) return;
    setState(() {
      session.isLoading = false;
      if (item != null) {
        session.bahan = item.bahan;
        session.menu = item.menu;
        if (item.createdAt != null) session.waktu = item.createdAt!;
      } else {
        session.error = error ?? 'Riwayat pencarian tidak ditemukan.';
      }
    });
  }

  Future<void> _requestAI(_ChatSession session) async {
    final babyId = await _resolveBabyId();
    if (!mounted) return;

    if (babyId == null) {
      setState(() {
        session.isLoading = false;
        session.error = _babyError ?? 'Data anak tidak ditemukan.';
      });
      _scrollToBottomDelayed();
      return;
    }

    final result = await AiService.rekomendasi(
      babyId: babyId,
      bahan: session.bahan,
      alergi: session.alergi,
    );
    if (!mounted) return;

    setState(() {
      session.isLoading = false;
      if (result.error != null) {
        session.error = result.error;
      } else {
        session.menu = AiMenu.parse(result.text ?? '');
        session.waktu = DateTime.now();

        // kondisi dari AI hanya dipakai kalau kondisi dari Home/backend belum ada
        final k = result.kondisi;
        if ((_kondisi ?? '').trim().isEmpty &&
            k != null &&
            k.trim().isNotEmpty) {
          _kondisi = k.trim();
        }
      }
    });
    _scrollToBottomDelayed();

    // riwayat sudah tersimpan di backend -> muat ulang daftar
    if (result.error == null) _loadHistory();
  }

  void _retry(_ChatSession session) {
    setState(() {
      session.isLoading = true;
      session.error = null;
    });
    if (session.isDetail) {
      _loadInitial(session);
    } else {
      _requestAI(session);
    }
  }

  Future<void> _hapusHistory(AiHistoryItem item) async {
    final error = await AiService.hapusRiwayat(item.id);
    if (!mounted) return;
    if (error != null) {
      _snack(error);
      return;
    }
    _history = _history.where((e) => e.id != item.id).toList();
    _historyTick.value++;
  }

  // ================= DETAIL =================
  void _openDetail(AiHistoryItem item) {
    FocusScope.of(context).unfocus();
    _bahanC.clear();

    final alergi =
        _alergiFinal.isNotEmpty ? _alergiFinal : widget.child.alergi;

    setState(() {
      _alergiFinal = alergi;
      _alergiC.text = alergi;
      _chatHistory
        ..clear()
        ..add(_ChatSession(
          bahan: item.bahan,
          alergi: alergi,
          waktu: item.createdAt,
          isDetail: true,
          isLoading: false,
          menu: item.menu,
        ));
      _step = _AiStep.detail;
      _openedFromHistory = false; // buka dari panel riwayat internal
    });
    _scrollToBottomDelayed();
  }

  void _closeDetail() {
    FocusScope.of(context).unfocus();
    _bahanC.clear();

    // Kalau dibuka dari Riwayat, tombol back = keluar halaman
    if (_openedFromHistory) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _step =
          _alergiFinal.isNotEmpty ? _AiStep.formFilled : _AiStep.formEmpty;
      _chatHistory.clear();
      _showScrollDown = false;
    });
  }

  // ================= SUBMIT =================
  void _submitFromEmpty() {
    FocusScope.of(context).unfocus();
    if (_sedangMemuat) return;

    final alergi = _alergiC.text.trim();
    final bahan = _bahanC.text.trim();

    if (bahan.isEmpty) {
      _snack('Isi bahan di rumah dulu ya');
      return;
    }

    _bahanC.clear();
    final newSession = _ChatSession(bahan: bahan, alergi: alergi);

    setState(() {
      _alergiFinal = alergi;
      _chatHistory
        ..clear()
        ..add(newSession);
      _step = _AiStep.result;
    });

    _scrollToBottomDelayed();
    _requestAI(newSession);
  }

  void _submitFromFilled() {
    FocusScope.of(context).unfocus();
    if (_sedangMemuat) return;

    final bahan = _bahanC.text.trim();

    if (bahan.isEmpty) {
      _snack('Isi bahan di rumah dulu ya');
      return;
    }

    _bahanC.clear();
    final newSession = _ChatSession(bahan: bahan, alergi: _alergiFinal);

    setState(() {
      _chatHistory.add(newSession);
      _step = _AiStep.result;
    });

    _scrollToBottomDelayed();
    _requestAI(newSession);
  }

  /// Dipakai saat user mengirim input "Lanjutkan obrolan ini" di mode detail.
  void _submitLanjutanDetail() {
    FocusScope.of(context).unfocus();
    if (_sedangMemuat) return;

    final bahanBaru = _bahanC.text.trim();

    if (bahanBaru.isEmpty) {
      _snack('Isi bahan dulu');
      return;
    }

    _bahanC.clear();
    final newSession = _ChatSession(bahan: bahanBaru, alergi: _alergiFinal);

    setState(() {
      _chatHistory.add(newSession);
      _step = _AiStep.result; // keluar dari mode detail -> result view
      _openedFromHistory = false;
      _showScrollDown = false;
    });

    _scrollToBottomDelayed();
    _requestAI(newSession);
  }

  void _newChat() {
    FocusScope.of(context).unfocus();
    setState(() {
      _bahanC.clear();
      _chatHistory.clear();
      _openedFromHistory = false;

      final savedAlergi = _alergiFinal.isNotEmpty
          ? _alergiFinal
          : (_alergiC.text.trim().isNotEmpty
              ? _alergiC.text.trim()
              : widget.child.alergi);
      _alergiFinal = savedAlergi;
      _alergiC.text = savedAlergi;

      _step = savedAlergi.isEmpty ? _AiStep.formEmpty : _AiStep.formFilled;
    });
  }

  void _ubahAlergi() {
    FocusScope.of(context).unfocus();
    setState(() {
      _alergiC.text = _alergiFinal;
      _step = _AiStep.formEmpty;
      _chatHistory.clear();
      _openedFromHistory = false;
    });
  }

  // ================= HISTORY PANEL =================
  void _showHistory() {
    _loadHistory(); // muat ulang setiap panel dibuka

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 319,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat obrolan',
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textBlack,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close,
                                size: 24, color: textBlack),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _historyTick,
                        builder: (_, __, ___) => _buildHistoryList(ctx),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 32, left: 28, right: 28),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _newChat();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5F5)
                                .withValues(alpha: 0.77),
                            elevation: 2,
                            shadowColor:
                                Colors.black.withValues(alpha: 0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(86),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/ep--edit.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                    textBlack, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 11),
                              Text(
                                'Obrolan baru',
                                style: google_fonts.GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildHistoryList(BuildContext ctx) {
    Widget pesan(String text, {VoidCallback? onTap, String? aksi}) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textGrey,
                ),
              ),
              if (onTap != null && aksi != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    aksi,
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryRed,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_historyLoading && _history.isEmpty) {
      return pesan('Memuat riwayat...');
    }
    if (_historyError != null && _history.isEmpty) {
      return pesan(_historyError!, onTap: _loadHistory, aksi: 'Coba lagi');
    }
    if (_history.isEmpty) {
      return pesan('Belum ada riwayat obrolan');
    }

    // kelompokkan per tanggal (data dari backend sudah terurut terbaru dulu)
    final groups = <String, List<AiHistoryItem>>{};
    for (final item in _history) {
      groups.putIfAbsent(_labelTanggal(item.createdAt), () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        for (final e in groups.entries) ...[
          _buildHistoryGroup(ctx, e.key, e.value),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHistoryGroup(
    BuildContext ctx,
    String date,
    List<AiHistoryItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: google_fonts.GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF797777),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          return Builder(
            builder: (itemCtx) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(ctx);
                  _openDetail(item);
                },
                onLongPress: () => _showDeleteHistoryPopup(itemCtx, item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Color(0xFFEAEAEA), thickness: 1),
                    const SizedBox(height: 12),
                    Text(
                      item.bahan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textBlack,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.menuTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showDeleteHistoryPopup(BuildContext itemCtx, AiHistoryItem item) {
    final RenderBox? box = itemCtx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset pos = box.localToGlobal(Offset.zero);
    final Size screen = MediaQuery.of(itemCtx).size;

    const double popW = 150;
    const double popH = 40.5;

    double top = pos.dy + box.size.height - 24;
    if (top + popH > screen.height - 24) {
      top = pos.dy - popH + 8;
    }
    final double left =
        pos.dx.clamp(8.0, screen.width - popW - 8).toDouble();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (popCtx, a1, a2) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(popCtx);
                          _hapusHistory(item);
                        },
                        child: Container(
                          width: popW,
                          height: popH,
                          padding:
                              const EdgeInsets.fromLTRB(15, 8, 59, 10),
                          decoration: BoxDecoration(
                            color: const Color(0x33D9D9D9),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/trash-fill.svg',
                                width: 22.5,
                                height: 22.5,
                                colorFilter: const ColorFilter.mode(
                                    textBlack, BlendMode.srcIn),
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(
                                  Icons.delete,
                                  size: 22.5,
                                  color: textBlack,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Flexible(
                                child: Text(
                                  'Hapus',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: google_fonts.GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 17 / 14,
                                    color: textBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isDetail = _step == _AiStep.detail;
    final showResultBody = _step == _AiStep.result || isDetail;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            isDetail ? _buildDetailHeader(topPad) : _buildHeader(topPad),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        if (_step == _AiStep.formEmpty) _buildFormEmpty(),
                        if (_step == _AiStep.formFilled) _buildFormFilled(),
                        if (showResultBody) _buildChatView(),
                      ],
                    ),
                  ),

                  if (showResultBody)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRect(
                              child: ShaderMask(
                                blendMode: BlendMode.dstIn,
                                shaderCallback: (rect) =>
                                    const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black
                                  ],
                                  stops: [0.0, 0.4],
                                ).createShader(rect),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 3, sigmaY: 3),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white
                                              .withValues(alpha: 0.5),
                                          Colors.white,
                                        ],
                                        stops: const [0.0, 0.35],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 21,
                              right: 21,
                              bottom: 16,
                              top: 32,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDetail)
                                  _inputField(
                                    controller: _bahanC,
                                    hint: 'Lanjutkan obrolan ini',
                                    onSend: _submitLanjutanDetail,
                                    autofocus: false,
                                    pill: true,
                                  )
                                else
                                  _inputField(
                                    controller: _bahanC,
                                    hint:
                                        'Punya bahan masakan apa di rumah?',
                                    onSend: _submitFromFilled,
                                    autofocus: false,
                                    pill: true,
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  'AI bisa saja membuat kesalahan. Cek ulang bahan dan takaran resep.',
                                  style: google_fonts.GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black
                                        .withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (showResultBody && _showScrollDown)
                    Positioned(
                      right: 27,
                      bottom: 120,
                      child: GestureDetector(
                        onTap: _scrollToBottom,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  Colors.black.withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_downward_rounded,
                            size: 22,
                            color: textBlack,
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
    );
  }

  Widget _buildChatView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatHeader(),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEAEAEA), thickness: 1),
          ..._chatHistory.map((session) => _buildChatMessage(session)),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildChildInfo()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Alergi',
                    style: google_fonts.GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textGrey)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _ubahAlergi,
                  behavior: HitTestBehavior.opaque,
                  child: Text('Ubah',
                      style: google_fonts.GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: primaryRed)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: 82.45,
              height: 31.51,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chipBg,
                border: Border.all(color: primaryRed, width: 0.5),
                borderRadius: BorderRadius.circular(31.5),
              ),
              child: Text(
                _alergiFinal.isEmpty ? '-' : _alergiFinal,
                overflow: TextOverflow.ellipsis,
                style: google_fonts.GoogleFonts.inter(
                    fontSize: 12.6, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Satu pesan obrolan: bubble bahan dari user + jawaban AI (atau loading/error).
  Widget _buildChatMessage(_ChatSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _formatJam(session.waktu),
              style: google_fonts.GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textGrey),
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 178,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgInput,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bahan di rumah',
                    style: google_fonts.GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF797777))),
                const SizedBox(height: 6),
                Text(session.bahan,
                    style: google_fonts.GoogleFonts.inter(
                        fontSize: 12.9, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        if (session.isLoading)
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(color: primaryRed),
                const SizedBox(height: 12),
                Text(
                    session.isDetail
                        ? 'Memuat riwayat...'
                        : 'AI sedang membuat resep...',
                    style: google_fonts.GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textGrey)),
              ],
            ),
          )
        else if (session.error != null)
          _buildError(session)
        else if (session.menu != null)
          _buildMenuView(session),
      ],
    );
  }

  Widget _buildError(_ChatSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.error!,
          style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: primaryRed,
              height: 16 / 13),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _retry(session),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: primaryRed),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Coba lagi',
              style: google_fonts.GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryRed),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMenuView(_ChatSession session) {
    final menu = session.menu!;
    final formattedBahan = _formatBahan(session.bahan);

    final statusText = (_kondisi ?? '').trim().isEmpty
        ? widget.child.nama
        : '${widget.child.nama} ($_kondisiLabel)';
    final alergiText =
        session.alergi.isNotEmpty ? ' dan alergi ${session.alergi}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: google_fonts.GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textBlack,
                height: 16 / 13),
            children: [
              const TextSpan(text: 'Berikut resep MPASI dari '),
              TextSpan(
                text: formattedBahan,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textBlack,
                  height: 16 / 13,
                ),
              ),
              TextSpan(
                text:
                    ' yang disesuaikan dengan status gizi $statusText$alergiText.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (menu.terbaca) ...[
          if (menu.nama.isNotEmpty) _sectionTitle(menu.nama),

          if (menu.bahan.isNotEmpty) ...[
            _sectionTitle('Bahan-bahan'),
            ...menu.bahan.map(_bullet),
          ],

          if (menu.langkah.isNotEmpty) ...[
            _sectionTitle('Cara Membuat'),
            for (int i = 0; i < menu.langkah.length; i++)
              _paragraph('${i + 1}. ${menu.langkah[i]}'),
          ],

          if (menu.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('Tips Penting'),
            ...menu.tips.map(_bullet),
          ],
        ] else
          // format jawaban tidak dikenali -> tampilkan apa adanya
          _paragraph(menu.mentah),

        const SizedBox(height: 40),
      ],
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(double topPad) {
    return Container(
      height: topPad + 130,
      decoration: const BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 28,
            bottom: 32,
            child: Text('Tanya AI Resep',
                style: google_fonts.GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          Positioned(
            right: 60,
            bottom: 30,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showHistory,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SvgPicture.asset(
                        'assets/images/basil--history-solid.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _newChat,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SvgPicture.asset(
                        'assets/images/ep--edit.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 32,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(_alergiFinal),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.close, size: 28, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(double topPad) {
    return Container(
      height: topPad + 130,
      decoration: const BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            bottom: 32,
            child: GestureDetector(
              onTap: _closeDetail,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 24,
                height: 34,
                child: Icon(Icons.arrow_back_ios_new,
                    size: 22, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 56,
            bottom: 32,
            child: Text('Detail Pencarian',
                style: google_fonts.GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          Positioned(
            right: 20,
            bottom: 32,
            child: Container(
              width: 73,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0x9CD9D9D9),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showHistory,
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      'assets/images/basil--history-solid.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _newChat,
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      'assets/images/ep--edit.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
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

  // ================= FORM =================
  Widget _buildFormEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildInfo(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Alergi',
                  style: google_fonts.GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text('(opsional)',
                  style: google_fonts.GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: textGrey)),
            ],
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: _alergiC,
            hint: 'Ketik alergi Si Kecil',
            autofocus: true,
          ),
          const SizedBox(height: 24),
          Text('Bahan di rumah',
              style: google_fonts.GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _inputField(
            controller: _bahanC,
            hint: 'Punya bahan masakan apa di rumah?',
            onSend: _bahanC.text.isNotEmpty ? _submitFromEmpty : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFilled() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildChildInfo()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Alergi',
                          style: google_fonts.GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textGrey)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _ubahAlergi,
                        behavior: HitTestBehavior.opaque,
                        child: Text('Ubah',
                            style: google_fonts.GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: primaryRed)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 82.45,
                    height: 31.51,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: chipBg,
                      border: Border.all(color: primaryRed, width: 0.5),
                      borderRadius: BorderRadius.circular(31.5),
                    ),
                    child: Text(
                      _alergiFinal.isEmpty ? '-' : _alergiFinal,
                      overflow: TextOverflow.ellipsis,
                      style: google_fonts.GoogleFonts.inter(
                          fontSize: 12.6, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Bahan di rumah',
              style: google_fonts.GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _inputField(
            controller: _bahanC,
            hint: 'Punya bahan masakan apa di rumah?',
            onSend: _bahanC.text.isNotEmpty ? _submitFromFilled : null,
            autofocus: true,
          ),
        ],
      ),
    );
  }

  Widget _buildChildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Untuk si kecil',
            style: google_fonts.GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textGrey)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(widget.child.nama,
                style: google_fonts.GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textBlack)),
            const SizedBox(width: 8),
            Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: textBlack, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(_umur,
                style: google_fonts.GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textBlack)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: _kondisiColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('Kondisi: $_kondisiLabel',
                style: google_fonts.GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textBlack)),
          ],
        ),
      ],
    );
  }

  // ================= HELPERS =================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(text,
          style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textBlack)),
    );
  }

  Widget _paragraph(String text) {
    return Text(text,
        style: google_fonts.GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textBlack,
            height: 16 / 13));
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: textBlack, shape: BoxShape.circle)),
          ),
          Expanded(child: _paragraph(text)),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    VoidCallback? onSend,
    bool autofocus = false,
    bool pill = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: pill
          ? const EdgeInsets.fromLTRB(20, 3, 3, 3)
          : const EdgeInsets.fromLTRB(20, 3, 6, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(86),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: pill
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              style: google_fonts.GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textBlack),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: google_fonts.GoogleFonts.inter(
                    fontSize: pill ? 12 : 12.9,
                    fontWeight: FontWeight.w400,
                    color: textGrey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (onSend != null)
            GestureDetector(
              onTap: onSend,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: pill ? 38 : 32,
                height: pill ? 38 : 32,
                decoration: const BoxDecoration(
                    color: textMuted, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(Icons.arrow_upward_rounded,
                    size: pill ? 22 : 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}