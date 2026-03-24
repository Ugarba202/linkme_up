import 'package:flutter/material.dart';
import 'package:linkmeup_app/core/themes/app_colors.dart';
import 'steps/username_step.dart';
import 'steps/profile_setup_step.dart';
import 'steps/connect_socials_step.dart';

import 'package:go_router/go_router.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  // State for the wizard
  String _username = '';
  String _name = '';
  String _bio = '';
  
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Finish wizard
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: _previousStep,
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_totalSteps, (index) {
            final isActive = index <= _currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 24 : 12,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryPurple : AppColors.gray300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe to force using buttons
          onPageChanged: (index) {
            setState(() {
              _currentStep = index;
            });
          },
          children: [
            UsernameStep(
              initialValue: _username,
              onSaved: (val) {
                setState(() => _username = val);
                _nextStep();
              },
            ),
            ProfileSetupStep(
              initialName: _name,
              initialBio: _bio,
              onSaved: (name, bio) {
                setState(() {
                  _name = name;
                  _bio = bio;
                });
                _nextStep();
              },
            ),
            ConnectSocialsStep(
              onFinish: () {
                // Submit to backend (mocked) and go to dashboard
                // For now, since authentication mock redirects to /auth/country, we might adjust routing later.
                // Let's go to /analytics directly as it assumes success.
                context.go('/analytics');
              },
            ),
          ],
        ),
      ),
    );
  }
}
