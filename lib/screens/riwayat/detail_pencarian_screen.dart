import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:flutter_svg/flutter_svg.dart';

class DetailPencarianScreen extends StatefulWidget {
  final List<String> keywords;

  const DetailPencarianScreen({
    super.key,
    required this.keywords,
  });

  @override
  State<DetailPencarianScreen> createState() => _DetailPencarianScreenState();
}

class _DetailPencarianScreenState extends State<DetailPencarianScreen> {
  // Warna dari Figma
  static const Color primaryRed = Color(0xFFD45060);
  static const Color bgInput    = Color(0x4DD9D9D9);
  static const Color textBlack  = Color(0xFF000000);
  static const Color textGrey   = Color(0xFF8F8F8F);
  static const Color textMuted  = Color(0xFF9E5665);
  static const Color chipBg     = Color(0x80F88B92);

  final ScrollController _scroll = ScrollController();
  bool _showScrollDown = false;

  // Format kata dari keywords (contoh: ['Ayam', 'Wortel'] -> 'Ayam dan Wortel')
  String get _judulHighlight {
    if (widget.keywords.isEmpty) return '';
    if (widget.keywords.length == 1) return widget.keywords[0];
    if (widget.keywords.length == 2) return '${widget.keywords[0]} dan ${widget.keywords[1]}';
    final all = widget.keywords.sublist(0, widget.keywords.length - 1).join(', ');
    return '$all, dan ${widget.keywords.last}';
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    final show = p.maxScrollExtent - p.pixels > 60;
    if (show != _showScrollDown) setState(() => _showScrollDown = show);
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _buildDetailHeader(topPad),
            Expanded(
              child: Stack(
                children: [
                  // ================= KONTEN UTAMA =================
                  SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 160),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildContent(),
                      ],
                    ),
                  ),

                  // ================= INPUT BAR MELAYANG =================
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 21,
                        right: 21,
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 10,
                            offset: Offset(0, -4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _inputField(),
                          const SizedBox(height: 10),
                          Text(
                            'AI bisa saja membuat kesalahan. Cek ulang bahan dan takaran resep.',
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= TOMBOL SCROLL KE BAWAH =================
                  if (_showScrollDown)
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
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
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

  // ================= HEADER DETAIL PENCARIAN =================
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
          // Tombol kembali
          Positioned(
            left: 16,
            bottom: 32,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 24,
                height: 34,
                child: Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.white),
              ),
            ),
          ),

          // Judul
          Positioned(
            left: 56,
            bottom: 32,
            child: Text(
              'Detail Pencarian',
              style: google_fonts.GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          // Pil: Riwayat + Obrolan baru
          Positioned(
            right: 26,
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
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      'assets/images/basil--history-solid.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      'assets/images/ep--edit.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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

  // ================= KONTEN (INFO ANAK, CHAT, & RESEP) =================
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info (Anak & Alergi)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Untuk si kecil', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textGrey)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Alaia', style: google_fonts.GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textBlack)),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: textBlack, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('18 Bulan', style: google_fonts.GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textBlack)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF88BBDC), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Kondisi: Normal', style: google_fonts.GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textBlack)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Alergi', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textGrey)),
                      const SizedBox(width: 12),
                      Text('Ubah', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primaryRed)),
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
                      'Telur',
                      style: google_fonts.GoogleFonts.inter(fontSize: 12.6, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEAEAEA), thickness: 1),

          // Timestamp
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '10.20 AM',
                style: google_fonts.GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: textGrey),
              ),
            ),
          ),

          // User Chat Bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 178,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bahan di rumah', style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF797777))),
                  const SizedBox(height: 6),
                  Text(
                    widget.keywords.join(', ').toLowerCase(),
                    style: google_fonts.GoogleFonts.inter(fontSize: 12.9, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Teks Pembuka AI (Bold pada bahan)
          RichText(
            text: TextSpan(
              style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textBlack, height: 16 / 13),
              children: [
                const TextSpan(text: 'Berikut resep MPASI dari '),
                TextSpan(
                  text: _judulHighlight,
                  style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: textBlack, height: 16 / 13),
                ),
                const TextSpan(text: ' yang disesuaikan dengan status gizi Alaia (Normal) dan alergi telur.'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _sectionTitle('1. Nugget ${widget.keywords.isNotEmpty ? widget.keywords.first : "Bahan"} Homemade Tanpa Telur'),
          _paragraph('Resep ini menggunakan tepung maizena sebagai pengganti telur agar adonan tetap padat dan aman untuk bayi alergi telur.'),

          _sectionTitle('Bahan-bahan'),
          _bullet('Daging ${widget.keywords.isNotEmpty ? widget.keywords.first.toLowerCase() : "utama"}: 120 gram (fillet)'),
          _bullet('Wortel: 10 gram (cincang halus)'),
          _bullet('Tepung maizena: 1 sdm'),
          _bullet('Kaldu bubuk MPASI: Secukupnya'),
          _bullet('Minyak kelapa: Secukupnya untuk menggoreng'),

          _sectionTitle('Cara Membuat'),
          _paragraph('1. Chopper ${widget.keywords.isNotEmpty ? widget.keywords.first.toLowerCase() : "bahan"}, wortel, dan tepung maizena hingga halus.'),
          _paragraph('2. Bentuk adonan menjadi adonan padat di wadah anti panas.'),
          _paragraph('3. Kukus selama matang, lalu potong kecil-kecil.'),

          const SizedBox(height: 16),
          _sectionTitle('2. Sosis ${widget.keywords.isNotEmpty ? widget.keywords.first : "Bahan"} Homemade Tanpa Telur'),
          _paragraph('Menu ini menggunakan tepung pati garut sebagai pengikat alami yang aman untuk bayi.'),

          _sectionTitle('Bahan-bahan'),
          _bullet('Daging ${widget.keywords.isNotEmpty ? widget.keywords.first.toLowerCase() : "utama"}: 400 gram (fillet)'),
          _bullet('Wortel: 1 buah (ukuran sedang)'),
          _bullet('Bawang bombay: 1/2 buah'),
          _bullet('Tepung pati garut: 3 sdm'),
          _bullet('Minyak jagung: 2 sdm'),

          _sectionTitle('Cara Membuat'),
          _paragraph('1. Haluskan semua bahan menggunakan chopper.'),
          _paragraph('2. Bentuk adonan menjadi sosis.'),
          _paragraph('3. Kukus hingga matang dan tekstur lembut.'),

          _sectionTitle('Tips Penting'),
          _bullet('Pengecekan tekstur: Pastikan tekstur makanan sudah sesuai dengan kemampuan kunyah bayi.'),
          _bullet('Hindari tambahan garam: Jangan menambahkan bumbu tambahan sebelum bayi berusia 1 tahun.'),
          _bullet('Simpan sisa makanan: Simpan di wadah tertutup di kulkas untuk stok MPASI.'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ================= BOTTOM INPUT FIELD =================
  Widget _inputField() {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.fromLTRB(20, 3, 3, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(86),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textBlack),
              decoration: InputDecoration(
                hintText: 'Lanjutkan obrolan ini',
                hintStyle: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textGrey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: textMuted, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_upward_rounded, size: 22, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(text, style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: textBlack)),
    );
  }

  Widget _paragraph(String text) {
    return Text(text, style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textBlack, height: 16 / 13));
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: textBlack, shape: BoxShape.circle)),
          ),
          Expanded(child: _paragraph(text)),
        ],
      ),
    );
  }
}