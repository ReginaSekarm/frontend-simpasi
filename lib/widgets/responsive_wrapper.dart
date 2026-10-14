import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width > Responsive.maxContentWidth
        ? Responsive.maxContentWidth
        : mq.size.width;

    return ColoredBox(
      color: const Color(0xFFEFEFEF),
      child: Center(
        child: SizedBox(
          width: width,
          child: MediaQuery(
            data: mq.copyWith(
              size: Size(width, mq.size.height),
              textScaler: mq.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}