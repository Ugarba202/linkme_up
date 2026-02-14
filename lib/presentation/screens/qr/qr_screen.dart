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

import '../../widgets/gradient_button.dart';
// Assuming UserEntity is in this path

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  bool _isGenerating = false;
  double _progress = 0.0;
  String _statusMessage = "Preparing your unique pass...";

  final List<String> _statusMessages = [
    "Preparing your unique pass...",
    "Scanning social footprints...",
    "Connecting social accounts...",
    "Syncing your identity...",
    "Encoding your profile URL...",
    "Generating secure QR code...",
    "Finalizing your digital pass...",
    "Almost there...",
  ];

  Future<void> _generateQr() async {
    setState(() {
      _isGenerating = true;
      _progress = 0.0;
      _statusMessage = _statusMessages[0];
    });

    // Simulate 10-second processing with status updates
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      setState(() {
        _progress = i / 100.0;
        if (i % 15 == 0) {
          int msgIndex = (i / 15).floor();
          if (msgIndex < _statusMessages.length) {
            _statusMessage = _statusMessages[msgIndex];
          }
        }
      });
    }

    if (!mounted) return;

    // Call provider to mark as generated
    await ref.read(userProvider.notifier).markQrAsGenerated();

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Widget _buildGenerateView(BuildContext context, WidgetRef ref) {
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.gray100,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPurple,
                    ),
                  ),
                  const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primaryPurple,
                        size: 48,
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 2.seconds),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate(key: ValueKey(_statusMessage))
                .fadeIn()
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 12),
            Text(
              "${(_progress * 100).toInt()}% complete",
              style: TextStyle(
                color: AppColors.gray500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                blurRadius: 40,
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            size: 100,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Ready to Generate?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "This will create your permanent LinkMeUp QR code. It only needs to be generated once!",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gray500, height: 1.5),
          ),
        ),
        const SizedBox(height: 40),
        GradientButton(
          text: "Generate My Pass",
          width: 250,
          onPressed: _generateQr,
          icon: Icons.auto_awesome_rounded,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
    final shareUrl = user?.publicUrl ?? "https://linkmeup.app/$displayHandle";

    return Scaffold(
      backgroundColor: Colors.black, // Force premium black background
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryPurple.withValues(alpha: 0.15),
              Colors.black,
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
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => context.push('/qr/scan'),
                        tooltip: "Scan Code",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
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
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 10),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Share your digital identity with a single scan",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 30),

              // Digital Pass Card
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: user != null && !user.isQrGenerated
                        ? _buildGenerateView(context, ref)
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Top Section: Profile Branding
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryPurple.withValues(alpha: 0.08),
                                        Colors.white,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(32),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundColor: AppColors.primaryPurple,
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
                                                    fontSize: 32,
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
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "@$displayHandle",
                                        style: TextStyle(
                                          color: AppColors.primaryPurple.withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Middle Section: QR Code with Logo
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: QrImageView(
                                    data: shareUrl,
                                    version: QrVersions.auto,
                                    size: 220.0,
                                    gapless: true,
                                    // Using assets/images/splash_image.png for the logo
                                    embeddedImage: const AssetImage('assets/images/splash_image.png'),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(50, 50),
                                    ),
                                    // Use standard square shapes for better scanning reliability
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: Colors.black,
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Clickable Link
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 32.0),
                                  child: InkWell(
                                    onTap: () async {
                                      final Uri url = Uri.parse(shareUrl);
                                      if (!await launchUrl(url)) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Could not launch url')),
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        shareUrl,
                                        style: const TextStyle(
                                          color: AppColors.primaryPurple,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                ),
              ),

              const SizedBox(height: 32),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
                child: GradientButton(
                  text: "Scan a Code",
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: () => context.push('/qr/scan'),
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
