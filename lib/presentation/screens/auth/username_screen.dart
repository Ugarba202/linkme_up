import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';

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
      // Simulate API call to check availability and update profile
      await Future.delayed(const Duration(seconds: 1));
      
      
      // Generate DiceBear Avatar URL
      // Switching to 'avataaars' for a flat, clean, and widely appealing personality.
      final avatarUrl = "https://api.dicebear.com/9.x/avataaars/png?seed=$username&backgroundColor=b6e3f4,c0aede,d1d4f9";

      // Update User Provider
      final currentUser = ref.read(userProvider);
      if (currentUser != null) {
        ref.read(userProvider.notifier).setUser(
          currentUser.copyWith(
            username: username,
            photoUrl: avatarUrl, 
          ),
        );
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "👤",
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Choose a Username",
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "This will be your unique identity on LinkMeUp.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Username Input inside Container
                    CustomInput(
                      controller: _usernameController,
                      hintText: "username",
                      label: "Username",
                      onChanged: _validateUsername,
                      prefixIcon: Icons.alternate_email_rounded,
                      errorText: _errorText, maxLines:1,
                    ),
                    
                    const SizedBox(height: 12),
                    // Preview Link
                    if (_usernameController.text.isNotEmpty && _errorText == null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          "linkmeup.ugarba/${_usernameController.text.trim()}",
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              GradientButton(
                text: "Create Username",
                isLoading: _isLoading,
                onPressed: _isLoading || _usernameController.text.isEmpty || _errorText != null
                    ? null
                    : _handleContinue,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
