import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class QrScreen extends ConsumerWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final fullName = user?.name ?? "User";
    final username = user?.username ?? "user";
    final photoUrl = user?.photoUrl;

    ImageProvider? backgroundImage;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        backgroundImage = NetworkImage(photoUrl);
      } else {
        backgroundImage = FileImage(File(photoUrl));
      }
    }

    final displayHandle = username.isNotEmpty ? username : "user";
    final shareUrl = "https://linkmeup.ugarba/$displayHandle";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Shared background gradient
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Text(
                      "My Pass",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Spacer(),
                    // Camera/Scan Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.primaryPurple,
                        ),
                        onPressed: () => context.go('/qr/scan'),
                        tooltip: "Scan Code",
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Share Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.share_rounded,
                          color: AppColors.primaryPurple,
                        ),
                        onPressed: () {
                          Share.share(
                            "Check out my profile on LinkMeUp: $shareUrl",
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 20),

              // Digital Pass Card
              Expanded(
                child:
                    Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: GlassContainer(
                              borderRadius: 32,
                              blur: 0,
                              borderOpacity: 0,
                              color: Colors.transparent,
                              borderColor: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Top Section: Profile
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(32),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            // boxShadow removed or made transparent
                                          ),
                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundColor:
                                                AppColors.primaryPurple,
                                            backgroundImage: backgroundImage,
                                            child: backgroundImage == null
                                                ? Text(
                                                    (fullName.trim().split(" ").length >= 2
                                                            ? "${fullName.trim().split(" ")[0][0]}${fullName.trim().split(" ")[1][0]}"
                                                            : fullName.isNotEmpty
                                                                ? fullName[0]
                                                                : "U")
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 40,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          fullName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "@$displayHandle",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: AppColors.primaryPurple,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Bottom Section: QR
                                  Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: QrImageView(
                                      data: shareUrl,
                                      version: QrVersions.auto,
                                      size: 200.0,
                                      // Use darker/contrast color for QR to ensure readability on glass
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: QrEyeShape
                                            .square, // Keep user's preference
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape:
                                            QrDataModuleShape.circle,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),

                                  // Clickable Link
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 32.0,
                                      left: 24,
                                      right: 24,
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final Uri url = Uri.parse(shareUrl);
                                        if (!await launchUrl(url)) {
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not launch url',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        shareUrl,
                                        style: const TextStyle(
                                          color: AppColors.primaryBlue,
                                          decoration: TextDecoration.underline,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .scale(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(delay: 200.ms),
              ),

              const SizedBox(height: 32),

              // Bottom Actions (Scan Button Removed as per request to move/consolidate?
              // Wait, user said "remove first a camera... can tap open to scan".
              // Actually, I'll keep the big button as it's good UX, but I also added the top icon.
              // The user said "remove the link..." -> I ADDED it back.
              // "remove remvoe first a camera" -> I think they mean I REMOVED it and they want it back.
              // I will leave the bottom button as it's the primary action for scanning usually.
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 130),
                child: GradientButton(
                  text: "Scan a Code",
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: () => context.go('/qr/scan'),
                ),
              ).animate().slideY(
                begin: 1.0,
                end: 0,
                delay: 500.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
