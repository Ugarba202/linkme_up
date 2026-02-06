import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/themes/app_colors.dart';
import '../../widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: "Scan once, connect everywhere.",
      subtitle: "Share your entire social presence in seconds with a single QR code.",
      icon: Icons.qr_code_scanner_rounded,
    ),
    OnboardingContent(
      title: "No more awkward spelling.",
      subtitle: "Stop repeating usernames. Just show your code and stay in the flow.",
      icon: Icons.forum_rounded,
    ),
    OnboardingContent(
      title: "Your identity, simplified.",
      subtitle: "One link for all your platforms. Instantly intuitive for everyone.",
      icon: Icons.person_add_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR - Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: _currentIndex < _pages.length - 1
                    ? TextButton(
                        onPressed: () => _navigateToAuth(),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48), // Spacer to maintain layout
              ),
            ),

            // CENTER CONTENT - PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPageView(content: _pages[index]);
                },
              ),
            ),

            // BOTTOM BAR - Indicators & Action Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentIndex),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  GradientButton(
                    text: _currentIndex == _pages.length - 1
                        ? "Get Started"
                        : "Next",
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentIndex == _pages.length - 1) {
                        _navigateToAuth();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutQuart,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://linkmeup.com/terms')),
                        child: Text(
                          "Terms of Service",
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text("  •  ", style: TextStyle(color: AppColors.gray300)),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://linkmeup.com/privacy')),
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToAuth() {
    context.push('/auth/name');
  }
}

class OnboardingContent {
  final String title;
  final String subtitle;
  final IconData icon;

  OnboardingContent({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final OnboardingContent content;

  const _OnboardingPageView({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Icon Placeholder
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              content.icon,
              size: 100,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 60),

          // Title
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            content.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
