import 'package:flutter/material.dart';

import '../../widgets/bottom_nav.dart';
import '../koleksi/koleksi_screen.dart';
import '../menu/menu_screen.dart';

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

class DetailPemeriksaanScreen extends StatelessWidget {
  final String tglHari;
  final String tglBulan;
  final String judul;
  final String status;
  final String beratBadan;
  final String tinggiBadan;
  final String lingkarKepala;
  final String lila;
  final String catatan;
  final String pemeriksaanBerikutnya;

  const DetailPemeriksaanScreen({
    super.key,
    required this.tglHari,
    required this.tglBulan,
    required this.judul,
    required this.status,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.lingkarKepala,
    required this.lila,
    required this.catatan,
    required this.pemeriksaanBerikutnya,
  });

  // Warna dari Figma
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color bgCream     = Color(0xFFFCEBD5);
  static const Color bgSoftCream = Color(0xFFF7F3EC);
  static const Color chipBg      = Color(0x80F88B92); // rgba(248,139,146,0.5)
  static const Color textBlack   = Color(0xFF000000);
  static const Color textGrey    = Color(0xFF8F8F8F);
  static const Color textDarkDate= Color(0xFF4B5563);
  static const Color statusRed   = Color(0xFFD45060);
  static const Color statusOrange= Color(0xFFF1A038);
  static const Color statusGreen = Color(0xFF76C457);

  Color _statusColor(String s) {
    switch (s) {
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
                  const SizedBox(height: 18),

                  // ==== Kartu tanggal + judul ====
                  _buildTopCard(),

                  const SizedBox(height: 26),

                  // ==== IDENTITAS BALITA & ORANG TUA ====
                  _buildSectionTitle('IDENTITAS BALITA & ORANG TUA'),
                  const SizedBox(height: 20),
                  _buildIdentitas(),

                  const SizedBox(height: 28),

                  // ==== PARAMETER ANTROPOMETRI ====
                  _buildSectionTitle('PARAMETER ANTROPOMETRI'),
                  const SizedBox(height: 25),
                  _buildParameterRow(),
                  const SizedBox(height: 19),
                  _buildCatatanBox(),

                  const SizedBox(height: 28),

                  // ==== BAHAN MAKANAN YANG DIREKOMENDASIKAN ====
                  _buildSectionTitle(
                      'BAHAN MAKANAN YANG DIREKOMENDASIKAN'),
                  const SizedBox(height: 22),
                  _buildBahanChips(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Ketuk salah satu bahan untuk melihat resep MPASI yang sesuai.',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: textBlack,
                        height: 12 / 10,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==== KONDISI & TINDAK LANJUT ====
                  _buildSectionTitle('KONDISI & TINDAK LANJUT'),
                  const SizedBox(height: 22),
                  _buildKondisiRow(),

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
      height: topPad + 150,
      decoration: const BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          // Back arrow
          Positioned(
            top: topPad + 60,
            left: 14,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Judul
          Positioned(
            top: topPad + 55,
            left: 66,
            right: 100,
            child: Text(
              'Detail Pemeriksaan',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 32 / 24,
              ),
            ),
          ),

          // Subtitle
          Positioned(
            top: topPad + 100,
            left: 66,
            child: Text(
              judul,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
                height: 32 / 13,
              ),
            ),
          ),

          // Status badge (kanan atas)
          Positioned(
            top: topPad + 80,
            right: 19,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _statusColor(status),
                  height: 13 / 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU TANGGAL + JUDUL =================
  Widget _buildTopCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 31),
      child: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgCream,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Kotak tanggal
            Container(
              width: 59,
              height: 63,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tglHari,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDarkDate,
                      height: 18 / 15,
                    ),
                  ),
                  Text(
                    tglBulan,
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

            // Judul + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    judul,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textBlack,
                      height: 18 / 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Diperiksa oleh kader posyandu',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textBlack.withValues(alpha: 0.25),
                      height: 15 / 12,
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

  // ================= SECTION TITLE =================
  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: primaryRed,
          height: 15 / 12,
        ),
      ),
    );
  }

  // ================= IDENTITAS =================
  Widget _buildIdentitas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Nama Lengkap | (kosong)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField('Nama Lengkap', 'Kentoz Albaiq')),
              Expanded(child: _buildField('Usia', '10 Bulan')),
            ],
          ),
          const SizedBox(height: 14),

          // Baris 2: Jenis Kelamin | Nama Orang Tua
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField('Jenis Kelamin', 'Laki-laki')),
              Expanded(child: _buildField('Nama Orang Tua', 'Ajeng Febria')),
            ],
          ),
          const SizedBox(height: 14),

          // Baris 3: Tempat & Tgl Lahir
          _buildField('Tempat & Tgl Lahir', 'Denpasar, 01/12/2025'),
          const SizedBox(height: 14),

          // Baris 4: Email
          _buildField('Email', 'AjengFebria01@gmail.com'),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textGrey,
            height: 12 / 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textBlack,
            height: 15 / 12,
          ),
        ),
      ],
    );
  }

  // ================= PARAMETER ANTROPOMETRI =================
  Widget _buildParameterRow() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildParamCard(beratBadan, 'BB (kg)')),
        const SizedBox(width: 12),
        Expanded(child: _buildParamCard(tinggiBadan, 'TB (cm)')),
        const SizedBox(width: 12),
        Expanded(child: _buildParamCard(lingkarKepala, 'LK (cm)')),
        const SizedBox(width: 12),
        Expanded(child: _buildParamCard(lila, 'LiLA (cm)')),
      ],
    ),
  );
}

Widget _buildParamCard(String value, String label) {
  return Container(
    constraints: const BoxConstraints(minHeight: 50),
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: bgSoftCream,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textBlack,
              height: 19 / 16,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textGrey,
              height: 12 / 10,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ===
  //============== CATATAN BOX =================
  Widget _buildCatatanBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        decoration: BoxDecoration(
          color: bgSoftCream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Catatan: $catatan',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textBlack,
            height: 15 / 12,
          ),
        ),
      ),
    );
  }

  // ================= BAHAN CHIPS =================
  Widget _buildBahanChips() {
    const bahan = ['Ayam', 'Telur', 'Sayuran', 'Buah'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 11,
        children: bahan.map((b) {
          return GestureDetector(
            onTap: () {
              // TODO: filter resep MPASI berdasarkan bahan ini
            },
            child: Container(
              width: 82.45,
              height: 31.51,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chipBg,
                border: Border.all(color: primaryRed, width: 0.5),
                borderRadius: BorderRadius.circular(31.5),
              ),
              child: Text(
                b,
                style: GoogleFonts.inter(
                  fontSize: 12.6,
                  fontWeight: FontWeight.w600,
                  color: textBlack,
                  height: 15 / 12.6,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= KONDISI & TINDAK LANJUT =================
  Widget _buildKondisiRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildKondisiField('Kondisi Balita', status)),
          Expanded(
            child: _buildKondisiField(
              'Pemeriksaan Berikutnya',
              pemeriksaanBerikutnya,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKondisiField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textGrey,
            height: 12 / 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textBlack,
            height: 15 / 12,
          ),
        ),
      ],
    );
  }
}