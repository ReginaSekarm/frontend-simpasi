import 'package:flutter/material.dart';
import 'package:simpasi/screens/home/home_ibu_screen.dart';
import 'widgets/responsive_wrapper.dart';
// import 'screens/splash/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simpasi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => ResponsiveWrapper(child: child!),
      home: ResponsiveWrapper(child: HomeIbuScreen()),
    );
  }
}