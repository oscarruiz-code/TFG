import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/screens/Splash/splash_screen.dart';
import 'package:oscarruizcode_pingu/screens/Splash/logo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pingu Game',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LogoScreen();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
