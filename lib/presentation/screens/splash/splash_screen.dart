import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3F4FF), // Soft blue/purple shading
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Hero(
            tag: 'app_logo',
            child: Icon(
              Icons.link_rounded,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
