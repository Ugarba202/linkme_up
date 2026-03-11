import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_container.dart';
import '../../../domain/entities/user_entity.dart';

class ProfileLandingScreen extends StatelessWidget {
  final UserEntity user;

  const ProfileLandingScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for premium feel
      body: Stack(
        children: [
          // Background Gradients
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.5, 1.5),
                  duration: 5.seconds,
                ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 4.seconds,
                ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxWidth: isWide ? 420 : double.infinity),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                child: Column(
                  children: [
                    // Brand Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.link_rounded, color: AppColors.primaryPurple, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "LinkMeUp",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 48),
                    
                    // Profile Avatar & Banner
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Banner
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: user.bannerUrl == null || user.bannerUrl!.isEmpty 
                              ? AppColors.primaryGradient 
                              : null,
                            image: user.bannerUrl != null && user.bannerUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.bannerUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          ),
                        ),
                        // Avatar overlaying banner
                        Positioned(
                          bottom: -40,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Hero(
                              tag: 'profile_pic_${user.uid}',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.darkSurface,
                                backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                                    ? const Icon(Icons.person, size: 50, color: AppColors.gray400)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                    
                    const SizedBox(height: 60),
                    
                    // Name & Handle
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 4),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        "@${user.username}",
                        style: const TextStyle(
                          color: AppColors.primaryPurple, 
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    
                    const SizedBox(height: 16),

                    // Bio
                    if (user.bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          user.bio,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Connected Tabs Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "CONNECTED TABS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 2,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    
                    const SizedBox(height: 20),
                    
                    // Premium Web-style Link List
                    ...user.socialLinks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final link = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PremiumWebLinkTile(
                          title: link.platform.displayName,
                          subtitle: link.platform.ctaLabel,
                          icon: link.platform.icon,
                          color: link.platform.color,
                          onTap: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
                        ).animate(delay: (600 + (index * 100)).ms).fadeIn().slideX(begin: 0.05, end: 0),
                      );
                    }),
                    
                    const SizedBox(height: 48),
                    
                    // CTA Section
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 32,
                      color: Colors.white.withValues(alpha: 0.03),
                      borderColor: Colors.white.withValues(alpha: 0.05),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryPurple, size: 32),
                          const SizedBox(height: 16),
                          const Text(
                            "Ready for your own digital pass?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create your unified social profile and share it with a single scan.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: "Create My LinkMeUp",
                            onPressed: () {},
                            icon: Icons.rocket_launch_rounded,
                          ),
                        ],
                      ),
                    ).animate(delay: 1.seconds).fadeIn().scale(),
                    
                    const SizedBox(height: 40),

                    // Copyright
                    Text(
                      "© 2026 LinkMeUp. All rights reserved.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 12,
                      ),
                    ),
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

class _PremiumWebLinkTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PremiumWebLinkTile({
    required this.title, 
    required this.subtitle,
    required this.icon, 
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        color: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.05),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded, 
              color: Colors.white.withValues(alpha: 0.2), 
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
