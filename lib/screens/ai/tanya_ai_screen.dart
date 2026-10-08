import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

// ================= MODEL CHILD (untuk AI) =================
class AiChildInfo {
  final String nama;
  final String umur;
  final String gender; // 'L' / 'P'
  final String alergi; // kosong kalau tidak ada

  const AiChildInfo({
    required this.nama,
    required this.umur,
    required this.gender,
    this.alergi = '',
  });
}

// ================= STATE =================
enum _AiStep {
  formEmpty,   // Gambar 1 — form kosong (belum pernah pakai)
  formFilled,  // Gambar 2 — form terisi (sudah pernah pakai)
  result,      // Gambar 3 — hasil AI
}

class TanyaAiScreen extends StatefulWidget {
  final AiChildInfo child;
  const TanyaAiScreen({super.key, required this.child});

  @override
  State<TanyaAiScreen> createState() => _TanyaAiScreenState();
}

class _TanyaAiScreenState extends State<TanyaAiScreen> {
  // Warna
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgInput    = Color(0x4DD9D9D9);
  static const Color textBlack  = Color(0xFF000000);
  static const Color textGrey   = Color(0xFF8F8F8F);
  static const Color textMuted  = Color(0xFF9E5665);
  static const Color chipBg     = Color(0x80F88B92);

  final _alergiC = TextEditingController();
  final _bahanC  = TextEditingController();

  late _AiStep _step;
  String _alergiFinal = '';
  String _bahanFinal = '';

  @override
  void initState() {
    super.initState();

    // Kalau anak sudah pernah pakai AI (alergi tersimpan)
    // → langsung buka di state formFilled (Gambar 2)
    if (widget.child.alergi.isNotEmpty) {
      _alergiC.text = widget.child.alergi;
      _alergiFinal = widget.child.alergi;
      _step = _AiStep.formFilled;
    } else {
      _step = _AiStep.formEmpty;
    }

    // Listener untuk refresh tombol kirim
    _bahanC.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _alergiC.dispose();
    _bahanC.dispose();
    super.dispose();
  }

  // ================= SUBMIT (step formEmpty) =================
  void _submitFromEmpty() {
    final alergi = _alergiC.text.trim();
    final bahan  = _bahanC.text.trim();

    if (bahan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi bahan di rumah dulu ya')),
      );
      return;
    }

