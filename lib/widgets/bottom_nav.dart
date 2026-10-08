import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 20,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          border: Border.all(color: const Color(0x17AAA6A6)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _popupItem(
              index: 0,
              label: 'Koleksi',
              asset: 'assets/icons/albums.svg',
            ),
            _popupItem(
              index: 1,
              label: 'Menu',
              asset: 'assets/icons/bowl.svg',
            ),
            _centerItem(2),
            _popupItem(
              index: 3,
              label: 'Riwayat',
              asset: 'assets/icons/riwayat.svg',
            ),
            _popupItem(
              index: 4,
              label: 'Profil',
              asset: 'assets/icons/profil.svg',
            ),
          ],
        ),
      ),
    );
  }

  // ================= ITEM POPUP (icon SVG Figma 30x30) =================
  Widget _popupItem({
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
          child: Container(
            width: 55,
            height: 50,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
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
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    active ? _red : _grey,
                    BlendMode.srcIn,
                  ),
                ),
                if (active) ...[
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
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

  // ================= TOMBOL TENGAH (logo 69.85 x 36.35) =================
  Widget _centerItem(int index) {
    final active = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: Container(
            width: 65,
            height: 50,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
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
                        child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/start-wink-melet.png',
                  width: 69.85,
                  height: 36.35,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.child_care, color: _red, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}