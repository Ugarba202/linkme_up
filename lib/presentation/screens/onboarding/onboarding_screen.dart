import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        onPageChanged: (i) {
          setState(() => index = i);
        },
        children: [
          buildPage("Connect instantly"),
          buildPage("One QR for all socials"),
          buildLastPage(),
        ],
      ),
    );
  }

  Widget buildPage(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Widget buildLastPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Ready to start?", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              context.go('/auth');
            },
            child: const Text("Get Started"),
          ),
        ],
      ),
    );
  }
}
