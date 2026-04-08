import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/auth_providers.dart';
import '../../../application/providers/user_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authRepository = ref.read(authRepositoryProvider);
    final userId = authRepository.currentUserId;

    if (userId != null) {
      try {
        // Ensure user profile is loaded into state before we leave the splash
        // This helps the GoRouter redirect make the right decision
        final user = await ref.read(userRepositoryProvider).getUser(userId);
        if (user != null && mounted) {
          ref.read(userProvider.notifier).setUserLocal(user);
        }
      } catch (e) {
        debugPrint("DEBUG: Error loading profile on splash: $e");
      }
    }

    if (mounted) {
      // Navigate to home; the GoRouter redirect will intercept and send to 
      // /setup or /onboarding if necessary.
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white to tally with logo background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // New Brand Logo
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/brand_logo_new.png',
                        width: 180,
                        height: 180,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // App Name
                    const Text(
                      'LinkMeUp',
                      style: TextStyle(
                        color: Color(0xFF5B62F4), // Brand Blue
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom section
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minimalist Tagline
                  const Text(
                    'ONE QR CODE. ALL YOUR LINKS. FOREVER.',
                    style: TextStyle(
                      color: Color(0xFF5B62F4),
                      fontSize: 10,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Elegant subtle indicator
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Color(0xFF5B62F4),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
