import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_colors.dart';

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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
         decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          destinations: const [
            NavigationDestination(label: 'Home', icon: Icon(Icons.grid_view_rounded)),
            NavigationDestination(label: 'QR Code', icon: Icon(Icons.qr_code_rounded)),
            NavigationDestination(label: 'Profile', icon: Icon(Icons.person_rounded)),
          ],
          onDestinationSelected: _goBranch,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppColors.primaryPurple.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
