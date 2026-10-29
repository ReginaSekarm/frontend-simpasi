import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Pastikan import ini sesuai dengan struktur folder Anda
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/notification_icon.dart';
import '../home/home_ibu_screen.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/menu_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import 'detail_pemeriksaan_screen.dart';
import 'detail_pencarian_screen.dart'; // 👈 WAJIB IMPORT INI

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
  });
}

// ================= MODEL PENCARIAN AI =================
class PencarianItem {
  final List<String> keywords;
  final int jumlahResep;

  const PencarianItem({
    required this.keywords,
    required this.jumlahResep,
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
  // Warna dari Figma
  static const Color primaryRed   = Color(0xFFD45060);
  static const Color bgCream      = Color(0xFFFCEBD5);
  static const Color bgPinkChip   = Color(0xFFF7A497);
  static const Color chipBg       = Color(0x80F88B92);
  static const Color orangeText   = Color(0xFFE38621);
  static const Color orangeFaded  = Color(0xB3E38621);
  static const Color dividerOrange= Color(0xFFBE6D15);
  static const Color textBlack    = Color(0xFF000000);
  static const Color textGrey     = Color(0xFF8F8F8F);
  static const Color textDarkDate = Color(0xFF4B5563);
  static const Color statusRed    = Color(0xFFD45060);
  static const Color statusOrange = Color(0xFFF1A038);
  static const Color statusGreen  = Color(0xFF76C457);
  static const Color purpleAI     = Color(0xFF9564DD);
  static const Color iconCircleBg = Color(0xA3FFFFFF);

  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  // ================= DATA PEMERIKSAAN =================
  static const List<RiwayatItem> _riwayat = [
    RiwayatItem(
      tglHari: '12',
      tglBulan: 'Sep',
      judul: 'Pemeriksaan bulan ke-6',
      catatan: 'Catatan: Nafsu makan menurun dan....',
      status: 'Stunting',
      catatanLengkap:
          'Nafsu makan menurun dan berat badan naik lambat dua bulan '
          'terakhir, perlu tambahan asupan protein hewani.',
    ),
    RiwayatItem(
      tglHari: '12',
      tglBulan: 'Agu',
      judul: 'Pemeriksaan bulan ke-5',
      catatan: 'Catatan: -',
      status: 'Berisiko',
    ),
    RiwayatItem(
      tglHari: '12',
      tglBulan: 'Jul',
      judul: 'Pemeriksaan bulan ke-4',
      catatan: 'Catatan: -',
      status: 'Normal',
    ),
    RiwayatItem(
      tglHari: '12',
      tglBulan: 'Jun',
      judul: 'Pemeriksaan bulan ke-3',
      catatan: 'Catatan: -',
      status: 'Normal',
    ),
  ];

  // ================= DATA PENCARIAN AI =================
  static const List<PencarianGroup> _pencarian = [
    PencarianGroup(
      hari: 'Sabtu',
      tanggal: '12 Sep 2026',
      items: [
        PencarianItem(keywords: ['Ayam', 'Wortel'], jumlahResep: 2),
        PencarianItem(keywords: ['Telur'], jumlahResep: 2),
        PencarianItem(keywords: ['Ubi', 'Pepaya', 'Pisang'], jumlahResep: 3),
      ],
    ),
    PencarianGroup(
      hari: 'Jumat',
      tanggal: '4 Sep 2026',
      items: [
        PencarianItem(keywords: ['Pisang'], jumlahResep: 5),
      ],
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  SizedBox(height: context.w(32)),

                  // ================= ISI TAB =================
                  if (_tab == 1) ...[
                    for (int i = 0; i < _riwayat.length; i++) ...[
                      if (i > 0) SizedBox(height: context.w(27)),
                      _buildRiwayatCard(context, _riwayat[i]),
                    ],
                  ] else ...[
                    for (int i = 0; i < _pencarian.length; i++) ...[
                      if (i > 0) SizedBox(height: context.w(28)),
                      _buildPencarianGroup(context, _pencarian[i]),
                    ],
                  ],

                  SizedBox(height: context.w(140)),
                ],
              ),
            ),

            // ================= BOTTOM NAV =================
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
                  Navigator.of(context).popUntil((r) => r.isFirst);
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
          // Baris 1: "Riwayat" + bell
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

          // Baris 2: Tab toggle
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
        onTap: () => setState(() => _tab = index),
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
            // ==== Header: "Sabtu 12 Sep 2026" ====
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

            // Divider header
            Container(height: context.w(1), color: dividerOrange),

            // ==== List pencarian item ====
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailPencarianScreen(keywords: item.keywords),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, context.w(12), 0, context.w(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // AI icon circle
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

            // Kolom chips + "N resep ditemukan"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips
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

            // Chevron
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
              // Kotak tanggal
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