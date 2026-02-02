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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    HapticFeedback.mediumImpact();
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
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  // Subtle Animated Circles
                  Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: 0, end: 30, duration: 3.seconds),

                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () => _pickImage(context, ref),
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
                                child: backgroundImage == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                    : null,
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
                        label: "Email Address",
                        value: user?.email ?? "N/A",
                        icon: Icons.email_outlined,
                        onTap: () => _showEditField(
                          context,
                          ref,
                          "Email",
                          user?.email ?? "",
                          (v) => ref.read(userProvider.notifier).updateEmail(v),
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
                          (v) =>
                              ref.read(userProvider.notifier).updateCountry(v),
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
                        onTap: () => context.push('/profile/manage-socials'),
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
                        value: "linkmeup.ugarba/${user?.username ?? 'user'}",
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
                        label: "Notifications",
                        icon: Icons.notifications_none_rounded,
                        onTap: () {}, // Implementation placeholder
                      ),
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
                  _buildLogoutButton(context),
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
      children:
          [
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
              ]
              .animate(interval: 50.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
    );
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

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        HapticFeedback.heavyImpact();
        context.go('/onboarding');
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
                    prefixIcon: title == "Email"
                        ? Icons.email_outlined
                        : Icons.person_outline_rounded,
                    keyboardType: title == "Email"
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    maxLines: 1,
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
