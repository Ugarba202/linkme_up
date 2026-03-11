import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/social_link_detector.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';

class AddSocialsScreen extends ConsumerStatefulWidget {
  const AddSocialsScreen({super.key});

  @override
  ConsumerState<AddSocialsScreen> createState() => _AddSocialsScreenState();
}

class _AddSocialsScreenState extends ConsumerState<AddSocialsScreen> {
  final TextEditingController _linkController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _handleAnalyze() async {
    final text = _linkController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Detect all links
      final detectedLinks = SocialLinkDetector.detectAll(text);
      
      if (detectedLinks.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No valid social links detected. Please try again.")),
          );
        }
      } else {
        // 2. Save each link to Supabase
        for (final link in detectedLinks) {
          await ref.read(userProvider.notifier).addSocialLink(link);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Successfully added ${detectedLinks.length} links!")),
          );
          // Navigate to Dashboard
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding links: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_link_rounded,
                            size: 48,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Center(
                        child: Text(
                          "Add your links",
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          "Paste your social profile links below. We'll automatically detect the platforms.",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
        
                      // Paste Input
                      CustomInput(
                        controller: _linkController,
                        hintText: "https://instagram.com/username\nhttps://twitter.com/user...",
                        label: "Paste Links Here",
                        prefixIcon: Icons.link_rounded,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                      ),
        
                      const Spacer(),
                      const SizedBox(height: 32),
        
                      // Analyze Button
                      GradientButton(
                        text: "Analyze Links",
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _isProcessing,
                        onPressed: _isProcessing ? null : _handleAnalyze,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
