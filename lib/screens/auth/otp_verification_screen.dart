// lib/screens/auth/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

import '../../widgets/popup_status.dart';
import '../home/home_ibu_screen.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isFromForgotPassword;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isFromForgotPassword = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // Warna dari Figma
  static const Color primary = Color(0xFFD45060);
  static const Color accent = Color(0xFFF1A038);
  static const Color grey = Color(0xFF8F8F8F);
  static const Color subGrey = Color(0xFF797777);

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes.$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ================= VERIFIKASI =================
  void _onVerify() {
    final code = _otpControllers.map((c) => c.text).join();

    // Validasi: harus 4 digit
    if (code.length < 4) {
      showStatusPopup(context, type: PopupType.sendFailed);
      return;
    }

    if (widget.isFromForgotPassword) {
      // Alur Lupa Password → Reset Password
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        ),
      );
    } else {
      // Alur Registrasi → popup sukses → Home
      showStatusPopup(
        context,
        type: PopupType.emailVerifySuccess,
        onClose: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeIbuScreen()),
            (r) => false,
          );
        },
      );
    }
  }

  // ================= KIRIM ULANG KODE =================
  void _resendCode() {
    if (_secondsRemaining == 0) {
      _startTimer();
      showStatusPopup(context, type: PopupType.otpResendSuccess);
    }
  }

  // ================= OTP BOX =================
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 58,
      height: 48,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: google_fonts.GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
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
                    widget.isFromForgotPassword
                        ? 'Verifikasi Kode'
                        : 'Verifikasi Email',
                    style: google_fonts.GoogleFonts.inter(
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
                      'Masukkan kode verifikasi yang kami kirimkan ke email Anda',
                      textAlign: TextAlign.center,
                      style: google_fonts.GoogleFonts.inter(
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'Kode OTP',
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'Masukkan 4 kode OTP yang dikirim ke\n'
                            '${widget.email.isEmpty ? "example@gmail.com" : widget.email}',
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: grey,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ================= 4 KOLOM OTP =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 0; i < 4; i++) ...[
                              _buildOtpBox(i),
                            ],
                          ],
                        ),
                        const SizedBox(height: 29),

                        // ================= KIRIM ULANG KODE =================
                        Center(
                          child: GestureDetector(
                            onTap: _resendCode,
                            child: Text(
                              'Kirim Ulang Kode',
                              style: google_fonts.GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _secondsRemaining == 0
                                    ? primary
                                    : subGrey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ================= TIMER =================
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Kode berlaku dalam ',
                              style: google_fonts.GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: _formattedTime,
                                  style: google_fonts.GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 41),

                        // ================= TOMBOL VERIFIKASI =================
                        Center(
                          child: SizedBox(
                            width: 186,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _onVerify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Verifikasi',
                                style: google_fonts.GoogleFonts.inter(
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
                  const SizedBox(height: 24),

                  // ================= TEKS BAWAH (DINAMIS) =================
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        widget.isFromForgotPassword
                            ? 'Ubah alamat email'
                            : 'Kembali',
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
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