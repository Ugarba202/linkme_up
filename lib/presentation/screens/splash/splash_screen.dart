import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    _navigateToNext();
  }

  void _navigateToNext() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Subtle Background Patterns/Shapes
            Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: 0,
                  end: 50,
                  duration: 4.seconds,
                  curve: Curves.easeInOut,
                ),

            Positioned(
                  bottom: -50,
                  left: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveX(
                  begin: 0,
                  end: 50,
                  duration: 3.seconds,
                  curve: Curves.easeInOut,
                ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container with Premium Styling
                  Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 60,
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/splash_image.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      )
                      .animate()
                      .scale(duration: 800.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 600.ms)
                      .shimmer(delay: 2.seconds, duration: 1500.ms),

                  const SizedBox(height: 32),

                  // App Name
                  Text(
                        'LinkMeUp',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 800.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 12),

                  // Tagline
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Scan • Connect • Share',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 800.ms)
                      .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
                ],
              ),
            ),

            // Loading Indicator at Bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ).animate().fadeIn(delay: 1.seconds),
            ),
          ],
        ),
      ),
    );
  }
}
