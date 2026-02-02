import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/social_link_entity.dart' as social_link_entity;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ImageProvider? profileImage;
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      if (user.photoUrl!.startsWith('http')) {
        profileImage = NetworkImage(user.photoUrl!);
      } else {
        profileImage = FileImage(File(user.photoUrl!));
      }
    }

    ImageProvider? bannerImage;
    if (user.bannerUrl != null && user.bannerUrl!.isNotEmpty) {
      if (user.bannerUrl!.startsWith('http')) {
        bannerImage = NetworkImage(user.bannerUrl!);
      } else {
        bannerImage = FileImage(File(user.bannerUrl!));
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Banner & Back Button
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: bannerImage != null
                  ? Image(image: bannerImage, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryPurple, AppColors.success],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white.withValues(alpha: 0.2),
                          size: 64,
                        ),
                      ),
                    ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Overlapping Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.gray200,
                        backgroundImage: profileImage,
                        child: profileImage == null
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPurple,
                                ),
                              )
                            : null,
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 16),

                    // User Info
                    Column(
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primaryPurple,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.country,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.gray500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "@${user.username}",
                              style: const TextStyle(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Bio
                    if (user.bio.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          user.bio,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                height: 1.5,
                                color: isDark
                                    ? AppColors.gray300
                                    : AppColors.gray700,
                              ),
                        ),
                      ).animate(delay: 300.ms).fadeIn(),

                    const SizedBox(height: 40),

                    // Social Connections Header
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Social Connections",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ).animate(delay: 400.ms).fadeIn(),

                    const SizedBox(height: 16),

                    // Social Links Grid-like List
                    if (user.socialLinks.where((l) => l.isVisible).isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No social links connected yet.",
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: user.socialLinks
                            .where((l) => l.isVisible)
                            .length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final link = user.socialLinks
                              .where((l) => l.isVisible)
                              .toList()[index];
                          return _SocialCTATile(
                                link: link,
                                onTap: () => _launchSocial(context, link.url),
                                isDark: isDark,
                              )
                              .animate(delay: (500 + (index * 100)).ms)
                              .fadeIn()
                              .slideX(begin: 0.1, end: 0);
                        },
                      ),

                    const SizedBox(height: 48),

                    // Follow Button with Website Link
                    GradientButton(
                      text: "Get LinkMeUp & Follow",
                      onPressed: () => _launchSocial(
                        context,
                        "https://linkmeup.ugarba.com/download",
                      ),
                      icon: Icons.person_add_rounded,
                    ).animate(delay: 1000.ms).fadeIn().scale(),

                    const SizedBox(height: 130),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialCTATile extends StatelessWidget {
  final social_link_entity.SocialLinkEntity link;
  final VoidCallback onTap;
  final bool isDark;

  const _SocialCTATile({
    required this.link,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.gray100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: link.platform.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                link.platform.icon,
                color: link.platform.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.platform.ctaLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    link.platform.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.gray300,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Fixed import for SocialLinkEntity since I renamed the tile and added more logic
// Actually I need to fix the import in the tile or use the full path
