import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../utils/responsive.dart';
import '../menu/detail_resep_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../../widgets/notification_icon.dart';

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

// ================= MODEL NOTIFIKASI =================
class NotifItem {
  final int? id;
  final int? recipeId;
  final String judul;
  final String isiBefore;
  final String boldText;
  final String isiAfter;
  final String waktu;
  final NotifAction action;
  final String? targetTitle;
  final String? targetImage;
  final String? targetBadge;
  final bool openComments;

  final double isiAlpha;
  final double waktuRight;
  final double waktuBottom;

  bool isRead;

  NotifItem({
    this.id,
    this.recipeId,
    required this.judul,
    required this.isiBefore,
    required this.boldText,
    required this.isiAfter,
    required this.waktu,
    required this.action,
    this.targetTitle,
    this.targetImage,
    this.targetBadge,
    this.openComments = false,
    this.isiAlpha = 1.0,
    this.waktuRight = 18,
    this.waktuBottom = 7,
    this.isRead = false,
  });
}

// ================= AKSI TIAP NOTIFIKASI =================
enum NotifAction {
  bukaResepPepaya,
  bukaRiwayat,
  bukaResepKueUbiKeju,
  bukaResepCustom,
}

class NotificationData {
  static final List<NotifItem> _fallbackItems = [
    NotifItem(
      judul: 'Resep Baru Telah Ditambahkan',
      isiBefore: 'Kader menambahkan resep baru: “Pepaya lumat”. ',
      boldText: 'Lihat Menu.',
      isiAfter: '',
      waktu: '2 jam yang lalu',
      action: NotifAction.bukaResepPepaya,
      isiAlpha: 0.8,
      isRead: false,
    ),
    NotifItem(
      judul: 'Catatan dari Kader Posyandu',
      isiBefore:
          'Kader menambahkan catatan baru terkait perkembangan gizi anak Anda. ',
      boldText: 'Ketuk untuk lihat detail.',
      isiAfter: '',
      waktu: 'Kemarin, 14.30',
      action: NotifAction.bukaRiwayat,
      isRead: false,
    ),
    NotifItem(
      judul: 'Hasil pemeriksaan tersedia',
      isiBefore:
          'Hasil pemeriksaan stunting bulan ini di Posyandu sudah bisa dilihat. ',
      boldText: 'Ketuk untuk cek status pertumbuhan.',
      isiAfter: '',
      waktu: '3 hari lalu',
      action: NotifAction.bukaRiwayat,
      waktuRight: 21,
      isRead: false,
    ),
    NotifItem(
      judul: 'Balasan Komentar Baru',
      isiBefore:
          'Uni membalas komentar Anda pada resep Kue Ubi Keju: "Uni: @Aisyah Oke bun, makasih infonya". ',
      boldText: 'Ketuk untuk lihat balasan.',
      isiAfter: '',
      waktu: '3 hari lalu',
      action: NotifAction.bukaResepKueUbiKeju,
      waktuRight: 21,
      waktuBottom: 9,
      isRead: false,
    ),
  ];

  static final List<NotifItem> items = List<NotifItem>.from(_fallbackItems);
  static bool _hasSyncedOnce = false;
  static Timer? _backgroundTimer;

  static const List<String> _namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static void syncUnreadCount() {
    unreadNotifications.value = items.where((n) => !n.isRead).length;
  }

  static void init() {
    syncUnreadCount();
    fetchFromBackend();
    startBackgroundSync();
  }

  static void startBackgroundSync({
    Duration interval = const Duration(seconds: 12),
  }) {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(interval, (_) {
      fetchFromBackend();
    });
  }

  static void stopBackgroundSync() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  static int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  static String _formatRelativeTime(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.isNegative || diff.inSeconds < 45) {
      return 'Baru saja';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    }

    final jam = local.hour.toString().padLeft(2, '0');
    final menit = local.minute.toString().padLeft(2, '0');
    final todayStart = DateTime(now.year, now.month, now.day);
    final itemStart = DateTime(local.year, local.month, local.day);
    final dayDiff = todayStart.difference(itemStart).inDays;

    if (dayDiff == 1) {
      return 'Kemarin, $jam.$menit';
    }
    if (dayDiff < 7) {
      return '$dayDiff hari lalu';
    }

