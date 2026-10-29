import 'package:flutter/material.dart';

/// Scaffold custom yang OTOMATIS:
/// - `resizeToAvoidBottomInset: false` → navbar/bottom nav tidak naik saat keyboard muncul
/// - `backgroundColor: Colors.white` → default putih
class AppScaffold extends Scaffold {
  const AppScaffold({
    super.key,
    super.appBar,
    super.body,
    super.floatingActionButton,
    super.floatingActionButtonLocation,
    super.floatingActionButtonAnimator,
    super.persistentFooterButtons,
    super.persistentFooterAlignment,
    super.drawer,
    super.onDrawerChanged,
    super.endDrawer,
    super.onEndDrawerChanged,
    super.bottomNavigationBar,
    super.bottomSheet,
    super.backgroundColor = Colors.white,
    super.resizeToAvoidBottomInset = false,   // 👈 KUNCI-NYA
    super.primary,
    super.drawerDragStartBehavior,
    super.extendBody,
    super.extendBodyBehindAppBar,
    super.drawerScrimColor,
    super.drawerEdgeDragWidth,
    super.drawerEnableOpenDragGesture,
    super.endDrawerEnableOpenDragGesture,
    super.restorationId,
  });
}