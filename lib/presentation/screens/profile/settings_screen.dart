import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("Profile Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primarySoft,
                    child: const Icon(Icons.person_rounded, size: 60, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Info Section
            _buildSection(
              "Account Information",
              [
                _buildInfoTile("Name", user?.name ?? "N/A", Icons.person_outline_rounded),
                _buildInfoTile("Phone", user?.phoneNumber ?? "N/A", Icons.phone_iphone_rounded, isReadOnly: true),
                _buildInfoTile("Country", "Nigeria", Icons.public_rounded),
              ],
            ),

            const SizedBox(height: 24),

            // Preferences
            _buildSection(
              "Preferences",
              [
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: AppColors.primary),
                  title: const Text("Manage Socials", style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => context.push('/profile/manage-socials'),
                  tileColor: Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextButton(
                onPressed: () {
                   // Logout logic
                   context.go('/onboarding');
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {bool isReadOnly = false}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isReadOnly ? AppColors.textMuted : AppColors.textPrimary,
        ),
      ),
      trailing: isReadOnly ? const Icon(Icons.lock_rounded, size: 16, color: AppColors.textMuted) : const Icon(Icons.edit_rounded, size: 16),
    );
  }
}
