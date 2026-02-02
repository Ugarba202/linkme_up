import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/themes/app_colors.dart';
import '../widgets/glass_container.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  void _goBranch(int index) {
    if (index == navigationShell.currentIndex) return;
    
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide nav bar on certain screens if needed
    // Hide nav bar on dashboard (index 0)
    final bool showNavBar = navigationShell.currentIndex != 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Main Content
          navigationShell,

          // Floating Industry-Standard Navigation
          if (showNavBar)
            Positioned(
              left: 32,
              right: 32,
              bottom: 32,
              child: SafeArea(
                child: Hero(
                  tag: 'main_nav',
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: GlassContainer(
                      height: 76,
                      borderRadius: 38,
                      blur: 30,
                      color: isDark 
                        ? AppColors.darkSurface.withValues(alpha: 0.8) 
                        : Colors.white.withValues(alpha: 0.85),
                      borderColor: isDark 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : AppColors.gray200.withValues(alpha: 0.5),
                      child: Stack(
                        children: [
                          // Magnetic Active Indicator
                          AnimatedAlign(
                            duration: 350.ms,
                            curve: Curves.elasticOut,
                            alignment: _getAlignment(navigationShell.currentIndex),
                            child: FractionallySizedBox(
                              widthFactor: 1 / 3,
                              child: Center(
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Nav Items
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNavItem(context, 0, Icons.grid_view_rounded, "Home"),
                              _buildNavItem(context, 1, Icons.qr_code_rounded, "QR"),
                              _buildNavItem(context, 2, Icons.person_rounded, "Profile"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 1.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
              ),
            ),
        ],
      ),
    );
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0: return Alignment.centerLeft;
      case 1: return Alignment.center;
      case 2: return Alignment.centerRight;
      default: return Alignment.centerLeft;
    }
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = navigationShell.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _goBranch(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: 200.ms,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.gray400,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: 200.ms,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
