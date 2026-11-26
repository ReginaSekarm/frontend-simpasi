import 'package:flutter/material.dart';

import '../../services/user_service.dart';
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
  static const Color errorRed      = Color(0xFFFF0000);
  static const Color inputBg       = Color(0x99FFFFFF);
  static const Color disabledBtn   = Color(0xFFD9D9D9);

  late TextEditingController _namaC;
  late TextEditingController _emailC;
  late TextEditingController _hpC;

  bool _hasChanges = false;
  bool _saving = false;

  String? _namaError;
  String? _emailError;
  String? _hpError;

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

  String get _inisial {
    final n = _namaC.text.trim().isEmpty ? widget.namaLengkap.trim() : _namaC.text.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  // FUNGSI CEK PERUBAHAN (juga memperbarui nama di samping avatar secara langsung)
  void _checkChanges() {
    final hasChanged =
        _namaC.text.trim() != widget.namaLengkap.trim() ||
        _emailC.text.trim() != (widget.email ?? '').trim() ||
        _hpC.text.trim() != (widget.noHp ?? '').trim();

    setState(() {
      _hasChanges = hasChanged;
    });
  }

  // ================= SIMPAN KE BACKEND =================
  Future<void> _simpan() async {
    if (_saving) return;

    final nama = _namaC.text.trim();
    final email = _emailC.text.trim();
    
    // Bersihkan HP dari spasi dan strip
    final hp = _hpC.text.replaceAll(RegExp(r'[\s-]'), '');
    final digitHp = hp.replaceAll('+', '');

    String? namaErr;
    String? emailErr;
    String? hpErr;

    // Validasi (aturan sama dengan backend)
    if (nama.isEmpty) {
      namaErr = 'Nama lengkap wajib diisi.';
    } else if (nama.length > 100) {
      namaErr = 'Nama lengkap maksimal 100 karakter.';
    }

    if (email.isEmpty) {
      emailErr = 'Alamat email wajib diisi.';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailErr = 'Format email tidak valid. Periksa lagi lalu masukkan ulang.';
    }

    // VALIDASI NO HP (MINIMAL 10 DIGIT)
    if (hp.isEmpty) {
      hpErr = 'Nomor HP wajib diisi.';
    } else if (!RegExp(r'^\+?\d+$').hasMatch(hp)) {
      hpErr = 'Nomor HP hanya boleh berisi angka.';
    } else if (digitHp.length < 10 || digitHp.length > 15) {
      hpErr = 'Nomor HP harus terdiri dari 10 hingga 15 digit.';
    }

    if (namaErr != null || emailErr != null || hpErr != null) {
      setState(() {
        _namaError = namaErr;
        _emailError = emailErr;
        _hpError = hpErr;
      });
      return;
    }

    setState(() {
      _saving = true;
      _namaError = null;
      _emailError = null;
      _hpError = null;
    });

    final error = await UserService.updateProfile(
      fullName: nama,
      email: email,
      phone: hp,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      setState(() {
        final lower = error.toLowerCase();
        if (lower.contains('email')) {
          _emailError = error;
        } else if (lower.contains('hp') || lower.contains('phone') || lower.contains('nomor')) {
          _hpError = error;
        } else {
          _namaError = error;
        }
      });
      return;
    }

    // Berhasil -> kembali ke Profil (Profil memuat ulang datanya)
    Navigator.of(context).pop(true);
  }

  // ================= FUNGSI POPUP KONFIRMASI (SESUAI FIGMA 100%) =================
  Future<void> _onBackPressed() async {
    if (_saving) return;

    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: context.w(350),
          padding: EdgeInsets.symmetric(
            horizontal: context.w(31.5),
            vertical: context.w(30.24),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.w(7.62)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              SizedBox(height: context.w(11)),
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
              SizedBox(height: context.w(11)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
    
    // LOGIKA TOMBOL SIMPAN 
    // Tombol hanya bisa ditekan jika ada perubahan, tidak sedang loading, dan TIDAK ADA error pada form
    final bool isFormValid = _emailError == null && _hpError == null;
    final bool canSave = _hasChanges && !_saving && isFormValid;

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
                          _inisial,
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
                          _namaC.text.trim().isEmpty
                              ? widget.namaLengkap
                              : _namaC.text.trim(),
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
                    errorText: _namaError,
                    onChanged: (_) {
                      if (_namaError != null) setState(() => _namaError = null);
                      _checkChanges();
                    },
                  ),

                  SizedBox(height: context.w(26)),

                  // ---- Field: Alamat Email ----
                  _buildLabel('Alamat Email'),
                  SizedBox(height: context.w(6)),
                  _buildTextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (val) {
                      setState(() {
                        if (val.trim().isEmpty) {
                          _emailError = null;
                        } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val)) {
                          _emailError = 'Format email tidak valid. Periksa lagi lalu masukkan ulang.';
                        } else {
                          _emailError = null;
                        }
                      });
                      _checkChanges();
                    },
                  ),

                  SizedBox(height: context.w(26)),

                  // ---- Field: No. HP ----
                  _buildLabel('No. HP'),
                  SizedBox(height: context.w(6)),
                  _buildTextField(
                    controller: _hpC,
                    keyboardType: TextInputType.phone,
                    errorText: _hpError,
                    onChanged: (val) {
                      setState(() {
                        // Bersihkan spasi dan strip (jika user ngetik 0812-345)
                        final cleaned = val.replaceAll(RegExp(r'[\s-]'), '');
                        final digitOnly = cleaned.replaceAll('+', '');
                        
                        if (cleaned.isEmpty) {
                          _hpError = null;
                        } else if (!RegExp(r'^\+?\d+$').hasMatch(cleaned)) {
                          _hpError = 'Nomor HP hanya boleh berisi angka.';
                        } else if (digitOnly.length < 10) {
                          _hpError = 'Nomor HP minimal 10 digit.';
                        } else {
                          _hpError = null;
                        }
                      });
                      _checkChanges();
                    },
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
              // Hanya bisa ditekan jika 'canSave' bernilai true
              onTap: canSave ? _simpan : null,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: context.w(60),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // Warna berubah jadi abu-abu jika tidak valid
                  color: canSave ? primaryOrange : disabledBtn,
                  borderRadius: BorderRadius.circular(context.w(15)),
                ),
                child: _saving
                    ? SizedBox(
                        width: context.w(26),
                        height: context.w(26),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
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
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: context.w(50),
          padding: EdgeInsets.symmetric(horizontal: context.w(14)),
          decoration: BoxDecoration(
            color: inputBg,
            border: Border.all(
              color: hasError ? errorRed : textBlack, // Border merah jika error
              width: context.w(1),
            ),
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
        ),
        if (hasError) ...[
          SizedBox(height: context.w(7)),
          Text(
            errorText,
            style: GoogleFonts.inter(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w400,
              color: errorRed,
              height: 12 / 10,
            ),
          ),
        ],
      ],
    );
  }
}