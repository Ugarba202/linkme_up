import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_colors.dart';
import '../widgets/glass_container.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showNavBar = navigationShell.currentIndex != 0;

    return Scaffold(
      extendBody: true, // Important for glass effect to show content behind
      body: Stack(
        children: [
          // Main Content
          navigationShell,

          // Floating Island Navigation
          if (showNavBar)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: SafeArea(
                child: GlassContainer(
                  height: 70,
                  borderRadius: 35,
                  blur: 20,
                  borderOpacity: 0.1,
                  color: AppColors.primaryPurple.withValues(alpha: 0.85), // Deep purple glass
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(context, 0, Icons.grid_view_rounded, "Home"),
                      _buildNavItem(context, 1, Icons.qr_code_rounded, "QR"),
                      _buildNavItem(context, 2, Icons.person_rounded, "Profile"),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = navigationShell.currentIndex == index;
    
    return GestureDetector(
      onTap: () => _goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              size: 26,
            ),
            if (isSelected) 
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
