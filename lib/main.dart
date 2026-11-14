import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simpasi/screens/splash/splash.dart';

import 'widgets/responsive_wrapper.dart';
import 'core/app_theme.dart' as app_theme;
import 'core/app_scroll_behavior.dart';
import 'package:simpasi/screens/notifikasi/notifikasi_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  NotificationData.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simpasi',
      debugShowCheckedModeBanner: false,
      theme: app_theme.AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) => ResponsiveWrapper(
        child: RepaintBoundary(child: child!),
      ),
      home: const SplashScreen(),
    );
  }
}