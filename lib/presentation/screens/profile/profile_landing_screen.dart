import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../../domain/entities/user_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileLandingScreen extends StatelessWidget {
  final UserEntity user;

  const ProfileLandingScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Check if we are on a wide screen (web)
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Brand
              const Text(
                "LinkMeUp",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 48),
              
              // Profile Circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2), width: 8),
                  image: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 80, color: AppColors.primaryPurple)
                    : null,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                user.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                "@${user.username}",
                style: const TextStyle(color: AppColors.primaryPurple, fontSize: 18),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                "Connect with me",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              
              const SizedBox(height: 20),
              
              // Simple Web-style Link List
              ...user.socialLinks.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WebLinkTile(
                  title: link.platform.displayName,
                  icon: link.platform.icon,
                  onTap: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
                ),
              )),
              
              const SizedBox(height: 48),
              
              // App Store buttons or CTA
              Text(
                "Get LinkMeUp to create your own digital pass",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: "Download App",
                onPressed: () {},
                icon: Icons.download_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebLinkTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _WebLinkTile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
