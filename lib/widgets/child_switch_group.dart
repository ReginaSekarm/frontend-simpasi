import 'package:flutter/material.dart';

class ChildSwitchGroup extends StatelessWidget {
  final String childGender; // 'L' / 'P'
  final bool showAddButton;
  final VoidCallback onSwitch;
  final VoidCallback onAdd;

  const ChildSwitchGroup({
    super.key,
    required this.childGender,
    required this.showAddButton,
    required this.onSwitch,
    required this.onAdd,
  });

  static const Color _figmaGrey = Color.fromRGBO(217, 217, 217, 0.5);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 87,
      height: 37,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pill abu
          Positioned(
            left: 10,
            top: 7,
            child: Container(
              width: 77,
              height: 30,
              decoration: BoxDecoration(
                color: _figmaGrey,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // Maskot
          Positioned(
            left: 23,
            top: 9,
            child: Image.asset(
              childGender == 'P'
                  ? 'assets/images/kepala_b.cewe.png'
                  : 'assets/images/kepala_b.cowo.png',
              width: 30.84,
              height: 23,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // Panah ⇄ / tombol +
          Positioned(
            left: 59,
            top: 14,
            child: GestureDetector(
              onTap: showAddButton ? onAdd : onSwitch,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 16,
                height: 16,
                child: Icon(
                  showAddButton ? Icons.add : Icons.swap_horiz_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Lingkaran ganti
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: onSwitch,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: _figmaGrey,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.change_circle_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}