import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../menu/detail_resep_screen.dart';
import '../riwayat/riwayat_screen.dart';

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

  const _NotifItem({
    required this.judul,
    required this.isiBefore,
    required this.boldText,
    required this.isiAfter,
    required this.waktu,
    required this.action,
  });
}

// ================= AKSI TIAP NOTIFIKASI =================
enum _NotifAction {
  bukaResepPepaya,   // ke DetailResepScreen Pepaya lumat
  bukaRiwayat,       // ke RiwayatScreen — tab Pemeriksaan Stunting
}

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  // Warna dari Figma
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgCream    = Color(0xFFFCEBD5);
  static const Color textBlack  = Color(0xFF000000);
  static const Color textGrey   = Color(0xFF8F8F8F);

  // Data dummy notifikasi
  static const List<_NotifItem> _notifs = [
    _NotifItem(
      judul: 'Resep Baru Telah Ditambahkan',
      isiBefore: 'Kader menambahkan resep baru: "Pepaya lumat". ',
      boldText: 'Lihat Menu.',
      isiAfter: '',
      waktu: '2 jam yang lalu',
      action: _NotifAction.bukaResepPepaya,
    ),
    _NotifItem(
      judul: 'Catatan dari Kader Posyandu',
      isiBefore:
          'Kader menambahkan catatan baru terkait perkembangan gizi anak Anda. ',
      boldText: 'Ketuk untuk lihat detail.',
      isiAfter: '',
      waktu: 'Kemarin, 14.30',
      action: _NotifAction.bukaRiwayat,
    ),
    _NotifItem(
      judul: 'Hasil pemeriksaan tersedia',
      isiBefore:
          'Hasil pemeriksaan stunting bulan ini di Posyandu sudah bisa dilihat. ',
      boldText: 'Ketuk untuk cek status pertumbuhan.',
      isiAfter: '',
      waktu: '3 hari lalu',
      action: _NotifAction.bukaRiwayat,
    ),
  ];

  // ================= NAVIGASI =================
  void _handleAction(BuildContext context, _NotifAction action) {
    switch (action) {
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
        // 👇 FIX: initialTab: 1 → langsung buka tab Pemeriksaan Stunting
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RiwayatScreen(initialTab: 1),
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
            // ================= HEADER =================
            Container(
              height: topPad + 150,
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
                    child: Text(
                      'Notifikasi',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 32 / 24,
                      ),
                    ),
                  ),

                  // Close icon
                  Positioned(
                    right: 30,
                    bottom: 27,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.close,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ================= LIST NOTIFIKASI =================
            for (int i = 0; i < _notifs.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _buildNotifCard(context, _notifs[i]),
              ),
            ],

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ================= KARTU NOTIFIKASI =================
  Widget _buildNotifCard(BuildContext context, _NotifItem item) {
    return Container(
      constraints: const BoxConstraints(minHeight: 105),
      padding: const EdgeInsets.fromLTRB(29, 19, 28, 19),
      decoration: BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            item.judul,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 17 / 14,
            ),
          ),
          const SizedBox(height: 7),

          // Isi (dengan bold text yang bisa di-tap)
          _buildIsiRich(context, item),

          const SizedBox(height: 8),

          // Waktu align kanan
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.waktu,
              style: GoogleFonts.inter(
                fontSize: 12,
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

  // ================= ISI DENGAN BOLD PART YANG BISA DI-TAP =================
  Widget _buildIsiRich(BuildContext context, _NotifItem item) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textBlack.withValues(alpha: 0.8),
          height: 15 / 12,
        ),
        children: [
          // Teks sebelum bold
          TextSpan(text: item.isiBefore),

          // Bold text yang bisa di-tap
          TextSpan(
            text: item.boldText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textBlack,
              height: 15 / 12,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _handleAction(context, item.action),
          ),

          // Teks setelah bold (kalau ada)
          if (item.isiAfter.isNotEmpty) TextSpan(text: item.isiAfter),
        ],
      ),
    );
  }
}