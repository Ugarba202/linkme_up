import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/social_link_entity.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final links = user?.socialLinks ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                   CircleAvatar(
                     radius: 24,
                     backgroundColor: AppColors.primarySoft,
                     child: const Icon(Icons.person_rounded, color: AppColors.primary),
                   ),
                   const SizedBox(width: 16),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text(
                         "Hello,",
                         style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                       ),
                       Text(
                         user?.name ?? "Explorer",
                         style: const TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: AppColors.textPrimary,
                         ),
                       ),
                     ],
                   ),
                   const Spacer(),
                   IconButton(
                     onPressed: () => context.push('/profile/settings'),
                     icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
                   ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "Your connections",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${links.length} platform${links.length == 1 ? '' : 's'} connected",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Grid of Socials
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: links.length + 1,
                  itemBuilder: (context, index) {
                    if (index == links.length) {
                      // Add more button
                      return _buildAddButton(context);
                    }
                    return _buildSocialCard(links[index]);
                  },
                ),
              ),

              // Core Experience Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/qr'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Show My QR Code",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialCard(SocialLinkEntity link) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getPlatformIcon(link.platform), color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            link.platform.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile/add-socials'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, style: BorderStyle.solid, width: 2),
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 32),
      ),
    );
  }

  IconData _getPlatformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram: return Icons.camera_alt_rounded;
      case SocialPlatform.twitter: return Icons.alternate_email_rounded;
      case SocialPlatform.linkedin: return Icons.work_rounded;
      case SocialPlatform.github: return Icons.code_rounded;
      case SocialPlatform.tiktok: return Icons.music_note_rounded;
      case SocialPlatform.youtube: return Icons.play_circle_fill_rounded;
      case SocialPlatform.whatsapp: return Icons.message_rounded;
      case SocialPlatform.snapchat: return Icons.snapchat_rounded;
      default: return Icons.link_rounded;
    }
  }
}
