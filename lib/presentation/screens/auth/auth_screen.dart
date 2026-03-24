import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/themes/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/auth_background.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    if (mounted) {
      // Navigate to setup wizard steps 
      context.push('/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, size: 48, color: AppColors.primaryPurple),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            
            // Welcome Text
            Text(
              _isLogin ? "Welcome Back" : "Create Account",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            Text(
              _isLogin ? "Enter your details to proceed." : "Sign up to start sharing your links.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 40),
            
            // Inputs
            CustomInput(
              controller: _emailController,
              hintText: "Email",
              label: "Email Address",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 20),
            
            CustomInput(
              controller: _passwordController,
              hintText: "Password",
              label: "Password",
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 40),
            
            GradientButton(
              text: _isLogin ? "Sign In" : "Sign Up",
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleAuth,
            ).animate().fadeIn(delay: 600.ms).scale(duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // Social Auth Mock Buttons
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.gray200)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Or continue with", style: TextStyle(color: AppColors.gray400, fontSize: 12)),
                ),
                Expanded(child: Divider(color: AppColors.gray200)),
              ],
            ).animate().fadeIn(delay: 700.ms),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.g_mobiledata_rounded, AppColors.facebook),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.apple_rounded, Colors.black),
              ],
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 40),
            
            // Toggle Login/Signup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? "Don't have an account? " : "Already have an account? ",
                  style: const TextStyle(color: AppColors.gray500, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: _toggleMode,
                  child: Text(
                    _isLogin ? "Sign Up" : "Sign In",
                    style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 900.ms),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }
}
