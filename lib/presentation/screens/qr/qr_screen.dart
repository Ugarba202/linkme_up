import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';

class QrScreen extends ConsumerWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final username = user?.name ?? "User";
    final shareUrl = "https://linkup.to/${username.replaceAll(' ', '').toLowerCase()}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary),
            onPressed: () {
              // Share logic
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Info
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primarySoft,
              child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "@${username.replaceAll(' ', '').toLowerCase()}",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const Spacer(),

            // BIG QR CODE
            GestureDetector(
              onTap: () => context.push('/qr/full'),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: shareUrl,
                  version: QrVersions.auto,
                  size: 260.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: AppColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   // Share logic
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share_rounded),
                    SizedBox(width: 12),
                    Text(
                      "Share my QR",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/profile/manage-socials'),
              child: const Text(
                "Manage Socials",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
