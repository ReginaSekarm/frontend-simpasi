import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

class HapusDataDialog extends StatelessWidget {
  const HapusDataDialog({super.key});

  static const Color _textBlack71 = Color(0xB5000000);
  static const Color _textGrey    = Color(0xFF8F8F8F);
  static const Color _redDelete   = Color(0xFFFF0020);
  static const Color _greyBg      = Color(0x80D9D9D9);

  /// Tampilkan dialog konfirmasi hapus data.
  /// Return true kalau user tap "Ya, hapus".
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const HapusDataDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 65),
      child: Container(
        width: 259,
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Title ----
            Text(
              'Hapus Data?',
              textAlign: TextAlign.center,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 17.76,
                fontWeight: FontWeight.w700,
                color: _textBlack71,
                height: 21 / 17.76,
              ),
            ),
            const SizedBox(height: 8),

            // ---- Subtitle ----
            Text(
              'Data akan dihapus permanen.',
              textAlign: TextAlign.center,
              style: google_fonts.GoogleFonts.inter(
                fontSize: 13.32,
                fontWeight: FontWeight.w700,
                color: _textGrey,
                height: 16 / 13.32,
              ),
            ),
            const SizedBox(height: 24),

            // ---- Buttons Row ----
            Row(
              children: [
                // Batal
                Expanded(
                  child: _buildButton(
                    label: 'Batal',
                    bgColor: _greyBg,
                    textColor: _textGrey,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 4),

                // Ya, hapus
                Expanded(
                  child: _buildButton(
                    label: 'Ya, hapus',
                    bgColor: _redDelete,
                    textColor: Colors.white,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 29.6,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(11.03),
        ),
        child: Text(
          label,
          style: google_fonts.GoogleFonts.inter(
            fontSize: 13.32,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 16 / 13.32,
          ),
        ),
      ),
    );
  }
}