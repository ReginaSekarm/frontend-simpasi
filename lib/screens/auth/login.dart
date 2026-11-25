// lib/screens/auth/login.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

import '../../services/auth_service.dart';
import 'package:simpasi/main.dart' show markLoginSuccess;
import 'forgot_pass_screen.dart';
import 'register.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool showDeletedSuccess;

  const LoginScreen({
    super.key,
    this.showDeletedSuccess = false,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Color primary = Color(0xFFD45060);
  static const Color accent = Color(0xFFF1A038);
  static const Color grey = Color(0xFF8F8F8F);

  final _emailC = TextEditingController();
  final _passC = TextEditingController();

  bool _hidePass = true;
  bool _remember = true;
  bool _isLoading = false;

  // STATE UNTUK ERROR EMAIL (CAUTION)
  String? _emailError;

  @override
  void initState() {
    super.initState();
    if (widget.showDeletedSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showSuccessPopup();
      });
    }
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  // ================= POPUP SUKSES HAPUS AKUN =================
  void _showSuccessPopup() {
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
              width: 290,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF77B255),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 21.05),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 26.31,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Akun berhasil dihapus',
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 17.5395,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 21 / 17.5395,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  // ================= POPUP KUSTOM LOGIN GAGAL (Figma) =================
  void _showLoginErrorDialog({required String title, required String message}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return _AutoDismissLoginErrorDialog(
          title: title,
          message: message,
        );
      },
    );
  }

  TextStyle _label() => gfonts.GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 17 / 14,
        color: Colors.black,
      );

  // DECORATION DIPERBARUI UNTUK MENERIMA ERROR TEXT
  InputDecoration _decoration(String hint, {Widget? suffix, String? errorText}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: grey, width: 1),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: gfonts.GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 17 / 14,
        color: grey,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: primary, width: 1.2),
      ),
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      suffixIcon: suffix,
      errorText: errorText,
      errorStyle: gfonts.GoogleFonts.inter(fontSize: 10, color: Colors.red),
    );
  }

  Future<void> _onLogin() async {
    if (_isLoading) return;

    final email = _emailC.text.trim();
    final password = _passC.text;

    setState(() {
      _emailError = null;
    });

    // 1. Cek jika kolom kosong
    if (email.isEmpty || password.isEmpty) {
      _showLoginErrorDialog(
        title: 'Email dan Kata Sandi Kosong',
        message:
            'Silakan isi alamat email dan kata sandi Anda terlebih dahulu sebelum masuk.',
      );
      return;
    }

    // 2. Cek Format Email (Munculkan Caution Merah)
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        _emailError = 'Format email tidak valid';
      });
      return;
    }

    // Tutup fokus input sebelum navigasi
    FocusManager.instance.primaryFocus?.unfocus();

    // 3. Panggil API login lalu arahkan ke Home
    setState(() => _isLoading = true);
    try {
      // AuthService.login: null = sukses (token sudah disimpan), selain itu pesan error
      final error = await AuthService.login(
        email,
        password,
        remember: _remember,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (error != null) {
        _showLoginErrorDialog(title: 'Gagal Masuk', message: error);
        return;
      }

      // Tandai login sukses (mengaktifkan penjaga session & menyiapkan notifikasi), lalu ke Home
      markLoginSuccess();
      context.go('/home');
    } on TimeoutException {
      if (!mounted) return;
      _showLoginErrorDialog(
        title: 'Gagal Masuk',
        message: 'Koneksi ke server terlalu lama. Silakan coba lagi.',
      );
    } catch (e, st) {
      debugPrint('LOGIN ERROR: $e\n$st');
      if (!mounted) return;
      _showLoginErrorDialog(
        title: 'Gagal Masuk',
        message: 'Terjadi kesalahan saat masuk. Silakan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _onGoToRegister() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 322,
              decoration: const BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/images/start-melet-buka.png',
                    height: 76,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.child_care,
                      size: 76,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Masuk ke Akun',
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 32 / 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Login untuk masuk kembali ke akun Anda',
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 17 / 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.fromLTRB(22, 28, 19, 27),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: grey, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 9),
                          child: Text('Alamat Email', style: _label()),
                        ),
                        const SizedBox(height: 12),

                        // KOLOM EMAIL DENGAN VALIDASI CAUTION MERAH
                        TextField(
                          controller: _emailC,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: gfonts.GoogleFonts.inter(fontSize: 14),
                          onChanged: (val) {
                            if (_emailError != null &&
                                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(val.trim())) {
                              setState(() => _emailError = null);
                            }
                          },
                          decoration: _decoration(
                            'nama@gmail.com',
                            errorText: _emailError,
                          ),
                        ),

                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.only(left: 9),
                          child: Text('Kata Sandi', style: _label()),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _passC,
                            obscureText: _hidePass,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onLogin(),
                            style: gfonts.GoogleFonts.inter(fontSize: 14),
                            decoration: _decoration(
                              '••••••••',
                              suffix: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    setState(() => _hidePass = !_hidePass),
                                icon: Icon(
                                  _hidePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: Checkbox(
                                    value: _remember,
                                    onChanged: (v) =>
                                        setState(() => _remember = v ?? true),
                                    activeColor: primary,
                                    checkColor: Colors.white,
                                    fillColor: WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                              ? primary
                                              : const Color(0xFFF7F8F0),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFF797777),
                                      width: 1.7,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ingat Saya',
                                  style: gfonts.GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    height: 12 / 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _onForgotPassword,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  'Lupa kata sandi?',
                                  style: gfonts.GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    height: 12 / 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: SizedBox(
                            width: 186,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',
                                      style: gfonts.GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        height: 24 / 20,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 140),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: gfonts.GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 17 / 14,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: _onGoToRegister,
                        child: Text(
                          'Daftar di sini',
                          style: gfonts.GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 17 / 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= WIDGET POPUP LOGIN GAGAL AUTO-DISMISS =================
class _AutoDismissLoginErrorDialog extends StatefulWidget {
  final String title;
  final String message;

  const _AutoDismissLoginErrorDialog({
    required this.title,
    required this.message,
  });

  @override
  State<_AutoDismissLoginErrorDialog> createState() =>
      _AutoDismissLoginErrorDialogState();
}

class _AutoDismissLoginErrorDialogState
    extends State<_AutoDismissLoginErrorDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: 335,
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF0000),
              size: 60,
            ),
            const SizedBox(height: 17),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: gfonts.GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 24 / 20,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: gfonts.GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8F8F8F),
                height: 17 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}