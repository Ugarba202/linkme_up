import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/social_link_detector.dart';
import '../../../domain/entities/social_link_entity.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String? rawLinks;
  const DashboardScreen({super.key, this.rawLinks});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  List<SocialLinkEntity> _detectLinks = [];
  final Set<SocialPlatform> _selectedPlatforms = {};

  @override
  void initState() {
    super.initState();
    _processLinks();
  }

  void _processLinks() {
    if (widget.rawLinks != null) {
      setState(() {
        _detectLinks = SocialLinkDetector.detectAll(widget.rawLinks!);
        // By default, maybe select all? Or let user tap? User said "tap and see how many connected"
        // So they start unselected.
      });
    } else {
       // Load existing links if no new ones provided
       final user = ref.read(userProvider);
       if (user != null) {
         setState(() {
           _detectLinks = user.socialLinks;
           for (var link in user.socialLinks) {
             _selectedPlatforms.add(link.platform);
           }
         });
       }
    }
  }

  void _toggleSelection(SocialPlatform platform) {
    setState(() {
      if (_selectedPlatforms.contains(platform)) {
        _selectedPlatforms.remove(platform);
      } else {
        _selectedPlatforms.add(platform);
      }
    });
  }

  void _handleConnect() {
    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one to connect.")),
      );
      return;
    }
    
    // Save selected links to provider
    final finalLinks = _detectLinks.where((l) => _selectedPlatforms.contains(l.platform)).toList();
    final user = ref.read(userProvider);
    if (user != null) {
      ref.read(userProvider.notifier).setUser(user.copyWith(socialLinks: finalLinks));
    }
    
    // Proceed to next screen (QR)
    context.go('/qr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: _currentIndex == 0 ? _buildDashboardHome() : const Center(child: Text("Coming Soon")),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppColors.primaryPurple.withValues(alpha: 0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
               icon: Icon(Icons.qr_code_rounded),
               label: 'Share',
             ),
             NavigationDestination(
               icon: Icon(Icons.person_rounded),
               label: 'Profile',
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome() {
    final user = ref.watch(userProvider);
    final username = user?.username ?? "User";
    
    String initials = "";
    if (user?.name != null && user!.name.isNotEmpty) {
      List<String> names = user.name.split(" ");
      initials = names.length >= 2 ? "${names[0][0]}${names[1][0]}" : names[0][0];
    } else {
      initials = username.isNotEmpty ? username[0] : "U";
    }

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                  child: Text(initials.toUpperCase(), style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello, $username!", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Connect your world", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary)),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(height: 8, width: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _detectLinks.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.link_off_rounded, size: 64, color: AppColors.gray300),
                      const SizedBox(height: 16),
                      const Text("No links detected.", style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/profile/add-socials'),
                        child: const Text("Go Back & Paste Links"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Detected Links", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _detectLinks.length,
                        itemBuilder: (context, index) {
                          final link = _detectLinks[index];
                          final isSelected = _selectedPlatforms.contains(link.platform);
                          return GestureDetector(
                            onTap: () => _toggleSelection(link.platform),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? link.platform.color.withValues(alpha: 0.1) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? link.platform.color : AppColors.gray200, width: isSelected ? 2 : 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(link.platform.icon, color: isSelected ? link.platform.color : AppColors.gray300, size: 32),
                                  const SizedBox(height: 8),
                                  Text(link.platform.displayName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.black : AppColors.gray400)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Bottom Buttons
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleConnect,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: Text("Connect (${_selectedPlatforms.length} connected)"),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.go('/profile/add-socials'),
                            child: const Text("Back", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          ),
                        ],
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
