import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:simpasi/core/network/api_client.dart';
import 'package:simpasi/screens/auth/login.dart';
import 'package:simpasi/screens/home/home_ibu_screen.dart';
import 'package:simpasi/screens/splash/splash.dart';
import 'package:simpasi/screens/notifikasi/notifikasi_screen.dart';
import 'widgets/responsive_wrapper.dart';
import 'core/app_theme.dart' as app_theme;
import 'core/app_scroll_behavior.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
DateTime? _lastLoginSuccessAt;

void markLoginSuccess() {
  _lastLoginSuccessAt = DateTime.now();
  Future.microtask(() {
    try {
      NotificationData.init();
    } catch (_) {
      // Jangan gagalkan navigasi ke home bila inisialisasi notifikasi bermasalah
    }
  });
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeIbuScreen(showLoginSuccess: true),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  ApiClient.onSessionExpired = () {
    // Hindari redirect paksa ke /login tepat setelah login sukses
    final justLoggedIn = _lastLoginSuccessAt != null &&
        DateTime.now().difference(_lastLoginSuccessAt!) <
            const Duration(seconds: 3);
    if (justLoggedIn) return;

    final currentUri = appRouter.routeInformationProvider.value.uri.path;
    if (currentUri != '/login') {
      try {
        NotificationData.stopBackgroundSync();
      } catch (_) {}
      appRouter.go('/login');
    }
  };

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simpasi',
      debugShowCheckedModeBanner: false,
      theme: app_theme.AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      routerConfig: appRouter,
      builder: (context, child) => ResponsiveWrapper(
        child: RepaintBoundary(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}