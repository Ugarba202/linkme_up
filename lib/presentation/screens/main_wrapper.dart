import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/navigation_provider.dart';
import 'dashboard/home_screen.dart';
import 'dashboard/my_qr_screen.dart';
import 'analytics/analytics_screen.dart';
import 'profile/edit_profile_screen.dart';

import 'scanner/qr_scanner_screen.dart';

class MainWrapperScreen extends ConsumerStatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  ConsumerState<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends ConsumerState<MainWrapperScreen> {
  // Using a getter so we can conditionally mount the scanner
  List<Widget> _getPages(int currentIndex) => [
    const HomeScreen(),
    const MyQRScreen(),
    currentIndex == 2 ? const QRScannerScreen() : const SizedBox(),
    const AnalyticsScreen(),
    const EditProfileScreen(isTab: true),
  ];

  void _onTabTapped(int index) {
    ref.read(navigationProvider.notifier).setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    return Scaffold(
      extendBody: true, // Allow body behind the navbar if needed for transparency effects
      body: IndexedStack(
        index: currentIndex,
        children: _getPages(currentIndex),
      ),
      bottomNavigationBar: _buildCustomNavBar(currentIndex),
    );
  }

  Widget _buildCustomNavBar(int currentIndex) {
    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Floats the navbar
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / 5;
          final pillWidth = itemWidth * 0.8; // Pill takes 80% of item width
          
          return ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Glass Backdrop
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Liquid Moving Indicator (Pill) - Calculated for perfect centering
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  left: (currentIndex * itemWidth) + (itemWidth - pillWidth) / 2,
                  top: (80 - 44) / 2, // Centered vertically in the 80px row
                  child: Container(
                    width: pillWidth,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B62F4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B62F4).withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Nav Items
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'HOME', currentIndex),
                      _buildNavItem(1, Icons.qr_code_2_rounded, 'MY QR', currentIndex),
                      _buildNavItem(2, Icons.qr_code_scanner_rounded, 'SCAN', currentIndex),
                      _buildNavItem(3, Icons.analytics_rounded, 'ANALYTICS', currentIndex),
                      _buildNavItem(4, Icons.person_rounded, 'PROFILE', currentIndex),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int currentIndex) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF5B62F4) : Colors.grey.shade400,
                size: 26,
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected ? const Color(0xFF5B62F4) : Colors.grey.shade400,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
