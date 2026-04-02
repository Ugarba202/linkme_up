import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/user_provider.dart';
import 'package:flutter/services.dart';

class MyQRScreen extends ConsumerWidget {
  const MyQRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final username = user?.username ?? 'username';
    final profileUrl = 'linkmeup.app/$username';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B62F4)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'QR Code',
          style: TextStyle(
            color: Color(0xFF5B62F4),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Main QR Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // QR Code itself - Larger as in the design
                    QrImageView(
                      data: 'https://$profileUrl',
                      version: QrVersions.auto,
                      size: 280.0,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF5B62F4)),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF5B62F4)),
                    ),
                    const SizedBox(height: 60),
                    // Title
                    const Text(
                      'Here is your code !!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3172), // Darker Navy-Blue for headers
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      'This is your unique QR Code for another\nperson to scan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Copy Link - preserved but styled subtely
                    InkWell(
                      onTap: () {
                        final textUrl = 'https://$profileUrl';
                        Clipboard.setData(ClipboardData(text: textUrl)).then((_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Link copied to clipboard!'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color(0xFF5B62F4),
                              ),
                            );
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profileUrl,
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.copy_rounded, size: 14, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
            // Bottom Actions (Dribbble Style)
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomAction(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onPressed: () {},
                  ),
                  _buildBottomAction(
                    icon: Icons.save_alt_rounded,
                    label: 'Save',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({required IconData icon, required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF5B62F4), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5B62F4),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
