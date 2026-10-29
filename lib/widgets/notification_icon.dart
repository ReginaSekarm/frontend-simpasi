import 'package:flutter/material.dart';
import '../utils/responsive.dart'; // Sesuaikan path ini dengan struktur project-mu


final ValueNotifier<int> unreadNotifications = ValueNotifier<int>(3);

class NotificationIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final double size;

  const NotificationIconButton({
    super.key,
    required this.onTap,
    this.iconColor = Colors.white,
    this.size = 25,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(context.w(4)),
        child: ValueListenableBuilder<int>(
          valueListenable: unreadNotifications,
          builder: (context, count, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: iconColor,
                  size: context.w(size),
                ),
                if (count > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: context.w(14),
                      height: context.w(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0020),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: context.w(1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: TextStyle(
                          fontSize: context.sp(9),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}