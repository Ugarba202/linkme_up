import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isUploadingProfile = false;
  bool _isUploadingBanner = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    HapticFeedback.mediumImpact();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() => _isUploadingProfile = true);
      try {
        await ref.read(userProvider.notifier).uploadProfileImage(File(pickedFile.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload image: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploadingProfile = false);
      }
    }
  }

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    HapticFeedback.mediumImpact();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() => _isUploadingBanner = true);
      try {
        await ref.read(userProvider.notifier).uploadBannerImage(File(pickedFile.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Banner updated")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload banner: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploadingBanner = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Profile Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryPurple,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner / Gradient Background
                  GestureDetector(
                    onTap: _isUploadingBanner ? null : _pickBannerImage,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: user?.bannerUrl == null || user!.bannerUrl!.isEmpty 
                          ? AppColors.primaryGradient 
                          : null,
                        image: user?.bannerUrl != null && user!.bannerUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(user.bannerUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (user?.bannerUrl == null || user!.bannerUrl!.isEmpty)
                            const Opacity(
                              opacity: 0.3,
                              child: Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 40),
                            ),
                          if (_isUploadingBanner)
                            Container(
                              color: Colors.black26,
                              child: const CircularProgressIndicator(color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _isUploadingProfile ? null : _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white24,
                                backgroundImage: backgroundImage,
                                child: _isUploadingProfile 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : (backgroundImage == null
                                    ? Text(
                                        (user?.name ?? "U")
                                                    .trim()
                                                    .split(" ")
                                                    .length >= 2
                                            ? "${(user?.name ?? "U").trim().split(" ")[0][0]}${(user?.name ?? "U").trim().split(" ")[1][0]}"
                                                .toUpperCase()
                                            : (user?.name ?? "U").isNotEmpty
                                                ? (user?.name ?? "U")[0].toUpperCase()
                                                : "U",
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.primaryPurple,
                                  size: 20,
                                ),
                              ),
                            ).animate().scale(
                              delay: 400.ms,
                              curve: Curves.easeOutBack,
                            ),
                          ],
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? "User",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      Text(
                        "@${user?.username ?? 'username'}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 130),
              child: Column(
                children: [
                  // Account Section
                  _buildSection(
                    context,
                    title: "Account Information",
                    items: [
                      _buildSettingsTile(
                        context,
                        label: "Full Name",
                        value: user?.name ?? "N/A",
                        icon: Icons.person_outline_rounded,
                        onTap: () => _showEditField(
                          context,
                          ref,
                          "Name",
                          user?.name ?? "",
                          (v) => ref.read(userProvider.notifier).updateName(v),
                        ),
                      ),
                      _buildSettingsTile(
                        context,
                        label: "Bio",
                        value: user?.bio == null || user!.bio.isEmpty ? "No bio set" : user.bio,
                        icon: Icons.description_outlined,
                        onTap: () => _showEditField(
                          context,
                          ref,
                          "Bio",
                          user?.bio ?? "",
                          (v) => ref.read(userProvider.notifier).updateBio(v),
                        ),
                      ),
                      _buildSettingsTile(
                        context,
                        label: "Country / Region",
                        value: user?.country ?? "Nigeria",
                        icon: Icons.public_rounded,
                        onTap: () => _showEditField(
                          context,
                          ref,
                          "Country",
                          user?.country ?? "",
                          (v) => ref.read(userProvider.notifier).updateCountry(v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Connection Section
                  _buildSection(
                    context,
                    title: "Brand & Socials",
                    items: [
                      _buildSettingsTile(
                        context,
                        label: "Manage Linked Accounts",
                        icon: Icons.share_rounded,
                        onTap: () => context.push('/profile/settings/manage-socials'),
                      ),
                      ...((user?.socialLinks ?? [])).map(
                        (link) => _buildToggleTile(
                          context,
                          label: link.platform.displayName,
                          value: link.username,
                          icon: link.platform.icon,
                          isVisible: link.isVisible,
                          onToggle: (val) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(userProvider.notifier)
                                .toggleSocialVisibility(link.id);
                          },
                        ),
                      ),
                      _buildSettingsTile(
                        context,
                        label: "My Personal Link",
                        value: "linkmeup.app/${user?.username ?? 'user'}",
                        icon: Icons.link_rounded,
                        isReadOnly: true,
                        showCopy: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // App Section
                  _buildSection(
                    context,
                    title: "General Preferences",
                    items: [
                      _buildSettingsTile(
                        context,
                        label: "Appearance",
                        value: isDark ? "Dark Mode" : "Light Mode",
                        icon: Icons.palette_outlined,
                        onTap: () {}, // Implementation placeholder
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Logout
                  _buildLogoutButton(context, ref),
                  const SizedBox(height: 16),
                  _buildDeleteAccountButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.gray400,
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.6)
              : Colors.white,
          borderRadius: 24,
          borderColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.gray200.withValues(alpha: 0.5),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (idx < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.gray100,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required bool isVisible,
    required Function(bool) onToggle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(color: AppColors.gray500, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Switch.adaptive(
        value: isVisible,
        activeTrackColor: AppColors.primaryPurple.withValues(alpha: 0.5),
        activeColor: AppColors.primaryPurple,
        onChanged: onToggle,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String label,
    String? value,
    required IconData icon,
    bool isReadOnly = false,
    bool showCopy = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap != null || showCopy
          ? () {
              HapticFeedback.lightImpact();
              if (showCopy && value != null) {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Link copied to clipboard")),
                );
              } else {
                onTap?.call();
              }
            }
          : null,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: value != null
          ? Text(
              value,
              style: const TextStyle(color: AppColors.gray500, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: showCopy
          ? const Icon(Icons.copy_rounded, size: 18, color: AppColors.gray400)
          : (onTap != null
                ? const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.gray300,
                  )
                : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () async {
        HapticFeedback.heavyImpact();
        await ref.read(userProvider.notifier).signOut();
        if (mounted) {
          context.go('/onboarding');
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.error,
        backgroundColor: AppColors.error.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 20),
          SizedBox(width: 12),
          Text(
            "Logout Account",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Account"),
            content: const Text(
                "Are you sure you want to delete your account? This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  context.go('/onboarding'); // Mock deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Account deleted")),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },
      child: Text(
        "Delete Account",
        style: TextStyle(
          color: AppColors.error.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  void _showEditField(
    BuildContext context,
    WidgetRef ref,
    String title,
    String initialValue,
    Function(String) onSave,
  ) {
    HapticFeedback.mediumImpact();
    final controller = TextEditingController(text: initialValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Update $title",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your profile details below.",
                    style: TextStyle(color: AppColors.gray400),
                  ),
                  const SizedBox(height: 32),
                  CustomInput(
                    controller: controller,
                    label: title,
                    hintText: "Enter your $title",
                    prefixIcon: title == "Bio"
                        ? Icons.description_outlined
                        : Icons.person_outline_rounded,
                    keyboardType: title == "Bio"
                        ? TextInputType.multiline
                        : TextInputType.text,
                    maxLines: title == "Bio" ? 4 : 1,
                  ),
                  const SizedBox(height: 40),
                  GradientButton(
                    text: "Save Changes",
                    onPressed: () {
                      final val = controller.text.trim();
                      if (val.isNotEmpty) {
                        onSave(val);
                        HapticFeedback.lightImpact();
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$title updated")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
