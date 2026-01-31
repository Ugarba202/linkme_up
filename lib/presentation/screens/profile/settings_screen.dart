import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/custom_input.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      ref.read(userProvider.notifier).updatePhotoUrl(pickedFile.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final photoUrl = user?.photoUrl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ImageProvider? backgroundImage;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        backgroundImage = NetworkImage(photoUrl);
      } else {
        backgroundImage = FileImage(File(photoUrl));
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Subtle background gradient
      body: Container(
        decoration: BoxDecoration(
           gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryPurple.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              centerTitle: true,
              expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Settings",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              leading: IconButton(
                 icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge?.color),
                 onPressed: () => context.pop(),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Avatar Section
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(context, ref),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryPurple, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                                  backgroundImage: backgroundImage,
                                  child: backgroundImage == null
                                      ? const Icon(Icons.person_rounded, size: 60, color: AppColors.primaryPurple)
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? "User",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "@${user?.username ?? 'username'}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryBlue),
                        ),
                      ],
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 32),

                    // Info Section
                    _buildSectionHeader(context, "Account"),
                    GlassContainer(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
                      borderRadius: 24,
                      child: Column(
                        children: [
                          _buildInfoTile(
                            context,
                            "Name",
                            user?.name ?? "N/A",
                            Icons.person_outline_rounded,
                            onTap: () {
                              if (user != null) {
                                _showEditFieldDialog(context, ref, "Name", user.name, (val) {
                                  ref.read(userProvider.notifier).updateName(val);
                                });
                              }
                            },
                          ),
                          _buildDivider(isDark),
                          _buildInfoTile(
                            context,
                            "Email",
                            user?.email ?? "N/A",
                            Icons.email_outlined,
                            onTap: () {
                              if (user != null) {
                                _showEditFieldDialog(context, ref, "Email", user.email, (val) {
                                  ref.read(userProvider.notifier).updateEmail(val);
                                });
                              }
                            },
                          ),
                          _buildDivider(isDark),
                          _buildInfoTile(
                            context,
                            "Country",
                            user?.country ?? "Nigeria",
                            Icons.public_rounded,
                            onTap: () {
                              if (user != null) {
                                 _showEditFieldDialog(context, ref, "Country", user.country, (val) {
                                  ref.read(userProvider.notifier).updateCountry(val);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 24),

                    // Share Section
                     _buildSectionHeader(context, "Share"),
                     GlassContainer(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
                      borderRadius: 24,
                      child: Column(
                        children: [
                           _buildInfoTile(
                            context,
                            "My Personal Link",
                            "linkmeup.ugarba/${user?.username ?? 'user'}",
                            Icons.link_rounded,
                            isReadOnly: true,
                            showCopy: true,
                          ),
                        ],
                      ),
                     ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: 24),

                    // Preferences
                    _buildSectionHeader(context, "Preferences"),
                    GlassContainer(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
                      borderRadius: 24,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share_rounded, color: AppColors.primaryPurple),
                        ),
                        title: const Text("Manage Socials", style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => context.push('/profile/manage-socials'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                    ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 48),

                    // Logout
                    TextButton(
                      onPressed: () {
                         // Logout logic
                         context.go('/onboarding');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.error),
                          SizedBox(width: 8),
                          Text(
                            "Log Out",
                            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1, 
      thickness: 1, 
      indent: 20, 
      endIndent: 20, 
      color: isDark ? AppColors.gray800 : AppColors.gray200,
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon, {bool isReadOnly = false, bool showCopy = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isReadOnly && !showCopy ? AppColors.textMuted : Theme.of(context).textTheme.bodyLarge?.color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: showCopy 
        ? const Icon(Icons.copy_rounded, size: 18, color: AppColors.primaryPurple)
        : (isReadOnly ? null : const Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary)),
      onTap: onTap,
    );
  }

  void _showEditFieldDialog(
    BuildContext context, 
    WidgetRef ref, 
    String title, 
    String currentValue, 
    Function(String) onSave,
  ) {
    final TextEditingController controller = TextEditingController(text: currentValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Edit $title", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(
              controller: controller,
              label: title,
              hintText: "Enter your $title",
              keyboardType: title == "Email" ? TextInputType.emailAddress : TextInputType.text, maxLines: 1,
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                 onSave(newValue);
                 context.pop();
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title updated successfully")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
