import 'package:country_picker/country_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/providers/auth_providers.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/auth_background.dart';

class EmailScreen extends ConsumerStatefulWidget {
  final String userName;
  const EmailScreen({super.key, required this.userName});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  Country _selectedCountry = Country(
    phoneCode: "234",
    countryCode: "NG",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Nigeria",
    example: "",
    displayName: "Nigeria",
    displayNameNoCountryCode: "Nigeria",
    e164Key: "",
  );

  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isValidEmail = emailRegex.hasMatch(email);
    });
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
                  "📩",
                  style: TextStyle(fontSize: 48),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 32),
            
            Column(
              children: [
                Text(
                  "Welcome, ${widget.userName}!",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "What's your email?",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "We'll use this to verify your account.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 48),

            // Country Selector
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                  countryListTheme: CountryListThemeData(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                    inputDecoration: InputDecoration(
                      labelText: 'Search Country',
                      hintText: 'Start typing to search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCountry.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray400),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 20),

            // Email Input
            CustomInput(
              controller: _emailController,
              hintText: "yourname@example.com",
              label: "Email Address",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress, 
              maxLines: 1,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 80),

            // Continue Button
            GradientButton(
              text: "Continue",
              isLoading: _isLoading,
              onPressed: !_isValidEmail ? null : _handleSendLink,
            ).animate().fadeIn(delay: 500.ms).scale(duration: 400.ms),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://linkmeup.com/terms')),
                  child: Text(
                    "Terms",
                    style: TextStyle(
                      color: AppColors.gray400,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(" • ", style: TextStyle(color: AppColors.gray400)),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://linkmeup.com/privacy')),
                  child: Text(
                    "Privacy",
                    style: TextStyle(
                      color: AppColors.gray400,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).sendEmailVerificationLink(email);
      
      if (mounted) {
        context.push('/auth/verify', extra: {
          'name': widget.userName,
          'email': email,
          'country': _selectedCountry.name,
        });
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

