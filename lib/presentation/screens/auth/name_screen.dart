import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/auth_background.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isDirty = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 100), // Large gap instead of Spacer to prevent overlap

            // Continue Button
            GradientButton(
              text: "Continue",
              onPressed: _isDirty
                  ? () => context.push('/auth/email', extra: _nameController.text.trim())
                  : null,
            ).animate().fadeIn(delay: 600.ms).scale(duration: 400.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
