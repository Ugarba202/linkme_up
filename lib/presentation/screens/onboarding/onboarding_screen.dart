import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _onboardingPages = [
    OnboardingContent(
      title: 'One QR.\nAll your links.',
      description: 'Link your Instagram, TikTok, YouTube, and more in seconds.',
      imageType: OnboardingImageType.connect,
    ),
    OnboardingContent(
      title: 'Scan to\nConnect.',
      description: 'Show your QR code to anyone and let them discover your digital world instantly.',
      imageType: OnboardingImageType.share,
    ),
    OnboardingContent(
      title: 'Insights that matter.',
      description: 'See who’s scanning and which platforms are trending with real-time analytics.',
      imageType: OnboardingImageType.analytics,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        title: const Text(
          'LinkQR',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/auth'),
            child: const Text(
              'SKIP',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _OnboardingPageView(content: _onboardingPages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators on the left
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _onboardingPages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: _currentPage == index ? 24 : 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFF5B62F4) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                // Next button (half of the screen width)
                SizedBox(
                  width: 140, // Around half width of typical device or explicitly fixed
                  child: PrimaryButton(
                    text: '',
                    onPressed: _nextPage,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum OnboardingImageType { connect, share, analytics }

class OnboardingContent {
  final String title;
  final String description;
  final OnboardingImageType imageType;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.imageType,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final OnboardingContent content;

  const _OnboardingPageView({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: _buildGraphic(content.imageType),
          ),
          const SizedBox(height: 48),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content.title,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGraphic(OnboardingImageType type) {
    switch (type) {
      case OnboardingImageType.connect:
        return _ConnectGraphic();
      case OnboardingImageType.share:
        return _ShareGraphic();
      case OnboardingImageType.analytics:
        return _AnalyticsGraphic();
    }
  }
}

class _ConnectGraphic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 250,
        height: 250,
      ),
    );
  }
}

class _ShareGraphic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 200,
        height: 200,
      ),
    );
  }
}

class _AnalyticsGraphic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      width: double.infinity,
    );
  }
}
