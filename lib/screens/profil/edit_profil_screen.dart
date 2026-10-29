import 'package:flutter/material.dart';

import '../../utils/responsive.dart';

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

class EditProfilScreen extends StatefulWidget {
  final String namaLengkap;
  final String? email;
  final String? noHp;

  const EditProfilScreen({
    super.key,
    required this.namaLengkap,
    this.email,
    this.noHp,
  });

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  // Warna dari Figma
  static const Color primaryOrange = Color(0xFFF1A038);
  static const Color bgCream       = Color(0xFFFCEBD5);
  static const Color textBlack     = Color(0xFF000000);
  static const Color textBrown     = Color(0xFF9E5665);
  static const Color inputBg       = Color(0x99FFFFFF);
  static const Color disabledBtn   = Color(0xFFD9D9D9);

  late TextEditingController _namaC;
  late TextEditingController _emailC;
  late TextEditingController _hpC;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.namaLengkap);
    _emailC = TextEditingController(text: widget.email ?? '');
    _hpC = TextEditingController(text: widget.noHp ?? '');
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _hpC.dispose();
    super.dispose();
  }

  // FUNGSI CEK PERUBAHAN
  void _checkChanges() {
    final hasChanged = 
        _namaC.text != widget.namaLengkap ||
        _emailC.text != (widget.email ?? '') ||
        _hpC.text != (widget.noHp ?? '');

    if (hasChanged != _hasChanges) {
      setState(() {
        _hasChanges = hasChanged;
      });
    }
  }

  void _simpan() {
    final nama = _namaC.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap wajib diisi')),
      );
      return;
    }
    Navigator.of(context).pop(nama);
  }

  // ================= FUNGSI POPUP KONFIRMASI (SESUAI FIGMA 100%) =================
  Future<void> _onBackPressed() async {
    // Jika tidak ada perubahan, langsung kembali
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    // Jika ada perubahan, munculkan popup custom sesuai Figma
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero, 
        child: Container(
          width: context.w(350), // Lebar luar sesuai Figma
          padding: EdgeInsets.symmetric(
            horizontal: context.w(31.5), // (350 - 287) / 2 = 31.5
            vertical: context.w(30.24), // (190.42 - 129.95) / 2 = 30.235
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.w(7.62)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Judul
              Text(
                'Batalkan Perubahan?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.sp(19.95),
                  fontWeight: FontWeight.w600,
                  color: textBlack,
                  height: 24 / 19.95,
                ),
              ),
              SizedBox(height: context.w(11)), // Gap sesuai Figma
              
              // Deskripsi
              Text(
                'Perubahan yang belum disimpan akan hilang.\nYakin ingin membatalkan?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.sp(13.3),
                  fontWeight: FontWeight.w400,
                  color: textBlack,
                  height: 16 / 13.3,
                ),
              ),
              SizedBox(height: context.w(11)), // Gap sesuai Figma
              
              // Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Tetap di sini
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      width: context.w(129),
                      height: context.w(35.98),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(context.w(8.31)),
                      ),
                      child: Text(
                        'Tetap di sini',
                        style: GoogleFonts.inter(
                          fontSize: context.sp(14.96),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF797777).withValues(alpha: 0.8),
                          height: 18 / 14.96,
                        ),
                      ),
                    ),
                  ),
                  
                  // Tombol Ya, Batalkan
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, true),
                    child: Container(
                      width: context.w(129),
                      height: context.w(35.98),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0020),
                        borderRadius: BorderRadius.circular(context.w(8.31)),
                      ),
                      child: Text(
                        'Ya, Batalkan',
                        style: GoogleFonts.inter(
                          fontSize: context.sp(14.96),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 18 / 14.96,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER =================
          Padding(
            padding: EdgeInsets.only(
              top: topPad + context.w(16),
              left: context.w(15),
              right: context.w(15),
            ),
            child: SizedBox(
              height: context.w(40),
              child: Stack(
                children: [
                  // Back arrow
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _onBackPressed,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: context.w(40),
                        child: Icon(
                          Icons.chevron_left,
                          size: context.w(32),
                          color: textBlack,
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Center(
                    child: Text(
                      'Edit Profil',
                      style: GoogleFonts.inter(
                        fontSize: context.sp(24),
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

          // ================= CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.w(30)),

                  // ---- Avatar + Nama (Row) ----
                  Row(
                    children: [
                      Container(
                        width: context.w(102),
                        height: context.w(102),
                        decoration: const BoxDecoration(
                          color: bgCream,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'A',
                          style: GoogleFonts.inter(
                            fontSize: context.sp(49),
                            fontWeight: FontWeight.w700,
                            color: textBrown,
                            height: 59 / 49,
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(25)),
                      Expanded(
                        child: Text(
                          _namaC.text.isEmpty ? 'Aisyah' : _namaC.text,
                          style: GoogleFonts.inter(
                            fontSize: context.sp(24),
                            fontWeight: FontWeight.w700,
                            color: textBlack,
                            height: 29 / 24,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.w(62)),

                  // ---- Field: Nama Lengkap ----
                  _buildLabel('Nama Lengkap'),
                  SizedBox(height: context.w(6)),
                  _buildTextField(
                    controller: _namaC,
                    onChanged: (_) => _checkChanges(),
                  ),

                  SizedBox(height: context.w(26)),

                  // ---- Field: Alamat Email ----
                  _buildLabel('Alamat Email'),
                  SizedBox(height: context.w(6)),
                  _buildTextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _checkChanges(),
                  ),

                  SizedBox(height: context.w(26)),

                  // ---- Field: No. HP ----
                  _buildLabel('No. HP'),
                  SizedBox(height: context.w(6)),
                  _buildTextField(
                    controller: _hpC,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _checkChanges(),
                  ),

                  SizedBox(height: context.w(40)),
                ],
              ),
            ),
          ),

          // ================= TOMBOL SIMPAN =================
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(20),
              0,
              context.w(20),
              MediaQuery.of(context).padding.bottom + context.w(24),
            ),
            child: GestureDetector(
              onTap: _hasChanges ? _simpan : null,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: context.w(60),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _hasChanges ? primaryOrange : disabledBtn,
                  borderRadius: BorderRadius.circular(context.w(15)),
                ),
                child: Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.inter(
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 24 / 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= LABEL =================
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: context.w(14)),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: context.sp(16),
          fontWeight: FontWeight.w500,
          color: textBlack,
          height: 19 / 16,
        ),
      ),
    );
  }

  // ================= TEXTFIELD =================
  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: context.w(50),
      padding: EdgeInsets.symmetric(horizontal: context.w(14)),
      decoration: BoxDecoration(
        color: inputBg,
        border: Border.all(color: textBlack, width: context.w(1)),
        borderRadius: BorderRadius.circular(context.w(10)),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: context.sp(16),
            fontWeight: FontWeight.w500,
            color: textBlack,
            height: 19 / 16,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}