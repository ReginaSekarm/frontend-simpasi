import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:flutter_svg/flutter_svg.dart'; 

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
  formEmpty,   
  formFilled,  
  result,      
  detail,      // 👈 Detail Pencarian (dari riwayat) = Generate AI-4
}

class TanyaAiScreen extends StatefulWidget {
  final AiChildInfo child;
  const TanyaAiScreen({super.key, required this.child});

  @override
  State<TanyaAiScreen> createState() => _TanyaAiScreenState();
}

class _TanyaAiScreenState extends State<TanyaAiScreen> {
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

  bool _isLoadingAI = false;

  // untuk halaman Detail Pencarian
  final ScrollController _scroll = ScrollController();
  bool _showScrollDown = false;
  _AiStep _stepBeforeDetail = _AiStep.formEmpty;
  String _bahanBeforeDetail = '';

  @override
  void initState() {
    super.initState();

    if (widget.child.alergi.isNotEmpty) {
      _alergiC.text = widget.child.alergi;
      _alergiFinal = widget.child.alergi;
      _step = _AiStep.formFilled;
    } else {
      _step = _AiStep.formEmpty;
    }

    _bahanC.addListener(() => setState(() {}));
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _alergiC.dispose();
    _bahanC.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ================= FORMAT BAHAN =================
  String _formatBahan(String input) {
    if (input.isEmpty) return 'Bahan Utama';
    final parts = input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts[0][0].toUpperCase() + parts[0].substring(1).toLowerCase();
    } else if (parts.length == 2) {
      final p1 = parts[0][0].toUpperCase() + parts[0].substring(1).toLowerCase();
      final p2 = parts[1][0].toUpperCase() + parts[1].substring(1).toLowerCase();
      return '$p1 dan $p2';
    }
    return input;
  }

  // ================= DETAIL PENCARIAN (dari riwayat) =================
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

