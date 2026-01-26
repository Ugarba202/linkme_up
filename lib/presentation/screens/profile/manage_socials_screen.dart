import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/social_link_entity.dart';

class ManageSocialsScreen extends ConsumerWidget {
  const ManageSocialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final links = user?.socialLinks ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("Manage Socials", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: links.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: links.length,
              itemBuilder: (context, index) {
                final link = links[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getPlatformIcon(link.platform), color: AppColors.primary),
                    ),
                    title: Text(
                      link.platform.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    subtitle: Text(
                      link.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: link.isVisible,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        // Toggle logic (will need a copyWith in the notifier)
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.link_off_rounded, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            "No socials added yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Go back and add some"),
          ),
        ],
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
