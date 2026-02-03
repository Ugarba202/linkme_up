import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/auth_background.dart';

class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = null;
      } else if (value.length < 3) {
        _errorText = "Username must be at least 3 characters";
      } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
        _errorText = "Only letters, numbers, and underscores allowed";
      } else {
        _errorText = null;
      }
    });
  }

  Future<void> _handleContinue() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty || _errorText != null) return;

    setState(() => _isLoading = true);

    try {
      // Check for availability first
      final isAvailable = await ref.read(userRepositoryProvider).isUsernameAvailable(username);
      if (!isAvailable) {
        setState(() {
          _errorText = "Username is already taken";
          _isLoading = false;
        });
        return;
      }

      final avatarUrl = "https://api.dicebear.com/9.x/avataaars/png?seed=$username&backgroundColor=b6e3f4,c0aede,d1d4f9";

      final currentUser = ref.read(userProvider);
      if (currentUser != null) {
        final publicUrl = "linkmeup.ugarba/${username}";
        final updatedUser = currentUser.copyWith(
          username: username,
          photoUrl: avatarUrl,
          publicUrl: publicUrl,
          profileCompleted: true,
        );
        
        // Persist to Firestore
        await ref.read(userRepositoryProvider).createUser(updatedUser);
        
        // Update local state
        ref.read(userProvider.notifier).setUser(updatedUser);
      }

      if (mounted) {
        context.go('/profile/welcome');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating username: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                  "👤",
                  style: TextStyle(fontSize: 56),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 32),
            
            Column(
              children: [
                Text(
                  "Choose a Username",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "This will be your unique identity on LinkMeUp.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 48),

            CustomInput(
              controller: _usernameController,
              hintText: "username",
              label: "Username",
              onChanged: _validateUsername,
              prefixIcon: Icons.alternate_email_rounded,
              errorText: _errorText, 
              maxLines: 1,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Preview Link
            if (_usernameController.text.isNotEmpty && _errorText == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link_rounded, color: AppColors.primaryPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "linkmeup.ugarba/${_usernameController.text.trim()}",
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 80),

            // Continue Button
            GradientButton(
              text: "Create Username",
              isLoading: _isLoading,
              onPressed: _isLoading || _usernameController.text.isEmpty || _errorText != null
                  ? null
                  : _handleContinue,
            ).animate().fadeIn(delay: 500.ms).scale(duration: 400.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