    setState(() {
      _alergiFinal = alergi;
      _bahanFinal = bahan;
      _step = _AiStep.result;
    });
  }

  // ================= SUBMIT (step formFilled) =================
  void _submitFromFilled() {
    final bahan = _bahanC.text.trim();

    if (bahan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi bahan di rumah dulu ya')),
      );
      return;
    }

    setState(() {
      _bahanFinal = bahan;
      _step = _AiStep.result;
    });
  }

  // ================= SUBMIT LANJUTAN (dari step result) =================
  void _submitLanjutan() {
    final bahan = _bahanC.text.trim();

    if (bahan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi bahan dulu')),
      );
      return;
    }

    setState(() {
      _bahanFinal = bahan;
      // TODO: panggil API AI dengan bahan baru
    });
  }

  // ================= UBAH ALERGI =================
  void _ubahAlergi() {
    setState(() {
      _alergiC.text = _alergiFinal;
      _step = _AiStep.formEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  if (_step == _AiStep.formEmpty) _buildFormEmpty(),
                  if (_step == _AiStep.formFilled) _buildFormFilled(),
                  if (_step == _AiStep.result) _buildResult(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(double topPad) {
    return Container(
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
              'Tanya AI Resep',
              style: google_fonts.GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 32 / 24,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 27,
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

  // ================= STEP 1: FORM KOSONG (Gambar 1) =================
  Widget _buildFormEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildInfo(),
          const SizedBox(height: 20),

          Text(
            'Alergi',
            style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: _alergiC,
            hint: 'Ketik alergi Si Kecil',
          ),
          const SizedBox(height: 24),

          Text(
            'Bahan di rumah',
            style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
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

  // ================= STEP 2: FORM TERISI (Gambar 2) =================
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
                      Text(
                        'Alergi',
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textGrey,
                          height: 16 / 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _ubahAlergi,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'Ubah',
                          style: google_fonts.GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryRed,
                            height: 13 / 11,
                          ),
                        ),
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
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: 12.6,
                        fontWeight: FontWeight.w600,
                        color: textBlack,
                        height: 15 / 12.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Bahan di rumah',
            style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: _bahanC,
            hint: 'Punya bahan masakan apa di rumah?',
            onSend: _bahanC.text.isNotEmpty ? _submitFromFilled : null,
          ),
        ],
      ),
    );
  }

  // ================= STEP 3: HASIL (Gambar 3) =================
  Widget _buildResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      Text(
                        'Alergi',
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textGrey,
                          height: 16 / 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _ubahAlergi,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'Ubah',
                          style: google_fonts.GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryRed,
                            height: 13 / 11,
                          ),
                        ),
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
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: 12.6,
                        fontWeight: FontWeight.w600,
                        color: textBlack,
                        height: 15 / 12.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Bahan di rumah',
            style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 8),
          _inputFieldReadonly(
            text: _bahanFinal,
            onSend: _submitLanjutan,
          ),
          const SizedBox(height: 24),

          Text(
            'Ini resep MPASI untuk bayi ${widget.child.umur.toLowerCase()} '
            '${_alergiFinal.isNotEmpty ? "tanpa $_alergiFinal yang aman untuk alergi" : "sesuai kebutuhan"}.',
            style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 16),

          _sectionTitle('1. Nugget Ayam Homemade'),
          _paragraph(
            'Resep ini menggunakan tepung maizena sebagai pengganti telur '
            'agar adonan tetap padat dan aman untuk bayi alergi.',
          ),

          _sectionTitle('Bahan-bahan'),
          _bullet('Daging ayam: 120 gram (fillet)'),
          _bullet('Wortel: 10 gram (cincang halus)'),
          _bullet('Tepung maizena: 1 sdm'),
          _bullet('Kaldu bubuk MPASI: Secukupnya'),
          _bullet('Minyak kelapa: Secukupnya untuk menggoreng'),

          _sectionTitle('Cara Membuat'),
          _paragraph('1. Chopper ayam, wortel, dan tepung maizena hingga halus.'),
          _paragraph('2. Bentuk adonan menjadi adonan padat di wadah anti panas.'),
          _paragraph('3. Kukus selama matang, lalu potong kecil-kecil.'),

          const SizedBox(height: 16),
          _sectionTitle('2. Sosis Ayam Homemade'),
          _paragraph(
            'Menu ini menggunakan tepung pati garut sebagai pengikat '
            'alami yang aman untuk bayi.',
          ),
          _sectionTitle('Bahan-bahan'),
          _bullet('Daging ayam: 400 gram (fillet)'),
          _bullet('Wortel: 1 buah (ukuran sedang)'),
          _bullet('Bawang bombay: 1/2 buah'),
          _bullet('Tepung pati garut: 3 sdm'),

          _sectionTitle('Cara Membuat'),
          _paragraph('1. Haluskan semua bahan menggunakan chopper.'),
          _paragraph('2. Bentuk adonan menjadi sosis.'),
          _paragraph('3. Kukus hingga matang dan tekstur lembut.'),

          _sectionTitle('Tips Penting'),
          _bullet('Pengecekan tekstur: Pastikan tekstur makanan sudah sesuai '
              'dengan kemampuan kunyah bayi.'),
          _bullet('Hindari tambahan garam: Jangan menambahkan bumbu tambahan '
              'sebelum bayi berusia 1 tahun.'),
          _bullet('Simpan sisa makanan: Simpan di wadah tertutup di kulkas '
              'untuk stok MPASI.'),

          const SizedBox(height: 24),
          Divider(color: Colors.grey.withValues(alpha: 0.3)),

          Text(
            'Bahan di rumah',
            style: google_fonts.GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textBlack,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: _bahanC,
            hint: 'Punya bahan masakan apa di rumah?',
            onSend: _bahanC.text.isNotEmpty ? _submitLanjutan : null,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _buildChildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Untuk si kecil',
          style: google_fonts.GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textGrey,
            height: 16 / 13,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              widget.child.nama,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textBlack,
                height: 24 / 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: textBlack,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.child.umur,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textBlack,
                height: 13 / 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(
        text,
        style: google_fonts.GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textBlack,
          height: 16 / 13,
        ),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      style: google_fonts.GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textBlack,
        height: 16 / 13,
      ),
    );
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
                color: textBlack,
                shape: BoxShape.circle,
              ),
            ),
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
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      decoration: BoxDecoration(
        color: bgInput,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textBlack,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: google_fonts.GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textGrey,
                ),
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
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: textMuted,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputFieldReadonly({
    required String text,
    required VoidCallback onSend,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      decoration: BoxDecoration(
        color: bgInput,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textBlack,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSend,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: textMuted,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}