import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AuthBackground({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryPurple.withValues(alpha: isDark ? 0.1 : 0.05),
              isDark ? AppColors.darkBg : AppColors.gray50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : AppColors.darkBg,
                      ),
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