  void _openDetail({required String bahan}) {
    FocusScope.of(context).unfocus();
    _bahanC.clear();
    setState(() {
      if (_step != _AiStep.detail) {
        _stepBeforeDetail = _step;
        _bahanBeforeDetail = _bahanFinal;
      }
      _bahanFinal = bahan;
      
      _alergiFinal = 'Telur'; 
      _alergiC.text = 'Telur';
      
      _isLoadingAI = false;
      _step = _AiStep.detail;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scroll.hasClients) _scroll.jumpTo(0);
      _onScroll();
    });
  }

  // PERBAIKAN: Selalu kembali ke form input dengan alergi yang sudah terisi 
  void _closeDetail() {
    FocusScope.of(context).unfocus();
    _bahanC.clear();
    setState(() {
      // Paksa state kembali ke formFilled (jika ada alergi) atau formEmpty
      _step = _alergiFinal.isNotEmpty ? _AiStep.formFilled : _AiStep.formEmpty;
      _bahanFinal = ''; // Kosongkan bahan agar sesuai dengan gambar
      _showScrollDown = false;
    });
  }

  void _submitLanjutanDetail() {
    FocusScope.of(context).unfocus();
    final bahanBaru = _bahanC.text.trim();

    if (bahanBaru.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi bahan dulu')));
      return;
    }

    _bahanC.clear();
    setState(() {
      _bahanFinal = bahanBaru;
      _step = _AiStep.result;
      _showScrollDown = false;
    });
    _requestAI(bahanBaru, _alergiFinal);
  }

  // ================= FITUR OBROLAN BARU =================
  void _newChat() {
    FocusScope.of(context).unfocus();
    setState(() {
      _bahanC.clear();
      _bahanFinal = '';
      final savedAlergi = _alergiFinal.isNotEmpty
          ? _alergiFinal
          : (_alergiC.text.trim().isNotEmpty
              ? _alergiC.text.trim()
              : widget.child.alergi);
      _alergiFinal = savedAlergi;
      _alergiC.text = savedAlergi;
      
      _step = savedAlergi.isEmpty ? _AiStep.formEmpty : _AiStep.formFilled;
    });
  }

  // ================= PANEL GESER RIWAYAT OBROLAN =================
  void _showHistory() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 319,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat obrolan',
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textBlack,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, size: 24, color: textBlack),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        children: [
                          _buildHistoryGroup(
                            ctx,
                            'Sabtu, 12 Sep',
                            [
                              {'bahan': 'Ayam, wortel', 'menu': 'Nugget Ayam • Sosis Ayam'},
                              {'bahan': 'Telur', 'menu': 'Bubur Telur Sayur • Orak-Arik'},
                              {'bahan': 'Ubi, Pepaya, Pisang', 'menu': 'Puding Ubi • Bubur Pepaya • +1'},
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildHistoryGroup(
                            ctx,
                            'Jumat, 4 Sep',
                            [
                              {'bahan': 'Pisang', 'menu': 'Pancake Pisang Oat • +4'},
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildHistoryGroup(
                            ctx,
                            'Kamis, 27 Agu',
                            [
                              {'bahan': 'Bayam, Tahu', 'menu': 'Bola Tahu Ayam • Sup Bayam'},
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32, left: 28, right: 28),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _newChat();         
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5F5).withValues(alpha: 0.77),
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(86),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/ep--edit.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(textBlack, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 11),
                              Text(
                                'Obrolan baru',
                                style: google_fonts.GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim1, curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }

  Widget _buildHistoryGroup(
    BuildContext ctx,
    String date,
    List<Map<String, String>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: google_fonts.GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF797777),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(ctx);
              _openDetail(bahan: item['bahan']!);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Color(0xFFEAEAEA), thickness: 1),
                const SizedBox(height: 12),
                Text(
                  item['bahan']!,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textBlack,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item['menu']!,
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textBlack,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ================= SUBMIT =================
  void _submitFromEmpty() {
    FocusScope.of(context).unfocus(); 
    final alergi = _alergiC.text.trim();
    final bahan  = _bahanC.text.trim();

    if (bahan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi bahan di rumah dulu ya')));
      return;
    }

    setState(() {
      _alergiFinal = alergi;
      _bahanFinal = bahan;
      _step = _AiStep.result;
    });
    _bahanC.clear(); 
    _requestAI(bahan, alergi);
  }

  void _submitFromFilled() {
    FocusScope.of(context).unfocus();
    final bahan = _bahanC.text.trim();

    if (bahan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi bahan di rumah dulu ya')));
      return;
    }

    setState(() {
      _bahanFinal = bahan;
      _step = _AiStep.result;
    });
    _bahanC.clear(); 
    _requestAI(bahan, _alergiFinal);
  }

  void _submitLanjutan() {
    FocusScope.of(context).unfocus();
    final bahanBaru = _bahanC.text.trim();

    if (bahanBaru.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi bahan dulu')));
      return;
    }

    setState(() {
      _bahanFinal = bahanBaru; 
    });
    _bahanC.clear(); 
    _requestAI(bahanBaru, _alergiFinal);
  }

  Future<void> _requestAI(String bahan, String alergi) async {
    setState(() => _isLoadingAI = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _isLoadingAI = false);
  }

  void _ubahAlergi() {
    FocusScope.of(context).unfocus(); 
    setState(() {
      _alergiC.text = _alergiFinal;
      _step = _AiStep.formEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isDetail = _step == _AiStep.detail;
    final showResultBody = _step == _AiStep.result || isDetail;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), 
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            isDetail ? _buildDetailHeader(topPad) : _buildHeader(topPad),
            Expanded(
              child: Stack(
                children: [
                  // Konten Utama
                  SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 180), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        if (_step == _AiStep.formEmpty) _buildFormEmpty(),
                        if (_step == _AiStep.formFilled) _buildFormFilled(),
                        if (showResultBody) _buildResult(isDetail: isDetail),
                      ],
                    ),
                  ),

                  // Input Bar Melayang di Bawah
                  if (showResultBody)
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
                          ]
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDetail)
                              _inputField(
                                controller: _bahanC,
                                hint: 'Lanjutkan obrolan ini',
                                onSend: _submitLanjutanDetail,
                                autofocus: false,
                                pill: true,
                              )
                            else
                              _inputField(
                                controller: _bahanC,
                                hint: 'Punya bahan masakan apa di rumah?',
                                onSend: _submitFromFilled,
                                autofocus: false,
                                pill: true, 
                              ),
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

                  // Tombol panah bawah
                  if (showResultBody && _showScrollDown)
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

  // ================= HEADER (FORM & RESULT) =================
  Widget _buildHeader(double topPad) {
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
          Positioned(
            left: 28,
            bottom: 32,
            child: Text(
              'Tanya AI Resep',
              style: google_fonts.GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          
          Positioned(
            right: 60,
            bottom: 30,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showHistory,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SvgPicture.asset(
                        'assets/images/basil--history-solid.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _newChat,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SvgPicture.asset(
                        'assets/images/ep--edit.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: 32,
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

  // ================= HEADER: DETAIL PENCARIAN =================
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
              onTap: _closeDetail,
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
            right: 16,
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
                    onTap: _showHistory,
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
                    onTap: _newChat,
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

  // ================= STEP 1: FORM KOSONG =================
  Widget _buildFormEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildInfo(),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Alergi', style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text('(opsional)', style: google_fonts.GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: textGrey)),
            ],
          ),
          const SizedBox(height: 8),
          _inputField(
            controller: _alergiC,
            hint: 'Ketik alergi Si Kecil',
            autofocus: true,
          ),
          const SizedBox(height: 24),

          Text('Bahan di rumah', style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
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

  // ================= STEP 2: FORM TERISI =================
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
                      Text('Alergi', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textGrey)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _ubahAlergi,
                        behavior: HitTestBehavior.opaque,
                        child: Text('Ubah', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primaryRed)),
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
                      style: google_fonts.GoogleFonts.inter(fontSize: 12.6, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Bahan di rumah', style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _inputField(
            controller: _bahanC,
            hint: 'Punya bahan masakan apa di rumah?',
            onSend: _bahanC.text.isNotEmpty ? _submitFromFilled : null,
            autofocus: true,
          ),
        ],
      ),
    );
  }

  // ================= STEP 3: HASIL & DETAIL PENCARIAN =================
  Widget _buildResult({bool isDetail = false}) {
    final bahanUtama = _bahanFinal.isNotEmpty ? _bahanFinal.split(',').first.trim() : 'Bahan Utama';
    final formattedBahan = _formatBahan(_bahanFinal);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info (Anak & Alergi)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildChildInfo()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Alergi', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textGrey)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _ubahAlergi,
                        behavior: HitTestBehavior.opaque,
                        child: Text('Ubah', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primaryRed)),
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
                  Text(_bahanFinal, style: google_fonts.GoogleFonts.inter(fontSize: 12.9, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // AI Response Text
          if (_isLoadingAI) 
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(color: primaryRed),
                  const SizedBox(height: 12),
                  Text('AI sedang membuat resep...', style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textGrey)),
                ],
              ),
            )
          else if (isDetail)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textBlack, height: 16 / 13),
                    children: [
                      const TextSpan(text: 'Berikut resep MPASI dari '),
                      TextSpan(text: 'Ayam dan Wortel', style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: textBlack, height: 16 / 13)),
                      const TextSpan(text: ' yang disesuaikan dengan status gizi Alaia (Normal) dan alergi telur'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _sectionTitle('1. Nugget Ayam Homemade Tanpa Telur'),
                _paragraph('Resep ini menggunakan tepung maizena sebagai pengganti telur agar adonan tetap padat dan aman untuk bayi alergi telur.'),
                
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
                _sectionTitle('2. Sosis Ayam Homemade Tanpa Telur'),
                _paragraph('Menu ini menggunakan tepung pati garut sebagai pengikat alami yang aman untuk bayi.'),
                
                _sectionTitle('Bahan-bahan'),
                _bullet('Daging ayam: 400 gram (fillet)'),
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
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textBlack, height: 16 / 13),
                    children: [
                      const TextSpan(text: 'Berikut resep MPASI dari '),
                      TextSpan(text: formattedBahan, style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: textBlack, height: 16 / 13)),
                      TextSpan(text: ' yang disesuaikan dengan status gizi ${widget.child.nama} (Normal) dan alergi ${_alergiFinal.isNotEmpty ? _alergiFinal : "makanan"}.' ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _sectionTitle('1. Nugget $bahanUtama Homemade'),
                _paragraph('Resep ini menggunakan $bahanUtama sebagai bahan utama agar adonan tetap padat dan aman untuk bayi.'),
                
                _sectionTitle('Bahan-bahan'),
                _bullet('$bahanUtama: 120 gram (fillet)'),
                _bullet('Wortel: 10 gram (cincang halus)'),
                _bullet('Tepung maizena: 1 sdm'),
                _bullet('Kaldu bubuk MPASI: Secukupnya'),
                _bullet('Minyak kelapa: Secukupnya untuk menggoreng'),

                _sectionTitle('Cara Membuat'),
                _paragraph('1. Chopper $bahanUtama, wortel, dan tepung maizena hingga halus.'),
                _paragraph('2. Bentuk adonan menjadi adonan padat di wadah anti panas.'),
                _paragraph('3. Kukus selama matang, lalu potong kecil-kecil.'),

                const SizedBox(height: 16),
                _sectionTitle('2. Sosis $bahanUtama Homemade'),
                _paragraph('Menu ini menggunakan tepung pati garut sebagai pengikat alami yang aman untuk bayi.'),
                
                _sectionTitle('Bahan-bahan'),
                _bullet('$bahanUtama: 400 gram (fillet)'),
                _bullet('Wortel: 1 buah (ukuran sedang)'),
                _bullet('Bawang bombay: 1/2 buah'),
                _bullet('Tepung pati garut: 3 sdm'),

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
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _buildChildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Untuk si kecil', style: google_fonts.GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textGrey)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(widget.child.nama, style: google_fonts.GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textBlack)),
            const SizedBox(width: 8),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: textBlack, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(widget.child.umur, style: google_fonts.GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textBlack)),
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
    );
  }

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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    VoidCallback? onSend,
    bool autofocus = false, 
    bool pill = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: pill
          ? const EdgeInsets.fromLTRB(20, 3, 3, 3)
          : const EdgeInsets.fromLTRB(16, 8, 10, 8),
      decoration: BoxDecoration(
        color: pill ? Colors.white : bgInput, 
        borderRadius: BorderRadius.circular(pill ? 86 : 15),
        border: pill ? Border.all(color: const Color(0xFFE0E0E0), width: 1) : null,
        boxShadow: pill
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : (_step == _AiStep.result ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ] : []),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus, 
              style: google_fonts.GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textBlack),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: google_fonts.GoogleFonts.inter(fontSize: pill ? 12 : 12.9, fontWeight: FontWeight.w400, color: textGrey),
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
                width: pill ? 38 : 32,
                height: pill ? 38 : 32,
                decoration: const BoxDecoration(color: textMuted, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(Icons.arrow_upward_rounded, size: pill ? 22 : 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}