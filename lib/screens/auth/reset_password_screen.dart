// lib/screens/auth/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/popup_status.dart';
import 'login.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color primary = Color(0xFFD45060);
  static const Color accent  = Color(0xFFF1A038);
  static const Color grey    = Color(0xFF8F8F8F);
  static const Color errorRed = Color(0xFFFF0000);
  static const Color successGreen = Color(0xFF2E7D32);

  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Realtime validation flags
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigit = false;

  // Error flags (muncul saat tap Simpan)
  bool _showPassError = false;
  bool _showConfirmError = false;

  @override
  void initState() {
    super.initState();
    _passC.addListener(_validateRealtime);
    _confirmC.addListener(_validateRealtime);
  }

  void _validateRealtime() {
    final text = _passC.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
      _hasDigit = RegExp(r'\d').hasMatch(text);

      // Auto-hide error ketika user mulai valid
      if (_showPassError && _isPasswordValid) {
        _showPassError = false;
      }
      if (_showConfirmError &&
          _confirmC.text == _passC.text &&
          _confirmC.text.isNotEmpty) {
        _showConfirmError = false;
      }
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasDigit;
  bool get _isConfirmValid =>
      _confirmC.text.isNotEmpty && _confirmC.text == _passC.text;

  @override
  void dispose() {
    _passC.removeListener(_validateRealtime);
    _confirmC.removeListener(_validateRealtime);
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  // ================= SIMPAN =================
  void _onSimpan() {
    // Set flag error untuk trigger tampilan merah
    setState(() {
      _showPassError = !_isPasswordValid;
      _showConfirmError = !_isConfirmValid;
    });

    // Kalau ada error → stop, jangan lanjut
    if (_showPassError || _showConfirmError) return;

    // TODO: panggil API update password
    // Kalau API sukses → popup SUCCESS → balik ke Login
    // Kalau API gagal → popup FAILED
    //
    // Contoh:
    // try {
    //   await api.updatePassword(_passC.text);
    //   _showSuccessPopup();
    // } catch (e) {
    //   showStatusPopup(context, type: PopupType.resetPasswordFailed);
    // }

    // Untuk demo (API belum siap) → langsung tampilkan SUCCESS popup:
    showStatusPopup(
      context,
      type: PopupType.resetPasswordSuccess,
      onClose: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ================= BACKGROUND MERAH =================
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
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // ================= MASKOT =================
                  Image.asset(
                    'assets/images/start-face-forkspoon.png',
                    height: 76,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.child_care,
                      size: 76,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= JUDUL =================
                  Text(
                    'Lupa Kata Sandi?',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // ================= SUBTITLE =================
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 328),
                    child: Text(
                      'Kode terverifikasi.\nBuat password baru untuk akun Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ================= CARD FORM =================
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.fromLTRB(21, 32, 21, 52),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: grey, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ============ KATA SANDI BARU ============
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'Kata Sandi Baru',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passC,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: _border(_showPassError ? errorRed : grey),
                            enabledBorder:
                                _border(_showPassError ? errorRed : grey),
                            focusedBorder:
                                _border(_showPassError ? errorRed : primary),
                            hintText: '..........',
                            hintStyle: const TextStyle(color: grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: grey,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // INFO / ERROR TEXT
                        if (_showPassError)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Kata sandi belum memenuhi ketentuan',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: errorRed,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '*Kata sandi min 8 karakter, 1 huruf besar dan 1 angka',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: _isPasswordValid ? successGreen : grey,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // ============ KONFIRMASI ============
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'Konfirmasi Kata Sandi Baru',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmC,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border:
                                _border(_showConfirmError ? errorRed : grey),
                            enabledBorder:
                                _border(_showConfirmError ? errorRed : grey),
                            focusedBorder: _border(
                                _showConfirmError ? errorRed : primary),
                            hintText: '..........',
                            hintStyle: const TextStyle(color: grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: grey,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),

                        if (_showConfirmError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: Text(
                              'Konfirmasi Kata Sandi Tidak Cocok',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: errorRed,
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),

                        // ============ TOMBOL SIMPAN ============
                        Center(
                          child: SizedBox(
                            width: 245,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _onSimpan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Simpan',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }

  // Helper border
  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1.2),
      );
}