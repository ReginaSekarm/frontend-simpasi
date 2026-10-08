import 'package:flutter/material.dart';

import '../../widgets/bottom_nav.dart';
import '../home/home_ibu_screen.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/menu_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import 'detail_pemeriksaan_screen.dart';
import 'detail_pencarian_screen.dart';

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
  /// 0 = Pencarian, 1 = Pemeriksaan Stunting
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
  static const Color chipBg       = Color(0x80F88B92); // pink 50%
  static const Color orangeText   = Color(0xFFE38621);
  static const Color orangeFaded  = Color(0xB3E38621); // 70% alpha
  static const Color dividerOrange= Color(0xFFBE6D15);
  static const Color textBlack    = Color(0xFF000000);
  static const Color textGrey     = Color(0xFF8F8F8F);
  static const Color textDarkDate = Color(0xFF4B5563);
  static const Color statusRed    = Color(0xFFD45060);
  static const Color statusOrange = Color(0xFFF1A038);
  static const Color statusGreen  = Color(0xFF76C457);
  static const Color purpleAI     = Color(0xFF9564DD);
  static const Color iconCircleBg = Color(0xA3FFFFFF); // white 64%

  // 0 = Pencarian, 1 = Pemeriksaan Stunting
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
      body: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 32),

                  // ================= ISI TAB =================
                  if (_tab == 1) ...[
                    for (int i = 0; i < _riwayat.length; i++) ...[
                      if (i > 0) const SizedBox(height: 27),
                      _buildRiwayatCard(_riwayat[i]),
                    ],
                  ] else ...[
                    for (int i = 0; i < _pencarian.length; i++) ...[
                      if (i > 0) const SizedBox(height: 28),
                      _buildPencarianGroup(_pencarian[i]),
                    ],
                  ],

                  const SizedBox(height: 140),
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
      height: topPad + 184,
      decoration: const BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          // Baris 1: "Riwayat" + bell
          Positioned(
            top: topPad + 20,
            left: 28,
            right: 16,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Text(
                    'Riwayat',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 32 / 24,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),

          // Baris 2: Tab toggle
          Positioned(
            top: topPad + 90,
            left: 38,
            right: 38,
            child: Container(
              height: 55,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: bgCream,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Pencarian'),
                  _buildTab(1, 'Pemeriksaan\nStunting'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? bgPinkChip : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
        ),
      ),
    );
  }

  // ================= PENCARIAN GROUP CARD =================
  Widget _buildPencarianGroup(PencarianGroup group) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 31),
      child: Container(
        decoration: BoxDecoration(
          color: bgCream,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(7, 12, 7, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== Header: "Sabtu 12 Sep 2026" ====
            Padding(
              padding: const EdgeInsets.only(left: 7, bottom: 10),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: orangeText,
                    height: 19 / 15,
                  ),
                  children: [
                    TextSpan(text: group.hari),
                    TextSpan(
                      text: '  ${group.tanggal}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
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
            Container(height: 1, color: dividerOrange),

            // ==== List pencarian item ====
            for (int i = 0; i < group.items.length; i++) ...[
              _buildPencarianItem(group.items[i]),
              if (i < group.items.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 37),
                  child: Container(height: 1, color: dividerOrange),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= PENCARIAN ITEM =================
  Widget _buildPencarianItem(PencarianItem item) {
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
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // AI icon circle
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: iconCircleBg,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: purpleAI,
                ),
              ),
            ),
            const SizedBox(width: 13),

            // Kolom chips + "N resep ditemukan"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.keywords.map((k) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          border: Border.all(
                            color: primaryRed,
                            width: 0.35,
                          ),
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: Text(
                          k,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: textBlack,
                            height: 10 / 8.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.jumlahResep} Resep ditemukan',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: textBlack,
                      height: 10 / 8.5,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right,
              size: 26,
              color: textBlack,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ================= KARTU RIWAYAT PEMERIKSAAN =================
  Widget _buildRiwayatCard(RiwayatItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 31),
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
          constraints: const BoxConstraints(minHeight: 105),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 21),
          decoration: BoxDecoration(
            color: bgCream,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak tanggal
              Container(
                constraints: const BoxConstraints(minHeight: 63),
                width: 59,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.tglHari,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textDarkDate,
                        height: 18 / 15,
                      ),
                    ),
                    Text(
                      item.tglBulan,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textDarkDate,
                        height: 18 / 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),

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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textBlack,
                              height: 18 / 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.status,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _statusColor(item.status),
                              height: 13 / 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      item.catatan,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: textBlack,
                        height: 13 / 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Detail',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textBlack,
                            height: 13 / 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
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