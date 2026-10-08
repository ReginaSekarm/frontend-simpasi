import 'package:flutter/material.dart';

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

// ================= MODEL SECTION =================
enum SectionType { paragraph, heading, subHeading, bulletList, numberList }

class PencarianSection {
  final SectionType type;
  final String? text;
  final List<String>? items;
  final String? highlightText; // untuk bold di dalam paragraph

  const PencarianSection({
    required this.type,
    this.text,
    this.items,
    this.highlightText,
  });
}

class DetailPencarianScreen extends StatelessWidget {
  final List<String> keywords;

  const DetailPencarianScreen({
    super.key,
    required this.keywords,
  });

  // Warna dari Figma
  static const Color primaryRed   = Color(0xFFD45060);
  static const Color bgBlue       = Color(0x8076C0EC); // 50% alpha
  static const Color textBlack    = Color(0xFF000000);

  String get _judulHighlight {
    if (keywords.isEmpty) return '';
    if (keywords.length == 1) return keywords[0];
    if (keywords.length == 2) return '${keywords[0]} dan ${keywords[1]}';
    // 3+: A, B, dan C
    final all = keywords.sublist(0, keywords.length - 1).join(', ');
    return '$all, dan ${keywords.last}';
  }

  // ================= DATA DUMMY =================
  List<PencarianSection> get _sections => const [
        PencarianSection(
          type: SectionType.paragraph,
          text: 'Ini resep MPASI untuk bayi 10 bulan tanpa telur yang aman '
              'untuk alergi.',
        ),
        PencarianSection(
          type: SectionType.subHeading,
          text: '1. Nugget Ayam Homemade Tanpa Telur',
        ),
        PencarianSection(
          type: SectionType.paragraph,
          text: 'Resep ini menggunakan tepung maizena sebagai pengganti telur '
              'agar adonan tetap padat dan aman untuk bayi alergi telur.',
        ),
        PencarianSection(type: SectionType.heading, text: 'Bahan-bahan'),
        PencarianSection(
          type: SectionType.bulletList,
          items: [
            'Daging ayam: 120 gram (fillet)',
            'Wortel: 10 gram (cincang halus)',
            'Tepung maizena: 1 sdm',
            'Kaldu bubuk MPASI: Secukupnya',
            'Minyak kelapa: Secukupnya untuk menggoreng',
          ],
        ),
        PencarianSection(type: SectionType.heading, text: 'Cara Membuat'),
        PencarianSection(
          type: SectionType.numberList,
          items: [
            'Chopper ayam, wortel, dan tepung maizena hingga halus.',
            'Bentuk adonan menjadi adonan padat di wadah anti panas.',
            'Kukus selama matang, lalu potong kecil-kecil.',
          ],
        ),
        PencarianSection(
          type: SectionType.subHeading,
          text: '2. Sosis Ayam Homemade Tanpa Telur',
        ),
        PencarianSection(
          type: SectionType.paragraph,
          text: 'Menu ini menggunakan tepung pati garut sebagai pengikat '
              'alami yang aman untuk bayi.',
        ),
        PencarianSection(type: SectionType.heading, text: 'Bahan-bahan'),
        PencarianSection(
          type: SectionType.bulletList,
          items: [
            'Daging ayam: 400 gram (fillet)',
            'Wortel: 1 buah (ukuran sedang)',
            'Bawang bombay: 1/2 buah',
            'Tepung pati garut: 3 sdm',
            'Minyak jagung: 2 sdm',
          ],
        ),
        PencarianSection(type: SectionType.heading, text: 'Cara Membuat'),
        PencarianSection(
          type: SectionType.numberList,
          items: [
            'Haluskan semua bahan menggunakan chopper.',
            'Bentuk adonan menjadi sosis.',
            'Kukus hingga matang dan tekstur lembut.',
          ],
        ),
        PencarianSection(type: SectionType.heading, text: 'Tips Penting'),
        PencarianSection(
          type: SectionType.bulletList,
          items: [
            'Pengecekan tekstur: Pastikan tekstur makanan sudah sesuai '
                'dengan kemampuan kunyah bayi.',
            'Hindari tambahan garam: Jangan menambahkan bumbu tambahan '
                'sebelum bayi berusia 1 tahun.',
            'Simpan sisa makanan: Simpan di wadah tertutup di kulkas '
                'untuk stok MPASI.',
          ],
        ),
        PencarianSection(
          type: SectionType.paragraph,
          text: 'Apakah kamu ingin mencoba resep lain dengan bahan '
              'yang berbeda?',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 31, 12, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= BLUE CARD =================
                  _buildBlueCard(),

                  const SizedBox(height: 33),

                  // ================= BODY =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _sections.map(_buildSection).toList(),
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
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Judul
          Positioned(
            top: topPad + 56,
            left: 66,
            child: Text(
              'Detail Pencarian',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 32 / 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BLUE CARD =================
  Widget _buildBlueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
      decoration: BoxDecoration(
        color: bgBlue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textBlack,
            height: 17 / 14,
          ),
          children: [
            const TextSpan(text: 'Berikut resep MPASI dari '),
            TextSpan(
              text: _judulHighlight,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textBlack,
                height: 17 / 14,
              ),
            ),
            const TextSpan(
              text: ' yang menyesuaikan dengan kebutuhan si kecil',
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECTION BUILDER =================
  Widget _buildSection(PencarianSection s) {
    switch (s.type) {
      case SectionType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            s.text ?? '',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
        );

      case SectionType.subHeading:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            s.text ?? '',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
        );

      case SectionType.heading:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14, top: 6),
          child: Text(
            s.text ?? '',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
        );

      case SectionType.bulletList:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (s.items ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: textBlack,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textBlack,
                          height: 16 / 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case SectionType.numberList:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                List.generate((s.items ?? []).length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${i + 1}.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textBlack,
                          height: 16 / 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        s.items![i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textBlack,
                          height: 16 / 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
    }
  }
}