import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/auth_background.dart';





class NameScreen extends ConsumerStatefulWidget {
  final String countryName;
  const NameScreen({super.key, required this.countryName});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final fullName = _nameController.text.trim();
    if (fullName.isEmpty) return;

    setState(() => _isLoading = true);
    debugPrint("DEBUG: Finalizing onboarding for $fullName (No-Auth Flow)");

    try {
      // 1. Get current user from provider (already signed in from CountryScreen)
      final currentUser = ref.read(userProvider);
      if (currentUser == null) {
        throw Exception("No active session found. Please go back.");
      }

      // 2. Auto-generate Username (Take first name)
      final firstName = fullName.split(' ').first.toLowerCase();
      // Ensure it's alphanumeric only for the URL
      final sanitizedUsername = firstName.replaceAll(RegExp(r'[^a-z0-9]'), '');
      
      String finalUsername = sanitizedUsername;
      final isAvailable = await ref.read(userRepositoryProvider).isUsernameAvailable(finalUsername);
      if (!isAvailable) {
        finalUsername = "$sanitizedUsername${DateTime.now().millisecond}";
      }

      final avatarUrl = "https://api.dicebear.com/9.x/avataaars/png?seed=$finalUsername&backgroundColor=b6e3f4,c0aede,d1d4f9";
      final publicUrl = "https://linkmeup.app/$finalUsername";

      // 3. Update the existing profile in Supabase
      final updatedUser = currentUser.copyWith(
        name: fullName,
        username: finalUsername,
        photoUrl: avatarUrl,
        publicUrl: publicUrl,
        profileCompleted: true,
      );

      debugPrint("DEBUG: Updating profile in profiles table with Username: $finalUsername...");
      await ref.read(userRepositoryProvider).createUser(updatedUser); // upsert handles update

      // 5. Set local state
      ref.read(userProvider.notifier).setUser(updatedUser);

      debugPrint("DEBUG: Account setup complete. Proceeding to welcome screen.");
      if (mounted) {
        context.go('/profile/welcome');
      }
    } catch (e) {
      debugPrint("DEBUG: Error finalizing account: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      showBackButton: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Progress Indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 60),
            
            // Emoji / Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "👋",
                  style: TextStyle(fontSize: 56),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 40),

            // Headings
            Column(
              children: [
                Text(
                  "What should we call you?",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Your name will be visible to people you connect with.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
            
            const SizedBox(height: 56),

            // Input
            CustomInput(
              controller: _nameController,
              hintText: "Your Full Name",
              label: "Full Name",
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              maxLines: 1,
              onChanged: (val) => setState(() {}),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 100), // Large gap instead of Spacer to prevent overlap

            // Continue Button
            GradientButton(
              text: "Continue",
              isLoading: _isLoading,
              onPressed: _nameController.text.trim().isEmpty || _isLoading
                  ? null
                  : _handleContinue,
            ).animate().fadeIn(delay: 600.ms).scale(duration: 400.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
