import 'package:flutter/material.dart';
import 'dashboard/home_screen.dart';
import 'dashboard/my_qr_screen.dart';
import 'analytics/analytics_screen.dart';
import 'profile/edit_profile_screen.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0; // Start at Home

  final List<Widget> _pages = [
    const HomeScreen(),
    const MyQRScreen(),
    const SizedBox(), // Placeholder for SCAN button center
    const AnalyticsScreen(),
    const EditProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Center Scan Button Action
      _openScanner();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _openScanner() {
    // Navigate to scan screen or trigger overlay
    // For now, push to the existing scanner screen
    Navigator.of(context).pushNamed('/qr/scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body behind the navbar if needed for transparency effects
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      height: 110, // Extra height to accommodate the floating center button
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Main Nav Bar Background
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'HOME'),
                _buildNavItem(1, Icons.qr_code_2_rounded, 'MY QR'),
                const SizedBox(width: 60), // Space for center button
                _buildNavItem(3, Icons.analytics_rounded, 'ANALYTICS'),
                _buildNavItem(4, Icons.person_rounded, 'PROFILE'),
              ],
            ),
          ),
          // Center Floating Scan Button
          Positioned(
            top: 0,
            child: _buildCenterScanButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF5B62F4) : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF5B62F4) : Colors.grey.shade400,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterScanButton() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF5B62F4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B62F4).withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'SCAN',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
