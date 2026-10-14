import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/responsive.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _grey = Color(0xFF8F8F8F);
  static const Color _red = Color(0xFFD45060);
  static const Color _divider = Color(0xFFD9D9D9);

  // Gambar icon tengah. Kalau mau ganti gambar, ubah di sini saja.
  static const String _centerImage = 'assets/images/start-melet-buka.png';

  @override
  Widget build(BuildContext context) {
    // Supaya tidak tertutup home bar iPhone / tombol gestur Android
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: context.w(12),
      right: context.w(12),
      bottom: context.w(20) + bottomInset,
      child: Container(
        height: context.w(60),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(5),
          vertical: context.w(3),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          border: Border.all(color: const Color(0x17AAA6A6)),
          borderRadius: BorderRadius.circular(context.w(30)),
        ),
        child: Row(
          children: [
            _popupItem(
              context,
              index: 0,
              label: 'Koleksi',
              asset: 'assets/icons/albums.svg',
            ),
            _popupItem(
              context,
              index: 1,
              label: 'Menu',
              asset: 'assets/icons/bowl.svg',
            ),
            _centerItem(context, 2),
            _popupItem(
              context,
              index: 3,
              label: 'Riwayat',
              asset: 'assets/icons/riwayat.svg',
            ),
            _popupItem(
              context,
              index: 4,
              label: 'Profil',
              asset: 'assets/icons/profil.svg',
            ),
          ],
        ),
      ),
    );
  }

  // ================= ITEM POPUP (icon SVG 30x30) =================
  Widget _popupItem(
    BuildContext context, {
    required int index,
    required String label,
    required String asset,
  }) {
    final active = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.w(55),
            height: context.w(50),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(context.w(20)),
              border: active ? Border.all(color: _divider, width: 1) : null,
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: _red,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  asset,
                  width: context.w(30),
                  height: context.w(30),
                  colorFilter: ColorFilter.mode(
                    active ? _red : _grey,
                    BlendMode.srcIn,
                  ),
                ),
                if (active) ...[
                  SizedBox(height: context.w(2)),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w500,
                      color: _red,
                      height: 12 / 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= TOMBOL TENGAH (gambar bayi + garpu sendok) =================
  Widget _centerItem(BuildContext context, int index) {
    final active = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.w(65),
            height: context.w(50),
            padding: EdgeInsets.symmetric(
              horizontal: context.w(4),
              vertical: context.w(6),
            ),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(context.w(30)),
              border: active ? Border.all(color: _divider) : null,
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: _red,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Image.asset(
              _centerImage,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  Icon(Icons.child_care, color: _red, size: context.w(28)),
            ),
          ),
        ),
      ),
    );
  }
}