import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';

class AddSocialsScreen extends ConsumerStatefulWidget {
  const AddSocialsScreen({super.key});

  @override
  ConsumerState<AddSocialsScreen> createState() => _AddSocialsScreenState();
}

class _AddSocialsScreenState extends ConsumerState<AddSocialsScreen> {
  final TextEditingController _bulkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate if we have links already
    final user = ref.read(userProvider);
    if (user != null && user.socialLinks.isNotEmpty) {
      final linksText = user.socialLinks.map((l) => l.url).join('\n');
      _bulkController.text = linksText;
    }
  }

  void _handleContinue() {
    final text = _bulkController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please paste at least one link.")),
      );
      return;
    }

    // We navigate to Dashboard and let IT handle the detection logic for display
    // We could save it to provider as a raw string or just pass it as extra
    // Let's use a temporary field in UserEntity or just pass via extra for verification.
    // Actually, user said: "whatever link is pasted is going to appear in the user dashboard"
    // So we'll pass the raw text to the Dashboard.
    
    context.go('/dashboard', extra: text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Connect Your Socials",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black,
          onPressed: () => context.pop(), 
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Paste all your social links below:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Separate them with spaces or new lines. We'll find them for you!",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: TextField(
                  controller: _bulkController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "Enter links here...\ne.g. instagram.com/user\ntwitter.com/handle\nwa.me/numbers",
                    hintStyle: TextStyle(color: AppColors.gray300),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.primaryPurple,
                ),
                child: const Text(
                  "Continue to Dashboard",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
