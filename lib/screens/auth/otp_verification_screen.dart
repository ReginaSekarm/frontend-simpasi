// lib/screens/auth/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

import '../../widgets/popup_status.dart';
import 'login.dart';

import 'reset_password_screen.dart';
import 'register.dart'; 

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
  static const Color errorRed = Color(0xFFFF0000); 

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 60;
  Timer? _timer;
  
  bool _isError = false; 

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

  // ================= POPUP GAGAL KIRIM KODE =================
  void _showFailedSendCodePopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return const _AutoDismissFailedSendCodeDialog();
      },
    );
  }

  // ================= VERIFIKASI =================
  void _onVerify() {
    final code = _otpControllers.map((c) => c.text).join();

    // Tetap pastikan harus diisi 4 digit
    if (code.length < 4) {
      setState(() => _isError = true);
      return;
    }

    setState(() => _isError = false);

    // Tampilkan Popup Sukses Kustom
    showDialog(
      context: context,
      barrierDismissible: false, // User menunggu popup hilang sendiri
      builder: (ctx) {
        return _SuccessVerificationDialog(
          onDismiss: () {
            if (widget.isFromForgotPassword) {
              // Jika dari Lupa Sandi -> Ke Reset Password
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ResetPasswordScreen(),
                ),
              );
            } else {
              // Jika dari Register -> Ke Login
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), 
                (r) => false,
              );
            }
          },
        );
      },
    );
  }

  // ================= KIRIM ULANG KODE =================
  void _resendCode() {
    if (_secondsRemaining == 0) {
      _startTimer();

      // TODO: Nanti saat API sudah siap, panggil API di sini dan gunakan try-catch seperti ini:
      // try {
      //   await api.resendOtp(widget.email); 
      //   showStatusPopup(context, type: PopupType.otpResendSuccess);
      // } catch (e) {
      //   _showFailedSendCodePopup(); // Panggil popup gagal jika API error
      // }

      // Untuk saat ini (karena API belum terhubung), kita tampilkan popup sukses
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
          border: Border.all(
            color: _isError ? errorRed : grey, 
            width: 1,
          ),
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
            if (_isError) setState(() => _isError = false);

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
                    'assets/images/start-melet-buka.png',
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
                        
                        // ================= TEKS ERROR =================
                        if (_isError) ...[
                          const SizedBox(height: 7),
                          Text(
                            'Kode yang Anda masukkan tidak cocok. Periksa lagi lalu masukkan ulang.',
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: errorRed,
                              height: 12 / 10,
                            ),
                          ),
                        ],
                        
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
                                color: subGrey,
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
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          // Jika stack kosong, paksa kembali ke Register
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        }
                      },
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

// ================= WIDGET POPUP SUKSES KUSTOM (AUTO-DIRECT) =================
class _SuccessVerificationDialog extends StatefulWidget {
  final VoidCallback onDismiss;

  const _SuccessVerificationDialog({required this.onDismiss});

  @override
  State<_SuccessVerificationDialog> createState() => _SuccessVerificationDialogState();
}

class _SuccessVerificationDialogState extends State<_SuccessVerificationDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Timer 2 detik untuk menutup otomatis lalu menjalankan onDismiss (Direct ke halaman berikutnya)
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup popup
        widget.onDismiss(); // Jalankan perpindahan halaman
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
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.email_outlined, // Ikon surat (outline)
              color: Color(0xFF76C457), // Warna hijau sesuai Figma
              size: 70,
            ),
            const SizedBox(height: 12),
            Text(
              'Verifikasi Email\nBerhasil',
              textAlign: TextAlign.center,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 24 / 20,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Data email telah terkonfirmasi.',
              textAlign: TextAlign.center,
              style: google_fonts.GoogleFonts.inter(
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

// ================= WIDGET POPUP GAGAL KIRIM KODE (SESUAI FIGMA) =================
class _AutoDismissFailedSendCodeDialog extends StatefulWidget {
  const _AutoDismissFailedSendCodeDialog();

  @override
  State<_AutoDismissFailedSendCodeDialog> createState() => _AutoDismissFailedSendCodeDialogState();
}

class _AutoDismissFailedSendCodeDialogState extends State<_AutoDismissFailedSendCodeDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Timer untuk menutup otomatis setelah 3 detik
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Batalkan timer jika popup sudah ditutup manual oleh user
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: 330,
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8F8F8F), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cancel, // Ikon silang bulat
              color: Color(0xFFD45060), // Warna primary red dari Figma
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal Mengirim Kode',
              textAlign: TextAlign.center,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 24 / 20,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Terjadi kendala saat mengirim kode.\nPeriksa koneksi Anda dan coba lagi.',
              textAlign: TextAlign.center,
              style: google_fonts.GoogleFonts.inter(
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