    final bulan = _namaBulan[local.month - 1];
    if (local.year == now.year) {
      return '${local.day} $bulan, $jam.$menit';
    }
    return '${local.day} $bulan ${local.year}';
  }

  static String _formatWaktu(Map<String, dynamic> map) {
    final rawTime = (map['time_ago'] ??
            map['timeAgo'] ??
            map['waktu'] ??
            map['created_at'] ??
            map['createdAt'])
        ?.toString()
        .trim();
    if (rawTime == null || rawTime.isEmpty) return 'Baru saja';

    final parsed = DateTime.tryParse(rawTime);
    if (parsed != null) {
      return _formatRelativeTime(parsed);
    }
    return rawTime;
  }

  static String? _extractQuotedTitle(String text) {
    final match = RegExp(r'[“"]([^”"]+)[”"]').firstMatch(text);
    final extracted = match?.group(1)?.trim();
    if (extracted != null && extracted.isNotEmpty) {
      return extracted;
    }
    return null;
  }

  static NotifItem _fromJson(Map<String, dynamic> map) {
    final id =
        _parseId(map['id'] ?? map['notification_id'] ?? map['notificationId']);
    final recipeId = _parseId(map['recipe_id'] ?? map['recipeId']);
    final judul =
        (map['title'] ?? map['judul'] ?? 'Notifikasi').toString().trim();

    final fullMessage = (map['message'] ??
            map['body'] ??
            map['content'] ??
            map['isi'] ??
            '')
        .toString()
        .trim();

    final isRead = map['is_read'] == true ||
        map['isRead'] == true ||
        map['read'] == true ||
        _parseId(map['is_read']) == 1;

    final typeStr = (map['type'] ?? map['category'] ?? map['action'] ?? '')
        .toString()
        .toLowerCase();

    NotifAction action = NotifAction.bukaRiwayat;
    String boldText = 'Ketuk untuk lihat detail.';
    String? targetTitle;
    String? targetImage;
    String? targetBadge;
    bool openComments = false;

    if (typeStr.contains('comment') ||
        typeStr.contains('komentar') ||
        judul.toLowerCase().contains('komentar')) {
      action = NotifAction.bukaResepKueUbiKeju;
      boldText = 'Ketuk untuk lihat balasan.';
      openComments = true;
      targetTitle = (map['recipe_title'] ??
              map['recipeTitle'] ??
              _extractQuotedTitle(fullMessage) ??
              'Kue ubi keju')
          .toString()
          .trim();
      targetImage = (map['recipe_image'] ??
              map['photo_url'] ??
              map['image_url'] ??
              'assets/images/kue-ubi-keju.png')
          .toString()
          .trim();
      targetBadge = (map['age_category'] ?? '9 - 11 Bulan').toString().trim();
    } else if (typeStr.contains('recipe') ||
        typeStr.contains('resep') ||
        recipeId != null ||
        judul.toLowerCase().contains('resep')) {
      final resolvedTitle = (map['recipe_title'] ??
              map['recipeTitle'] ??
              _extractQuotedTitle(fullMessage))
          ?.toString()
          .trim();
      if (recipeId != null ||
          (resolvedTitle != null && resolvedTitle.isNotEmpty)) {
        action = NotifAction.bukaResepCustom;
        targetTitle = (resolvedTitle != null && resolvedTitle.isNotEmpty)
            ? resolvedTitle
            : 'Pepaya lumat';
        targetImage = (map['recipe_image'] ??
                map['photo_url'] ??
                map['image_url'] ??
                'assets/images/bubur-hati-ayam.png')
            .toString()
            .trim();
        targetBadge = (map['age_category'] ?? '6 Bulan').toString().trim();
      } else {
        action = NotifAction.bukaResepPepaya;
      }
      boldText = 'Lihat Menu.';
    } else if (typeStr.contains('checkup') ||
        typeStr.contains('pemeriksaan') ||
        typeStr.contains('stunting')) {
      action = NotifAction.bukaRiwayat;
      boldText = 'Ketuk untuk cek status pertumbuhan.';
    }

    final isiBefore =
        fullMessage.isEmpty ? 'Ada pembaruan baru untuk Anda. ' : '$fullMessage ';

    return NotifItem(
      id: id,
      recipeId: recipeId,
      judul: judul.isEmpty ? 'Notifikasi' : judul,
      isiBefore: isiBefore,
      boldText: boldText,
      isiAfter: '',
      waktu: _formatWaktu(map),
      action: action,
      targetTitle: targetTitle,
      targetImage: targetImage,
      targetBadge: targetBadge,
      openComments: openComments,
      isRead: isRead,
    );
  }

  static String _signature(NotifItem n) {
    return '${n.id ?? ''}|${n.judul}|${n.isiBefore}|${n.waktu}|${n.isRead}';
  }

  static Future<bool> fetchFromBackend() async {
    try {
      final res = await ApiClient.get('/notifications');
      final rawData = res['data'] ?? res['notifications'];
      if (rawData is List) {
        final parsed = <NotifItem>[];
        for (final entry in rawData) {
          if (entry is Map) {
            parsed.add(_fromJson(Map<String, dynamic>.from(entry)));
          }
        }

        final oldSig = items.map(_signature).join('##');
        final newSig = parsed.map(_signature).join('##');
        final changed = !_hasSyncedOnce || oldSig != newSig;

        items
          ..clear()
          ..addAll(parsed);
        _hasSyncedOnce = true;
        syncUnreadCount();
        return changed;
      }
      return false;
    } on ApiException {
      syncUnreadCount();
      return false;
    } catch (_) {
      syncUnreadCount();
      return false;
    }
  }

  static Future<void> markAsRead(NotifItem item) async {
    if (item.isRead) return;
    item.isRead = true;
    syncUnreadCount();

    if (item.id == null) return;

    try {
      await ApiClient.put('/notifications/${item.id}/read');
    } on ApiException {
      // Biarkan status terbaca di lokal agar UI tetap responsif
    }
  }

  static Future<void> markAllAsRead() async {
    for (final n in items) {
      n.isRead = true;
    }
    syncUnreadCount();

    try {
      await ApiClient.put('/notifications/read-all');
    } on ApiException {
      // Biarkan status terbaca di lokal jika gagal
    }
  }

  static Future<void> removeNotification(NotifItem item) async {
    items.remove(item);
    syncUnreadCount();

    if (item.id == null) return;

    try {
      await ApiClient.delete('/notifications/${item.id}');
    } on ApiException {
      // Abaikan jika gagal hapus di server
    }
  }
}

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen>
    with WidgetsBindingObserver {
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgCream    = Color(0xFFFCEBD5);
  static const Color textBlack  = Color(0xFF000000);
  static const Color textGrey   = Color(0xFF8F8F8F);

  bool _isLoading = false;
  Timer? _pollTimer;

  List<NotifItem> get _notifs => NotificationData.items;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications(showSpinner: _notifs.isEmpty);
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _silentRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _silentRefresh() async {
    if (!mounted) return;
    final changed = await NotificationData.fetchFromBackend();
    if (changed && mounted) {
      setState(() {});
    }
  }

  Future<void> _loadNotifications({bool showSpinner = true}) async {
    if (showSpinner && mounted) {
      setState(() => _isLoading = true);
    }
    await NotificationData.fetchFromBackend();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _handleAction(BuildContext context, NotifItem item) async {
    if (!item.isRead) {
      setState(() {});
      await NotificationData.markAsRead(item);
      if (!context.mounted) return;
      setState(() {});
    }

    switch (item.action) {
      case NotifAction.bukaResepPepaya:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailResepScreen(
              recipeId: item.recipeId,
              title: 'Pepaya lumat',
              imagePath: 'assets/images/pepaya-lumat.png',
              badge: '6 Bulan',
            ),
          ),
        );
        break;

      case NotifAction.bukaRiwayat:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RiwayatScreen(initialTab: 1),
          ),
        );
        break;

      case NotifAction.bukaResepKueUbiKeju:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailResepScreen(
              recipeId: item.recipeId,
              title: item.targetTitle ?? 'Kue ubi keju',
              imagePath: item.targetImage ?? 'assets/images/kue-ubi-keju.png',
              badge: item.targetBadge ?? '9 - 11 Bulan',
              openComments: true,
            ),
          ),
        );
        break;

      case NotifAction.bukaResepCustom:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailResepScreen(
              recipeId: item.recipeId,
              title: item.targetTitle ?? 'Resep MPASI',
              imagePath: item.targetImage ?? 'assets/images/bubur-hati-ayam.png',
              badge: item.targetBadge ?? '6 Bulan',
              openComments: item.openComments,
            ),
          ),
        );
        break;
    }

    if (mounted) {
      _silentRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: primaryRed,
        onRefresh: () => _loadNotifications(showSpinner: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: topPad + context.w(150),
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
                      left: context.w(28),
                      bottom: context.w(38),
                      child: Text(
                        'Notifikasi',
                        style: GoogleFonts.inter(
                          fontSize: context.sp(24),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 32 / 24,
                        ),
                      ),
                    ),
                    Positioned(
                      right: context.w(30),
                      bottom: context.w(40),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: context.w(30),
                          height: context.w(30),
                          child: CustomPaint(
                            painter: _CloseXPainter(
                              glyph: context.w(20.25),
                              stroke: context.w(2.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.w(36)),

              if (_isLoading && _notifs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryRed),
                  ),
                )
              else if (_notifs.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(30),
                    vertical: context.w(60),
                  ),
                  child: Center(
                    child: Text(
                      'Belum ada notifikasi',
                      style: GoogleFonts.inter(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w500,
                        color: textGrey,
                      ),
                    ),
                  ),
                )
              else
                for (int i = 0; i < _notifs.length; i++) ...[
                  if (i > 0) SizedBox(height: context.w(20)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(30)),
                    child: GestureDetector(
                      onTap: () => _handleAction(context, _notifs[i]),
                      behavior: HitTestBehavior.opaque,
                      child: _buildNotifCard(context, _notifs[i]),
                    ),
                  ),
                ],

              SizedBox(height: context.w(60)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifCard(BuildContext context, NotifItem item) {
    return Container(
      constraints: BoxConstraints(minHeight: context.w(105)),
      decoration: BoxDecoration(
        color: item.isRead ? bgCream.withValues(alpha: 0.5) : bgCream,
        borderRadius: BorderRadius.circular(context.w(20)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(29),
              context.w(19),
              context.w(18),
              context.w(13),
            ),
            child: SizedBox(
              width: context.w(250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(14),
                      fontWeight:
                          item.isRead ? FontWeight.w500 : FontWeight.w600,
                      color: item.isRead
                          ? textBlack.withValues(alpha: 0.4)
                          : textBlack,
                      height: 17 / 14,
                    ),
                  ),
                  SizedBox(height: context.w(7)),
                  _buildIsiRich(context, item),
                ],
              ),
            ),
          ),
          Positioned(
            right: context.w(item.waktuRight),
            bottom: context.w(item.waktuBottom),
            child: Text(
              item.waktu,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w400,
                color: textGrey,
                height: 15 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIsiRich(BuildContext context, NotifItem item) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: context.sp(12),
          fontWeight: FontWeight.w400,
          color: item.isRead
              ? textBlack.withValues(alpha: 0.4)
              : textBlack.withValues(alpha: item.isiAlpha),
          height: 15 / 12,
        ),
        children: [
          TextSpan(text: item.isiBefore),
          TextSpan(
            text: item.boldText,
            style: GoogleFonts.inter(
              fontSize: context.sp(12),
              fontWeight: FontWeight.w700,
              color: item.isRead ? textBlack.withValues(alpha: 0.5) : textBlack,
              height: 15 / 12,
            ),
          ),
          if (item.isiAfter.isNotEmpty) TextSpan(text: item.isiAfter),
        ],
      ),
    );
  }
}

class _CloseXPainter extends CustomPainter {
  final double glyph;
  final double stroke;

  const _CloseXPainter({required this.glyph, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final c = Offset(size.width / 2, size.height / 2);
    final h = glyph / 2;
    canvas.drawLine(c + Offset(-h, -h), c + Offset(h, h), paint);
    canvas.drawLine(c + Offset(h, -h), c + Offset(-h, h), paint);
  }

  @override
  bool shouldRepaint(covariant _CloseXPainter old) =>
      old.glyph != glyph || old.stroke != stroke;
}