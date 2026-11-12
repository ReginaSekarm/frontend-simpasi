// lib/screens/auth/forgot_password.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color grey = Color(0xFF8F8F8F);
  static const Color errorRed = Color(0xFFFF0000); // Tambahan warna merah

  final _emailC = TextEditingController();

  // State untuk menandakan apakah error harus ditampilkan
  bool _showEmailError = false; 

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

  // Diubah agar bisa menerima status error (border merah)
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

  // ---------- Aksi ----------
  void _onSendCode() {
    // Jika kosong, tampilkan error merah dan hentikan proses
    if (_emailC.text.trim().isEmpty) {
      setState(() {
        _showEmailError = true;
      });
      return;
    }

    // Sembunyikan error jika sudah diisi
    setState(() {
      _showEmailError = false;
    });

    // Pindah ke verifikasi OTP (alur Lupa Kata Sandi)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: _emailC.text.trim(),
          isFromForgotPassword: true, // 👈 INI YANG DITAMBAH
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
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(fontSize: 14),
                            // Sembunyikan error saat user mulai mengetik
                            onChanged: (value) {
                              if (_showEmailError && value.trim().isNotEmpty) {
                                setState(() {
                                  _showEmailError = false;
                                });
                              }
                            },
                            decoration: _decoration(
                              'nama@gmail.com',
                              isError: _showEmailError,
                            ),
                          ),
                        ),

                        // Teks Peringatan Merah (Muncul jika error)
                        if (_showEmailError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: Text(
                              'Silakan isi alamat email Anda',
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
                              onPressed: _onSendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
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