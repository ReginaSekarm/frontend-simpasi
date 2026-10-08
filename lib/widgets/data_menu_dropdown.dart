import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

class DataMenuDropdown extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DataMenuDropdown({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _textBlack71  = Color(0xB5000000);
  static const Color _redDelete    = Color(0xFFFF0020);
  static const Color _dividerGrey  = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 132,
        height: 70.76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildItem(
                icon: Icons.edit_outlined,
                label: 'Ubah Data',
                color: _textBlack71,
                onTap: onEdit,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10.7),
                ),
              ),
            ),
            Container(height: 0.886, color: _dividerGrey),
            Expanded(
              child: _buildItem(
                icon: Icons.delete,
                label: 'Hapus Data',
                color: _redDelete,
                onTap: onDelete,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 16 / 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}