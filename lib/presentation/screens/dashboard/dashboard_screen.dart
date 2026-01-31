import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/social_link_detector.dart';
import '../../../domain/entities/social_link_entity.dart';
import '../../widgets/gradient_button.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String? rawLinks;
  const DashboardScreen({super.key, this.rawLinks});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final int _currentIndex = 0;
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
    final finalLinks = _detectLinks
        .where((l) => _selectedPlatforms.contains(l.platform))
        .toList();
    final user = ref.read(userProvider);
    if (user != null) {
      ref
          .read(userProvider.notifier)
          .setUser(user.copyWith(socialLinks: finalLinks));
    }

    // Proceed to next screen (QR)
    context.go('/qr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Provide a slight gradient background for depth
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              AppColors.primaryPurple.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: _currentIndex == 0
            ? _buildDashboardHome()
            : const Center(child: Text("Coming Soon")),
      ),
    );
  }

  Widget _buildDashboardHome() {
    final user = ref.watch(userProvider);
    final username = user?.username ?? "User";
    final photoUrl = user?.photoUrl;

    ImageProvider? backgroundImage;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        backgroundImage = NetworkImage(photoUrl);
      } else {
        backgroundImage = FileImage(File(photoUrl));
      }
    }

    String initials = "";
    if (user?.name != null && user!.name.isNotEmpty) {
      List<String> names = user.name.split(" ");
      initials = names.length >= 2
          ? "${names[0][0]}${names[1][0]}"
          : names[0][0];
    } else {
      initials = username.isNotEmpty ? username[0] : "U";
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryPurple.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage: backgroundImage,
                    child: backgroundImage == null
                        ? Text(
                            initials.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $username!",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Connect your world",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        Icon(
                          Icons.link_off_rounded,
                          size: 80,
                          color: AppColors.gray300.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No links detected.",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 32),
                        GradientButton(
                          text: "Add Socials",
                          width: 200,
                          onPressed: () => context.go('/profile/add-socials'),
                          icon: Icons.add_link_rounded,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              "Your Connections",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            // Add Socials Button
                            IconButton(
                              onPressed: () => context.push('/profile/add-socials'),
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_rounded, color: AppColors.primaryPurple),
                              ),
                              tooltip: "Add Link",
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${_selectedPlatforms.length} Active",
                                style: const TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4, // 4 items per row
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.0, // Square tiles
                              ),
                          itemCount: _detectLinks.length,
                          itemBuilder: (context, index) {
                            final link = _detectLinks[index];
                            final isSelected = _selectedPlatforms.contains(
                              link.platform,
                            );

                            return GestureDetector(
                              onTap: () => _toggleSelection(link.platform),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? link.platform.color.withValues(
                                          alpha: 0.9,
                                        )
                                      : (isDark
                                            ? AppColors.darkSurface
                                            : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : AppColors.gray200.withValues(
                                            alpha: 0.5,
                                          ),
                                    width: 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: link.platform.color
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        link.platform.icon,
                                        color: isSelected
                                            ? Colors.white
                                            : link.platform.color,
                                        size: 28, // Smaller icon
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                            .animate(delay: (50 * index).ms)
                            .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                            .scale(begin: const Offset(0.8, 0.8), duration: 300.ms);
                          },
                        ),
                      ),

                      // Action Bar (only if editing/selecting)
                      if (_detectLinks.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          child: GradientButton(
                            text: "Save & Continue",
                            onPressed: _handleConnect,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
