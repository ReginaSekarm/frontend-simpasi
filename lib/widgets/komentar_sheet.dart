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

// ================= MODEL KOMENTAR =================
class KomentarItem {
  final String nama;
  final String? waktu; // null = belum ada waktu
  final String teks;
  final List<KomentarItem> balasan; // 👈 nested replies

  const KomentarItem({
    required this.nama,
    this.waktu,
    required this.teks,
    this.balasan = const [],
  });

  bool get adaBalasan => balasan.isNotEmpty;
}

// ================= BOTTOM SHEET KOMENTAR =================
class KomentarSheet extends StatefulWidget {
  final String recipeTitle;

  const KomentarSheet({super.key, required this.recipeTitle});

  @override
  State<KomentarSheet> createState() => _KomentarSheetState();
}

class _KomentarSheetState extends State<KomentarSheet> {
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textGrey    = Color(0xFF8F8F8F);
  static const Color inputBg     = Color(0xFFD9D9D9);
  static const Color dividerGrey = Color(0xFFD9D9D9);

  final _controller = TextEditingController();

  // Set index komentar yang sedang di-expand (lihat balasan)
  final Set<int> _expanded = {};

  // Data dummy — nanti ganti dengan data dari backend
  final List<KomentarItem> _komentar = [
    const KomentarItem(
      nama: 'Wowo',
      waktu: '1 hari',
      teks: 'Sebelum dihaluskan, ubi ungu perlu didiamkan sampai '
          'dingin dulu atau langsung dihaluskan selagi panas?',
    ),
    const KomentarItem(
      nama: 'Uni',
      teks: 'Dirumah cuma ada kimpul, ubi ungu nya bisa diganti '
          'kimpul aja ga bun?Tolong dijawab ya',
      // 👇 Balasan-balasan untuk komentar Uni
      balasan: [
        KomentarItem(
          nama: 'Bunda Aisyah',
          waktu: '20 jam',
          teks: 'Bisa banget Bun, kimpul teksturnya mirip ubi ungu. '
              'Kukus dulu ya sebelum dihaluskan.',
        ),
        KomentarItem(
          nama: 'Uni',
          waktu: '18 jam',
          teks: 'Oke bun, makasih infonya 🙏',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _kirim() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;

    setState(() {
      _komentar.insert(
        0,
        KomentarItem(nama: 'Aisyah', waktu: 'Baru saja', teks: t),
      );
      _controller.clear();
    });

    FocusScope.of(context).unfocus();
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        _expanded.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(27, 14, 27, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= DRAG HANDLE =================
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dividerGrey,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ================= HEADING =================
                Text(
                  'Komentar (${_komentar.length})',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textBlack,
                    height: 18 / 15,
                  ),
                ),
                const SizedBox(height: 19),

                // ================= LIST KOMENTAR =================
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < _komentar.length; i++) ...[
                          if (i > 0) const SizedBox(height: 19),
                          _buildComment(
                            _komentar[i],
                            isExpanded: _expanded.contains(i),
                            onToggle: () => _toggleExpand(i),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 44),

                // ================= INPUT =================
                _buildInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SATU KOMENTAR =================
  Widget _buildComment(
    KomentarItem k, {
    bool isExpanded = false,
    VoidCallback? onToggle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 35,
          height: 35,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 15),

        // Kolom kanan
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama + waktu
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    k.nama,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textBlack,
                      height: 18 / 15,
                    ),
                  ),
                  if (k.waktu != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      k.waktu!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                        height: 12 / 10,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),

              // Isi komentar
              Text(
                k.teks,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textBlack,
                  height: 15 / 12,
                ),
              ),
              const SizedBox(height: 6),

              // Aksi: Balas + Lihat/Sembunyikan balasan
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: balas komentar ini
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Balas',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: textGrey,
                          height: 15 / 12,
                        ),
                      ),
                    ),
                  ),

                  // 👇 Tombol Lihat / Sembunyikan balasan
                  if (k.adaBalasan) ...[
                    const SizedBox(width: 32),
                    GestureDetector(
                      onTap: onToggle,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          isExpanded
                              ? 'Sembunyikan balasan'
                              : 'Lihat balasan (${k.balasan.length})',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: textGrey,
                            height: 15 / 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // 👇 Balasan (nested) — tampil hanya kalau di-expand
              if (k.adaBalasan && isExpanded) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: dividerGrey, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < k.balasan.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        _buildComment(k.balasan[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ================= INPUT FIELD =================
  Widget _buildInput() {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 18, right: 14),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _kirim(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: textBlack,
                height: 19 / 16,
              ),
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textGrey,
                  height: 19 / 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _kirim,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.send_outlined,
                size: 22,
                color: primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}