import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/themes/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/auth_background.dart';
import '../../../application/providers/auth_providers.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/entities/user_entity.dart';

class CountryScreen extends ConsumerStatefulWidget {
  const CountryScreen({super.key});

  @override
  ConsumerState<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends ConsumerState<CountryScreen> {
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

  bool _isLoading = false;

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);
    try {
      // 1. Sign in anonymously to get a UID
      final uid = await ref.read(authRepositoryProvider).signInAnonymously();
      
      if (uid != null) {
        // 2. Create the initial profile with the selected country
        final newUser = UserEntity(
          uid: uid,
          name: 'User', // Placeholder until next screen
          country: _selectedCountry.name,
          createdAt: DateTime.now(),
        );

        await ref.read(userRepositoryProvider).createUser(newUser);
        
        // 3. Set local state
        ref.read(userProvider.notifier).setUser(newUser);

        if (mounted) {
          context.push('/auth/name', extra: _selectedCountry.name);
        }
      }
    } catch (e) {
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
                child: const Text("🌍", style: TextStyle(fontSize: 48)),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 32),

            Column(
              children: [
                Text(
                  "Where are you from?",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Help us personalize your experience.",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gray200.withValues(alpha: 0.5),
                  ),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray400,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 80),

            // Continue Button
            GradientButton(
              text: "Continue",
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleContinue,
            ).animate().fadeIn(delay: 500.ms).scale(duration: 400.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
