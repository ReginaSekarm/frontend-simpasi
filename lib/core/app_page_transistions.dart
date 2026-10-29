import 'package:flutter/material.dart';

class SmoothFadeScaleTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothFadeScaleTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; 
  }
}