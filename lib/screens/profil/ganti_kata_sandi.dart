import 'package:flutter/material.dart';

import '../../services/user_service.dart';

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

class GantiKataSandiScreen extends StatefulWidget {
  const GantiKataSandiScreen({super.key});

  @override
  State<GantiKataSandiScreen> createState() => _GantiKataSandiScreenState();
}

class _GantiKataSandiScreenState extends State<GantiKataSandiScreen> {
  // Warna dari Figma
  static const Color primaryOrange = Color(0xFFF1A038);
  static const Color textBlack     = Color(0xFF000000);
  static const Color textGrey      = Color(0xFF8F8F8F);
  static const Color errorRed      = Color(0xFFFF0000);
  static const Color inputBg       = Color(0x99FFFFFF); // white 60%

  final _oldPassC = TextEditingController();
  final _newPassC = TextEditingController();
  final _confirmPassC = TextEditingController();

  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _saving = false;

  String? _oldError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _oldPassC.dispose();
    _newPassC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

  // FUNGSI SNACKBAR KUSTOM
  void _snack(String msg) {
    if (!mounted) return;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottomInset),
          content: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF77B255),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 17 / 14,
                ),
              ),
            ),
          ),
        ),
      );
  }

  // ================= SIMPAN KE BACKEND =================
  Future<void> _simpan() async {
    if (_saving) return;

    // Kata sandi tidak di-trim: harus persis sama dengan yang diketik saat login
    final oldP = _oldPassC.text;
    final newP = _newPassC.text;
    final conf = _confirmPassC.text;

    String? oldErr;
    String? newErr;
    String? confErr;

    if (oldP.isEmpty) {
      oldErr = 'Kata sandi lama wajib diisi.';
    }

    // Validasi syarat kata sandi baru (min 8 karakter, 1 huruf besar, 1 angka, tidak sama dengan sandi lama)
    if (newP.isEmpty) {
      newErr = 'Kata sandi baru wajib diisi.';
    } else if (newP.length < 8) {
      newErr = 'Kata sandi baru minimal 8 karakter.';
    } else if (!RegExp(r'[A-Z]').hasMatch(newP)) {
      newErr = 'Kata sandi baru harus mengandung huruf besar.';
    } else if (!RegExp(r'\d').hasMatch(newP)) {
      newErr = 'Kata sandi baru harus mengandung angka.';
    } else if (newP == oldP) {
      newErr = 'Kata sandi baru tidak boleh sama dengan kata sandi lama.';
    }

    if (conf.isEmpty) {
      confErr = 'Konfirmasi kata sandi wajib diisi.';
    } else if (newP != conf) {
      confErr = 'Konfirmasi kata sandi tidak cocok. Periksa lagi lalu masukkan ulang.';
    }

    if (oldErr != null || newErr != null || confErr != null) {
      setState(() {
        _oldError = oldErr;
        _newError = newErr;
        _confirmError = confErr;
      });
      return;
    }

    setState(() {
      _saving = true;
      _oldError = null;
      _newError = null;
      _confirmError = null;
    });

    final error = await UserService.changePassword(
      oldPassword: oldP,
      newPassword: newP,
      confirmPassword: conf,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      setState(() {
        final lower = error.toLowerCase();
        if (lower.contains('lama') || lower.contains('salah') || lower.contains('old')) {
          _oldError = error;
        } else {
          _newError = error;
        }
      });
      return;
    }

    _snack('Kata sandi berhasil diubah');
    
    // Kembali ke halaman Pengaturan setelah snackbar muncul
    if (mounted) {
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
                      'Ganti Kata Sandi',
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

          // ================= CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 46),

                  // ---- Field: Kata Sandi Lama ----
                  _buildLabel('Kata Sandi Lama'),
                  const SizedBox(height: 4),
                  _buildPasswordField(
                    controller: _oldPassC,
                    hide: _hideOld,
                    errorText: _oldError,
                    onToggle: () => setState(() => _hideOld = !_hideOld),
                    onChanged: () {
                      if (_oldError != null) {
                        setState(() => _oldError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 36),

                  // ---- Field: Kata Sandi Baru ----
                  _buildLabel('Kata Sandi Baru'),
                  const SizedBox(height: 5),
                  _buildPasswordField(
                    controller: _newPassC,
                    hide: _hideNew,
                    errorText: _newError,
                    onToggle: () => setState(() => _hideNew = !_hideNew),
                    onChanged: () {
                      if (_newError != null) {
                        setState(() => _newError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 36),

                  // ---- Field: Konfirmasi Kata Sandi Baru ----
                  _buildLabel('Konfirmasi Kata Sandi Baru'),
                  const SizedBox(height: 6),
                  _buildPasswordField(
                    controller: _confirmPassC,
                    hide: _hideConfirm,
                    errorText: _confirmError,
                    onToggle: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                    onChanged: () {
                      if (_confirmError != null) {
                        setState(() => _confirmError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 46),

                  // ---- Tombol Simpan ----
                  GestureDetector(
                    onTap: _saving ? null : _simpan,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _saving
                            ? primaryOrange.withValues(alpha: 0.6)
                            : primaryOrange,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Simpan Kata Sandi',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 24 / 20,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
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
      padding: const EdgeInsets.only(left: 14),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textBlack,
          height: 19 / 16,
        ),
      ),
    );
  }

  // ================= PASSWORD FIELD =================
  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool hide,
    required VoidCallback onToggle,
    required VoidCallback onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            color: inputBg,
            border: Border.all(
              color: hasError ? errorRed : textBlack,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: hide,
                  onChanged: (_) => onChanged(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
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
              GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: textGrey,
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 7),
          Text(
            errorText,
            style: GoogleFonts.inter(
              fontSize: 10,
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