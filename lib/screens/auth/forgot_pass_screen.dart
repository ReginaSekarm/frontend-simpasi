// lib/screens/auth/forgot_password.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart'; // sesuaikan nama file kalau berbeda
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Warna dari Figma
  static const Color primary = Color(0xFFD45060);
  static const Color accent = Color(0xFFF1A038);
  static const Color accentDisabled = Color(0x99F1A038);
  static const Color grey = Color(0xFF8F8F8F);
  static const Color errorRed = Color(0xFFFF0000);

  final _emailC = TextEditingController();

  // Pesan error di bawah kolom email (null = tidak ada error)
  String? _emailError;

  // true selama menunggu balasan backend
  bool _isLoading = false;

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  // ---------- Helper style ----------
  TextStyle _label() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      );

  InputDecoration _decoration(String hint, {bool isError = false}) {
    final borderColor = isError ? errorRed : grey;
    final focusedColor = isError ? errorRed : primary;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor, width: 1),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: grey),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: focusedColor, width: 1.2),
      ),
    );
  }

  // ---------- Validasi ----------
  // Format email: nama@domain.com (dicek tanpa regex)
  bool _isValidEmail(String email) {
    if (email.contains(' ')) return false;

    final parts = email.split('@');
    if (parts.length != 2) return false; // harus ada tepat satu tanda @

    final name = parts[0];
    final domain = parts[1];

    if (name.isEmpty) return false;
    if (!domain.contains('.')) return false;
    if (domain.startsWith('.') || domain.endsWith('.')) return false;

    return true;
  }

  // ---------- Aksi ----------
  Future<void> _onSendCode() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final email = _emailC.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Silakan isi alamat email Anda');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Format email tidak valid');
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    // Minta backend mengirim kode OTP ke email (null = sukses, selain itu pesan error)
    final error = await AuthService.forgotPassword(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      // email tidak terdaftar, terlalu sering minta kode, atau gagal terhubung ke server
      setState(() => _emailError = error);
      return;
    }

    // Pindah ke verifikasi OTP (alur Lupa Kata Sandi)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: email,
          isFromForgotPassword: true,
        ),
      ),
    );
  }

  void _onBackToLogin() {
    Navigator.of(context).pop();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background merah melengkung (Rectangle 2 Figma: height 322)
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

          // Konten
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Maskot
                  Image.asset(
                    'assets/images/start-melet-buka.png',
                    height: 76,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.child_care,
                      size: 76,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Heading: Lupa Kata Sandi?
                  Text(
                    'Lupa Kata Sandi?',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Subheading
                  SizedBox(
                    width: 250,
                    child: Text(
                      'Silakan isi alamat email Anda\nkami akan mengirimkan kode verifikasi.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Card form
                  Container(
                    width: 330,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.fromLTRB(21, 24, 21, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: grey, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Alamat Email Label
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Alamat Email', style: _label()),
                        ),
                        const SizedBox(height: 10),

                        // Input Email
                        SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _emailC,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onSendCode(),
                            style: GoogleFonts.inter(fontSize: 14),
                            // Sembunyikan error saat user mulai mengetik
                            onChanged: (value) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                            decoration: _decoration(
                              'nama@gmail.com',
                              isError: _emailError != null,
                            ),
                          ),
                        ),

                        // Teks peringatan merah (muncul jika error)
                        if (_emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: Text(
                              _emailError!,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: errorRed,
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Tombol Kirim Kode Verifikasi
                        Center(
                          child: SizedBox(
                            width: 245,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onSendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                disabledBackgroundColor: accentDisabled,
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
                                      'Kirim Kode Verifikasi',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
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
                  const SizedBox(height: 290),

                  // Footer: Sudah ingat password? Masuk di sini
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah ingat password? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: _onBackToLogin,
                        child: Text(
                          'Masuk di sini',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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