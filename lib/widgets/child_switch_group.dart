import 'package:flutter/material.dart';

import '../utils/responsive.dart';

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
      width: context.w(87),
      height: context.w(37),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pill abu
          Positioned(
            left: context.w(10),
            top: context.w(7),
            child: Container(
              width: context.w(77),
              height: context.w(30),
              decoration: BoxDecoration(
                color: _figmaGrey,
                borderRadius: BorderRadius.circular(context.w(15)),
              ),
            ),
          ),

          // Maskot
          Positioned(
            left: context.w(23),
            top: context.w(9),
            child: Image.asset(
              childGender == 'P'
                  ? 'assets/images/kepala_b.cewe.png'
                  : 'assets/images/kepala_b.cowo.png',
              width: context.w(30.84),
              height: context.w(23),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

          // Panah ⇄ / tombol +
          Positioned(
            left: context.w(59),
            top: context.w(14),
            child: GestureDetector(
              onTap: showAddButton ? onAdd : onSwitch,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: context.w(16),
                height: context.w(16),
                child: Icon(
                  showAddButton ? Icons.add : Icons.swap_horiz_rounded,
                  size: context.w(16),
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
                width: context.w(24),
                height: context.w(24),
                decoration: const BoxDecoration(
                  color: _figmaGrey,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.change_circle_rounded,
                  size: context.w(24),
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