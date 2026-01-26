import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/social_link_detector.dart';
import '../../../domain/entities/social_link_entity.dart';

class AddSocialsScreen extends ConsumerStatefulWidget {
  const AddSocialsScreen({super.key});

  @override
  ConsumerState<AddSocialsScreen> createState() => _AddSocialsScreenState();
}

class _AddSocialsScreenState extends ConsumerState<AddSocialsScreen> {
  final TextEditingController _linkController = TextEditingController();
  final List<SocialLinkEntity> _detectedLinks = [];
  SocialPlatform? _currentDetection;

  @override
  void initState() {
    super.initState();
    _linkController.addListener(_onLinkChanged);
  }

  void _onLinkChanged() {
    final text = _linkController.text.trim();
    if (text.isEmpty) {
      setState(() => _currentDetection = null);
      return;
    }

    final platform = SocialLinkDetector.detect(text);
    if (platform != SocialPlatform.other) {
      setState(() => _currentDetection = platform);
    }
  }

  void _addLink() {
    final text = _linkController.text.trim();
    if (text.isEmpty || _currentDetection == null) return;

    final username = SocialLinkDetector.extractUsername(text, _currentDetection!);
    
    setState(() {
      _detectedLinks.add(
        SocialLinkEntity(
          id: DateTime.now().toString(),
          platform: _currentDetection!,
          username: username,
          url: text,
        ),
      );
      _linkController.clear();
      _currentDetection = null;
    });
  }

  void _saveAndContinue() {
    // Optimization: Add all links to provider
    for (var link in _detectedLinks) {
       ref.read(userProvider.notifier).addSocialLink(link);
    }
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                "Add your socials",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Paste links or usernames to connect your accounts.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Input Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        hintText: "Paste link here...",
                        prefixIcon: const Icon(Icons.link_rounded),
                        suffixIcon: _currentDetection != null
                            ? IconButton(
                                icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 32),
                                onPressed: _addLink,
                              )
                            : null,
                      ),
                    ),
                    if (_currentDetection != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(_getPlatformIcon(_currentDetection!), color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            "${_currentDetection!.name.toUpperCase()} detected!",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Detected Links List
              const Text(
                "Your connections",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _detectedLinks.length,
                  itemBuilder: (context, index) {
                    final link = _detectedLinks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(_getPlatformIcon(link.platform), color: AppColors.primary),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                link.platform.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                link.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              setState(() => _detectedLinks.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text("Skip for now"),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _detectedLinks.isNotEmpty
                            ? _saveAndContinue
                            : null,
                        child: const Text("Continue"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
