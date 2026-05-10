import 'package:flutter/material.dart';

import '../features/load_balancer/presentation/load_balancer_screen.dart';

class LoadBalancerApp extends StatelessWidget {
  const LoadBalancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF007C89);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Load Balancer Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E7EC)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const LoadBalancerScreen(),
    );
  }
}
