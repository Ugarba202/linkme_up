import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/social_link_entity.dart';
import '../../widgets/glass_container.dart';

class ManageSocialsScreen extends ConsumerWidget {
  const ManageSocialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final links = user?.socialLinks ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: const Text("Manage Socials", style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: links.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: links.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final link = links[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    color: isDark ? AppColors.darkSurface.withValues(alpha: 0.6) : Colors.white,
                    borderRadius: 24,
                    borderColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200.withValues(alpha: 0.5),
                    child: Row(
                      children: [
                        // Platform Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: link.platform.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            link.platform.icon,
                            color: link.platform.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Username & Platform
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                link.platform.displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gray400,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                link.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Visibility Toggle
                        Column(
                          children: [
                            const Text(
                              "VISIBLE",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.gray400),
                            ),
                            const SizedBox(height: 4),
                            Switch.adaptive(
                              value: link.isVisible,
                              activeTrackColor: AppColors.primaryPurple.withValues(alpha: 0.5),
                              activeColor: AppColors.primaryPurple,
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
                                ref.read(userProvider.notifier).toggleSocialVisibility(link.id);
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _confirmDelete(context, ref, link);
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
                );
              },
            ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SocialLinkEntity link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Link?"),
        content: Text("Are you sure you want to remove your ${link.platform.displayName} account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProvider.notifier).removeSocialLink(link.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${link.platform.displayName} removed")),
              );
            },
            child: const Text("Remove", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.link_off_rounded, size: 80, color: AppColors.gray300),
          ),
          const SizedBox(height: 24),
          const Text(
            "No links found",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Connect your first account to get started.",
            style: TextStyle(color: AppColors.gray400),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text("Go back", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
