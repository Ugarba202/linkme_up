import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "👤",
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Choose a Username",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "This will be your unique identity on LinkMeUp.",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Username Input inside Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _errorText != null ? Colors.red : AppColors.border,
                        ),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        onChanged: _validateUsername,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          prefixText: "@ ",
                          prefixStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                          hintText: "username",
                          hintStyle: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          errorText: null, // Handled manually below
                        ),
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false, 
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _errorText!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    // Preview Link
                    if (_usernameController.text.isNotEmpty && _errorText == null)
                      Text(
                        "linkmeup.ugarba/${_usernameController.text.trim()}",
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _usernameController.text.isEmpty || _errorText != null
                      ? null
                      : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Create Username",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
