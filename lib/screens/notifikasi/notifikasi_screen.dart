import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
class _NotifItem {
  final String judul;
  final String isiBefore;
  final String boldText;
  final String isiAfter;
  final String waktu;
  final _NotifAction action;

  final double isiAlpha;
  final double waktuRight;
  final double waktuBottom;

  bool isRead; 

  _NotifItem({
    required this.judul,
    required this.isiBefore,
    required this.boldText,
    required this.isiAfter,
    required this.waktu,
    required this.action,
    this.isiAlpha = 1.0,
    this.waktuRight = 18,
    this.waktuBottom = 7,
    this.isRead = false,
  });
}

// ================= AKSI TIAP NOTIFIKASI =================
enum _NotifAction {
  bukaResepPepaya,
  bukaRiwayat,
  bukaResepKueUbiKeju,
}

class NotificationData {
  static final List<_NotifItem> items = [
    _NotifItem(
      judul: 'Resep Baru Telah Ditambahkan',
      isiBefore: 'Kader menambahkan resep baru: “Pepaya lumat”. ',
      boldText: 'Lihat Menu.',
      isiAfter: '',
      waktu: '2 jam yang lalu',
      action: _NotifAction.bukaResepPepaya,
      isiAlpha: 0.8,
      isRead: false,
    ),
    _NotifItem(
      judul: 'Catatan dari Kader Posyandu',
      isiBefore: 'Kader menambahkan catatan baru terkait perkembangan gizi anak Anda. ',
      boldText: 'Ketuk untuk lihat detail.',
      isiAfter: '',
      waktu: 'Kemarin, 14.30',
      action: _NotifAction.bukaRiwayat,
      isRead: false,
    ),
    _NotifItem(
      judul: 'Hasil pemeriksaan tersedia',
      isiBefore: 'Hasil pemeriksaan stunting bulan ini di Posyandu sudah bisa dilihat. ',
      boldText: 'Ketuk untuk cek status pertumbuhan.',
      isiAfter: '',
      waktu: '3 hari lalu',
      action: _NotifAction.bukaRiwayat,
      waktuRight: 21,
      isRead: false,
    ),
    _NotifItem(
      judul: 'Balasan Komentar Baru',
      isiBefore: 'Uni membalas komentar Anda pada resep Kue Ubi Keju: "Uni: @Aisyah Oke bun, makasih infonya". ',
      boldText: 'Ketuk untuk lihat balasan.',
      isiAfter: '',
      waktu: '3 hari lalu',
      action: _NotifAction.bukaResepKueUbiKeju,
      waktuRight: 21,
      waktuBottom: 9,
      isRead: false,
    ),
  ];

  // Fungsi ini harus dipanggil saat aplikasi pertama kali dibuka
  static void init() {
    unreadNotifications.value = items.where((n) => !n.isRead).length;
  }
}


class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgCream    = Color(0xFFFCEBD5);
  static const Color textBlack  = Color(0xFF000000);
  static const Color textGrey   = Color(0xFF8F8F8F);

  // Ambil data dari kelas global
  List<_NotifItem> get _notifs => NotificationData.items;

  @override
  void initState() {
    super.initState();
    // Hapus pemanggilan _updateUnreadCount() di sini karena sudah diurus oleh NotificationData.init()
  }

  void _handleAction(BuildContext context, _NotifItem item) {
    if (!item.isRead) {
      setState(() {
        item.isRead = true;
      });
      // Panggil ulang init() untuk update angka badge secara global
      NotificationData.init(); 
    }

    switch (item.action) {
      case _NotifAction.bukaResepPepaya:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DetailResepScreen(
              title: 'Pepaya lumat',
              imagePath: 'assets/images/pepaya-lumat.png',
              badge: '6 Bulan',
            ),
          ),
        );
        break;

      case _NotifAction.bukaRiwayat:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RiwayatScreen(initialTab: 1),
          ),
        );
        break;

      case _NotifAction.bukaResepKueUbiKeju:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DetailResepScreen(
              title: 'Kue ubi keju',
              imagePath: 'assets/images/kue-ubi-keju.png',
              badge: '9 - 11 Bulan',
              openComments: true, 
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildNotifCard(BuildContext context, _NotifItem item) {
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
                      fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w600,
                      color: item.isRead ? textBlack.withValues(alpha: 0.4) : textBlack,
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

  Widget _buildIsiRich(BuildContext context, _NotifItem item) {
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