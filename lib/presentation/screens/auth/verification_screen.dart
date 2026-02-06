import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/providers/auth_providers.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/auth_background.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "🔗",
                  style: TextStyle(fontSize: 48),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 32),
            
            Column(
              children: [
                Text(
                  "Check your email",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "We've sent a verification link to your email. Please click the link to verify your account.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 48),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gray100),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primaryPurple),
                  const SizedBox(height: 12),
                  Text(
                    "After clicking the link in your email, come back here and click the button below to continue.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 80),

            // Verify Button
            GradientButton(
              text: "I have verified",
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleCheckVerification,
            ).animate().fadeIn(delay: 500.ms).scale(duration: 400.ms),
            
            const SizedBox(height: 24),
            
            TextButton(
              onPressed: () {
                // Handle resend logic here
              },
              child: const Text(
                "Resend Link",
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckVerification() async {
    setState(() => _isLoading = true);
    
    try {
      final isVerified = await ref.read(authRepositoryProvider).isEmailVerified();
      
      if (!isVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email not verified yet. Please check your inbox.")),
          );
        }
        return;
      }
      
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      final name = extra?['name'] as String? ?? 'User';
      final email = extra?['email'] as String? ?? 'user@example.com';
      final country = extra?['country'] as String? ?? 'Nigeria';

      final userId = 'mock-user-123'; // Mock ID since auth is mocked

      ref.read(userProvider.notifier).setUser(
        UserEntity(
          uid: userId,
          name: name,
          email: email,
          country: country,
          phoneNumber: '', // Not using phone number anymore
          username: '',
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) {
        context.go('/auth/username');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
