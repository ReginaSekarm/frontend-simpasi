import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================= WARNA =================
class PopupColors {
  static const Color green     = Color(0xFF76C457);
  static const Color red       = Color(0xFFD45060);
  static const Color pureRed   = Color(0xFFFF0000);
  static const Color textBlack = Color(0xFF000000);
  static const Color textGrey  = Color(0xFF8F8F8F);
}

// ================= ENUM JENIS POPUP =================
enum PopupType {
  otpResendSuccess,     // Kode OTP berhasil dikirim ulang
  emailVerifySuccess,   // Verifikasi Email Berhasil
  sendFailed,           // Gagal Mengirim Kode
  loginFailed,          // Email / Kata Sandi tidak cocok
  resetPasswordFailed,  // Gagal Memperbarui Kata Sandi
  resetPasswordSuccess, // Berhasil Memperbarui Kata Sandi
}

// ================= MAIN HELPER =================
Future<void> showStatusPopup(
  BuildContext context, {
  required PopupType type,
  VoidCallback? onClose,
  Duration duration = const Duration(seconds: 2),
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _StatusPopup(
      type: type,
      duration: duration,
      onClose: onClose,
    ),
  );
}

// ================= WIDGET POPUP =================
class _StatusPopup extends StatefulWidget {
  final PopupType type;
  final Duration duration;
  final VoidCallback? onClose;

  const _StatusPopup({
    required this.type,
    required this.duration,
    this.onClose,
  });

  @override
  State<_StatusPopup> createState() => _StatusPopupState();
}

class _StatusPopupState extends State<_StatusPopup> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _autoClose);
  }

  void _autoClose() {
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onClose?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ================= KONTEN PER TIPE =================
  String get _title {
    switch (widget.type) {
      case PopupType.otpResendSuccess:
        return 'Kode OTP berhasil\ndikirim ulang';
      case PopupType.emailVerifySuccess:
        return 'Verifikasi Email\nBerhasil';
      case PopupType.sendFailed:
        return 'Gagal Mengirim Kode';
      case PopupType.loginFailed:
        return 'Email atau Kata Sandi\ntidak cocok';
      case PopupType.resetPasswordFailed:
        return 'Gagal Memperbarui\nKata Sandi';
      case PopupType.resetPasswordSuccess:
        return 'Kata Sandi Berhasil\nDiperbarui';
    }
  }

  String get _subtitle {
    switch (widget.type) {
      case PopupType.otpResendSuccess:
        return 'Kode verifikasi baru sudah dikirim ke email Anda.';
      case PopupType.emailVerifySuccess:
        return 'Data email telah terkonfirmasi.';
      case PopupType.sendFailed:
        return 'Terjadi kendala saat mengirim kode. '
            'Periksa koneksi Anda dan coba lagi.';
      case PopupType.loginFailed:
        return 'Silakan periksa kembali ejaan email atau kata sandi. '
            'Tekan "Lupa kata sandi" jika anda lupa.';
      case PopupType.resetPasswordFailed:
        return 'Terjadi kendala saat perbarui kata sandi. '
            'Periksa koneksi Anda dan coba lagi.';
      case PopupType.resetPasswordSuccess:
        return 'Kata sandi Anda telah berhasil diperbarui. '
            'Silakan masuk dengan kata sandi baru.';
    }
  }

  Widget _buildIcon() {
    switch (widget.type) {
      // 1. Checkmark hijau dalam circle outline
      case PopupType.otpResendSuccess:
        return SizedBox(
          width: 70,
          height: 70,
          child: CustomPaint(
            painter: _CheckCirclePainter(color: PopupColors.green),
          ),
        );

      // 2. Envelope hijau outline
      case PopupType.emailVerifySuccess:
        return const Icon(
          Icons.mail_outline,
          size: 70,
          color: PopupColors.green,
        );

      // 3. X putih dalam circle merah
      case PopupType.sendFailed:
        return Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: PopupColors.red,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.close, size: 44, color: Colors.white),
        );

      // 4. Exclamation red outline
      case PopupType.loginFailed:
        return SizedBox(
          width: 70,
          height: 70,
          child: CustomPaint(
            painter: _WarningCirclePainter(color: PopupColors.pureRed),
          ),
        );

      // 5. X putih dalam circle merah (untuk reset password failed)
      case PopupType.resetPasswordFailed:
        return Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: PopupColors.red,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.close, size: 44, color: Colors.white),
        );

      // 6. Checkmark hijau untuk reset sukses
      case PopupType.resetPasswordSuccess:
        return SizedBox(
          width: 70,
          height: 70,
          child: CustomPaint(
            painter: _CheckCirclePainter(color: PopupColors.green),
          ),
        );
    }
  }

  // Border khusus: popup dengan background putih + border abu
  bool get _hasBorder =>
      widget.type == PopupType.sendFailed ||
      widget.type == PopupType.resetPasswordFailed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 27.5),
      child: Container(
        width: 335,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: _hasBorder
              ? Border.all(color: PopupColors.textGrey, width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 3),
            _buildIcon(),
            const SizedBox(height: 21),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: PopupColors.textBlack,
                height: 24 / 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PopupColors.textGrey,
                height: 17 / 14,
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// ================= CUSTOM PAINTER: CHECKMARK =================
class _CheckCirclePainter extends CustomPainter {
  final Color color;
  _CheckCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 3,
      stroke,
    );

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.30, h * 0.52)
      ..lineTo(w * 0.45, h * 0.66)
      ..lineTo(w * 0.72, h * 0.36);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================= CUSTOM PAINTER: EXCLAMATION CIRCLE =================
class _WarningCirclePainter extends CustomPainter {
  final Color color;
  _WarningCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, w / 2 - 3, stroke);

    canvas.drawLine(
      Offset(w * 0.5, h * 0.28),
      Offset(w * 0.5, h * 0.62),
      stroke,
    );

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.74),
      3.5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}