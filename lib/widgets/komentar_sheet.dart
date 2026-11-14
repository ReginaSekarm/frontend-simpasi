import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final String? waktu;
  final DateTime? postedAt;
  String teks;
  final List<KomentarItem> balasan;

  KomentarItem({
    required this.nama,
    this.waktu,
    this.postedAt,
    required this.teks,
    List<KomentarItem>? balasan,
  }) : balasan = balasan ?? [];

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
  static const Color blueTag     = Color(0xFF006199);

  static const String myName = 'Aisyah';

  final List<String> _knownNames = ['Siti Amaliah', 'Aisyah', 'Uni', 'Wowo'];

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  final Set<KomentarItem> _expanded = {};
  KomentarItem? _replyTo;

  final List<KomentarItem> _komentar = [
    KomentarItem(
      nama: 'Wowo',
      waktu: '1 hari',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      teks: 'Sebelum dihaluskan, ubi ungu perlu didiamkan sampai '
          'dingin dulu atau langsung dihaluskan selagi panas?',
      balasan: [
        KomentarItem(
          nama: 'Siti Amaliah',
          waktu: '20 jam',
          postedAt: DateTime.now().subtract(const Duration(hours: 20)),
          teks: '@Wowo Bisa banget bun, kimpul teksturnya mirip ubi ungu. '
              'Kukus dulu ya sebelum dihaluskan.',
        ),
      ],
    ),
    KomentarItem(
      nama: 'Uni',
      waktu: '1 hari',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      teks: 'Dirumah cuma ada kimpul, ubi ungu nya bisa diganti '
          'kimpul aja ga bun?Tolong dijawab ya',
      balasan: [
        KomentarItem(
          nama: 'Aisyah',
          waktu: '20 jam',
          postedAt: DateTime.now().subtract(const Duration(hours: 20)),
          teks: '@Uni Bisa banget bun, kimpul teksturnya mirip ubi ungu. '
              'Kukus dulu ya sebelum dihaluskan.',
        ),
        KomentarItem(
          nama: 'Uni',
          waktu: '18 jam',
          postedAt: DateTime.now().subtract(const Duration(hours: 18)),
          teks: '@Aisyah Oke bun, makasih infonya 🙏',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _expanded.add(_komentar[1]); 
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleReply(KomentarItem target) {
    setState(() {
      _replyTo = target;
      _controller.text = '@${target.nama} ';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    _focusNode.requestFocus();
  }

  void _kirim() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;

    setState(() {
      final newKomentar = KomentarItem(
        nama: myName,
        waktu: 'Baru saja',
        postedAt: DateTime.now(),
        teks: t,
      );

      if (_replyTo != null) {
        _replyTo!.balasan.add(newKomentar);
        _expanded.add(_replyTo!);
        
        for (var root in _komentar) {
          if (root == _replyTo) {
          } else if (root.balasan.contains(_replyTo)) {
            _expanded.add(root);
          } else {
            for (var sub in root.balasan) {
              if (sub.balasan.contains(_replyTo)) {
                _expanded.add(root);
                _expanded.add(sub);
              }
            }
          }
        }
      } else {
        _komentar.insert(0, newKomentar);
      }
      
      _controller.clear();
      _replyTo = null;
    });

    FocusScope.of(context).unfocus();
  }

  void _toggleExpand(KomentarItem item) {
    setState(() {
      if (_expanded.contains(item)) {
        _expanded.remove(item);
      } else {
        _expanded.add(item);
      }
    });
  }

  // POPUP HAPUS KOMENTAR (GAYA INSTAGRAM: BLUR + KOMENTAR MENONJOL + MENU HAPUS)
  void _showDeletePopup(KomentarItem k, BuildContext commentContext) {
    final RenderBox box = commentContext.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size screen = MediaQuery.of(context).size;
    final double bottomSafe = MediaQuery.of(context).padding.bottom;

    final bool canEdit = k.nama == myName &&
        k.postedAt != null &&
        DateTime.now().difference(k.postedAt!).inHours < 24;

    // Posisi komentar yang ditonjolkan (sama dengan posisi aslinya)
    const double pad = 8;
    final double width = (box.size.width + pad * 2).clamp(0.0, screen.width).toDouble();
    final double left = (position.dx - pad).clamp(0.0, screen.width - width).toDouble();

    // Kalau komentar terlalu dekat dengan bawah layar, geser naik sedikit
    // supaya menu Hapus tetap terlihat
    final double maxTop = screen.height - bottomSafe - 190;
    double top = position.dy - pad;
    if (top > maxTop) top = maxTop;
    if (top < 0) top = 0;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Latar blur + gelap, ketuk di sini untuk menutup
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(ctx),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: const Color(0x73000000)),
                  ),
                ),
              ),

              Positioned(
                left: left,
                top: top,
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Komentar yang dipilih (menonjol)
                    Container(
                      padding: const EdgeInsets.all(pad),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // === AVATAR DI POPUP HAPUS ===
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              image: k.nama == 'Siti Amaliah'
                                  ? const DecorationImage(
                                      image: AssetImage('assets/images/profil-kader.png'), // GANTI PATH INI
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: k.nama != 'Siti Amaliah'
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                _buildCommentText(k.teks),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Balas',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textGrey,
                                        height: 15 / 12,
                                      ),
                                    ),
                                    if (canEdit) ...[
                                      const SizedBox(width: 15),
                                      Text(
                                        'Edit',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textGrey,
                                          height: 15 / 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Menu: hanya "Hapus"
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: 170,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0x33D9D9D9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _hapusKomentarDariList(k);
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/trash-fill.svg',
                                    width: 22,
                                    height: 22,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFFF0020),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Hapus',
                                    maxLines: 1,
                                    softWrap: false,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFFF0020),
                                      height: 19 / 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  void _hapusKomentarDariList(KomentarItem target) {
    _komentar.removeWhere((element) => element == target);
    for (var item in _komentar) {
      item.balasan.removeWhere((element) => element == target);
      for (var sub in item.balasan) {
        sub.balasan.removeWhere((element) => element == target);
      }
    }
    _expanded.remove(target); 
  }

  // FUNGSI EDIT KOMENTAR DIPERBARUI (GAYA INSTAGRAM)
  void _editKomentar(KomentarItem k) {
    final textController = TextEditingController(text: k.teks);
    final FocusNode editFocusNode = FocusNode();

    // Otomatis fokus ke keyboard saat muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editFocusNode.requestFocus();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa naik saat keyboard muncul
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Mengedit balasan & Tombol X)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mengedit balasan',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: textGrey, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Area Input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === AVATAR DI EDIT KOMENTAR ===
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        image: k.nama == 'Siti Amaliah'
                            ? const DecorationImage(
                                image: AssetImage('assets/images/foto_siti.png'), // GANTI PATH INI
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: k.nama != 'Siti Amaliah'
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    // Kotak Input
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2), // Background abu-abu terang
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: textController,
                          focusNode: editFocusNode,
                          maxLines: null,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: textBlack,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tombol Simpan
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        k.teks = textController.text.trim();
                      });
                    },
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      editFocusNode.dispose();
      textController.dispose();
    });
  }

  Widget _buildCommentText(String text) {
    if (text.startsWith('@')) {
      for (String name in _knownNames) {
        final tagWithSpace = '@$name '; 
        
        if (text.startsWith(tagWithSpace)) {
          final tag = tagWithSpace.trim(); 
          final rest = text.substring(tagWithSpace.length); 

          // SEMUA TAG MENJADI BIRU
          final Color tagColor = blueTag; 

          return RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textBlack,
                height: 15 / 12,
              ),
              children: [
                TextSpan(
                  text: '$tag ',
                  style: TextStyle(color: tagColor), 
                ),
                TextSpan(text: rest),
              ],
            ),
          );
        }
      }
    }
    
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textBlack,
        height: 15 / 12,
      ),
    );
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

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < _komentar.length; i++) ...[
                          if (i > 0) const SizedBox(height: 19),
                          _buildComment(_komentar[i]),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 44),

                _buildInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComment(KomentarItem k) {
    final isMe = k.nama == myName;
    final isExpanded = _expanded.contains(k);
    final canEdit = isMe &&
        k.postedAt != null &&
        DateTime.now().difference(k.postedAt!).inHours < 24;

    return Builder(
      builder: (commentContext) {
        return GestureDetector(
          onLongPress: isMe ? () => _showDeletePopup(k, commentContext) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === AVATAR DI DAFTAR KOMENTAR UTAMA ===
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  image: k.nama == 'Siti Amaliah'
                      ? const DecorationImage(
                          image: AssetImage('assets/images/profil-kader.png'), 
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: k.nama != 'Siti Amaliah'
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        if (k.nama == 'Siti Amaliah') ...[
                          // === BAGIAN YANG DIUBAH: TITIK (DOT) ===
                          const SizedBox(width: 3),
                          SizedBox(
                            width: 6,
                            height: 6,
                            child: Center(
                              child: Container(
                                width: 2.5,
                                height: 2.5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF797777),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          // =========================================
                          Text(
                            'Pembuat',
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

                    _buildCommentText(k.teks),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _handleReply(k),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Balas',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                height: 15 / 12,
                              ),
                            ),
                          ),
                        ),
                        if (canEdit) ...[
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => _editKomentar(k),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                'Edit',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textGrey,
                                  height: 15 / 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (k.adaBalasan) ...[
                          const SizedBox(width: 27),
                          GestureDetector(
                            onTap: () => _toggleExpand(k),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                isExpanded
                                    ? 'Sembunyikan balasan'
                                    : 'Lihat balasan (${k.balasan.length})',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textGrey,
                                  height: 15 / 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

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
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 24, right: 14), // Padding kiri disesuaikan agar teks agak ke tengah
      decoration: BoxDecoration(
        color: Colors.white, // Background putih sesuai Figma
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFD9D9D9), // Border abu-abu tipis sesuai Figma
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
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
                  color: const Color(0xFF8E8E8E), // Warna hint sesuai Figma
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
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                'assets/images/paper-plane-outline.svg',
                width: 20, // Ukuran ikon disesuaikan dengan Figma
                height: 20,
                colorFilter: const ColorFilter.mode(
                  primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}