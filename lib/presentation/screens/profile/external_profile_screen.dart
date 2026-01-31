import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/gradient_button.dart';

class ExternalProfileScreen extends StatelessWidget {
  final UserEntity user;

  const ExternalProfileScreen({super.key, required this.user});

  Future<void> _launchSocial(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the profile')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ImageProvider? backgroundImage;
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      if (user.photoUrl!.startsWith('http')) {
        backgroundImage = NetworkImage(user.photoUrl!);
      } else {
        backgroundImage = FileImage(File(user.photoUrl!));
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Collapsing Header with Profile Image
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'profile_${user.username}',
                child: Container(
                  decoration: BoxDecoration(
                    image: backgroundImage != null
                        ? DecorationImage(image: backgroundImage, fit: BoxFit.cover)
                        : null,
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  ),
                  child: backgroundImage == null
                      ? Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                            style: const TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // User Info and Social Links
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primaryPurple, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        user.country,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 12),
                  Text(
                    "@${user.username}",
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  // Connections Header
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Social Connections",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Social Links List
                  if (user.socialLinks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        "No social links connected yet.",
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  else
                    Column(
                      children: List.generate(user.socialLinks.length, (index) {
                        final link = user.socialLinks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SocialConnectionTile(
                            platformIcon: link.platform.icon,
                            platformName: link.platform.displayName,
                            platformColor: link.platform.color,
                            onTap: () => _launchSocial(context, link.url),
                            isDark: isDark,
                          ).animate(delay: (400 + (100 * index)).ms).fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
                        );
                      }),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  GradientButton(
                    text: "Follow on LinkMeUp",
                    onPressed: () {},
                    icon: Icons.person_add_rounded,
                  ).animate(delay: 800.ms).fadeIn(duration: 500.ms),
                  
                  const SizedBox(height: 48), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialConnectionTile extends StatelessWidget {
  final IconData platformIcon;
  final String platformName;
  final Color platformColor;
  final VoidCallback onTap;
  final bool isDark;

  const _SocialConnectionTile({
    required this.platformIcon,
    required this.platformName,
    required this.platformColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: platformColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(platformIcon, color: platformColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                platformName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: AppColors.gray400, size: 18),
          ],
        ),
      ),
    );
  }
}
