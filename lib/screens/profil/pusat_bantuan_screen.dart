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

// ================= MODEL FAQ =================
class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class PusatBantuanScreen extends StatefulWidget {
  const PusatBantuanScreen({super.key});

  @override
  State<PusatBantuanScreen> createState() => _PusatBantuanScreenState();
}

class _PusatBantuanScreenState extends State<PusatBantuanScreen> {
  // Warna dari Figma
  static const Color textBlack     = Color(0xFF000000);
  static const Color textBlack50   = Color(0x80000000);
  static const Color cardBg        = Color(0x80D9D9D9); // rgba(217,217,217,0.5)
  static const Color dividerColor  = Color(0x80AAA6A6); // rgba(170,166,166,0.5)

  // Index yang sedang expand (null = tidak ada yang expand)
  int? _expandedIndex;

  // Daftar FAQ + jawaban
  static const List<_FaqItem> _faq = [
    _FaqItem(
      question: 'Bagaimana cara mengganti kata sandi?',
      answer: 'Buka menu Profil → Pengaturan → Ganti Kata Sandi. '
          'Masukkan kata sandi lama, lalu kata sandi baru dua kali '
          'untuk konfirmasi.',
    ),
    _FaqItem(
      question: 'Bagaimana cara menghapus akun saya?',
      answer: 'Buka menu Profil → Pengaturan → Hapus akun. '
          'Konfirmasi tindakan ini karena data tidak dapat dikembalikan.',
    ),
    _FaqItem(
      question: 'Bagaimana cara menambahkan data balita?',
      answer: 'Buka menu Home, tap ikon pengaturan di kartu data anak, '
          'lalu pilih "Ubah Data" untuk menambahkan atau memperbarui '
          'data balita Anda.',
    ),
    _FaqItem(
      question: 'Kenapa status balita saya berubah jadi '
          '"Berisiko Stunting"?',
      answer: 'Status ini otomatis dihitung berdasarkan hasil pengukuran '
          'berat badan, tinggi badan, dan lingkar kepala balita Anda. '
          'Jika hasilnya di bawah standar, status akan berubah. '
          'Segera konsultasikan ke kader Posyandu atau dokter anak.',
    ),
    _FaqItem(
      question: 'Siapa yang membuat resep-resep di aplikasi ini?',
      answer: 'Resep dibuat dan diunggah oleh kader Posyandu di '
          'wilayahmu, jadi disesuaikan dengan bahan-bahan yang umum '
          'tersedia di daerah setempat.',
    ),
  ];

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
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
            Padding(
              padding: EdgeInsets.fromLTRB(15, topPad + 60, 15, 0),
              child: SizedBox(
                height: 32,
                child: Stack(
                  children: [
                    // Back arrow
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.chevron_left,
                            size: 32,
                            color: textBlack,
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Center(
                      child: Text(
                        'Pusat Bantuan',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textBlack,
                          height: 29 / 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= FAQ LIST =================
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 39, 15, 40),
              child: Column(
                children: [
                  for (int i = 0; i < _faq.length; i++) ...[
                    if (i > 0) const SizedBox(height: 15),
                    _buildFaqCard(
                      index: i,
                      item: _faq[i],
                      isExpanded: _expandedIndex == i,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FAQ CARD (accordion) =================
  Widget _buildFaqCard({
    required int index,
    required _FaqItem item,
    required bool isExpanded,
  }) {
    return GestureDetector(
      onTap: () => _toggle(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Baris 1: Pertanyaan + Arrow ----
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 15, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Teks pertanyaan
                  Expanded(
                    child: Text(
                      item.question,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textBlack,
                        height: 19 / 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Chevron — animasi rotasi 90° saat expand
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0, // 0.25 = 90°
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: textBlack,
                    ),
                  ),
                ],
              ),
            ),

            // ---- Baris 2: Divider + Jawaban (kalau expanded) ----
            if (isExpanded) ...[
              // Divider
              Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: dividerColor,
              ),

              // Jawaban
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Text(
                  item.answer,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textBlack50,
                    height: 17 / 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}