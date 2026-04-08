import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../application/providers/user_provider.dart';
import 'package:flutter/services.dart';

class MyQRScreen extends ConsumerStatefulWidget {
  const MyQRScreen({super.key});

  @override
  ConsumerState<MyQRScreen> createState() => _MyQRScreenState();
}

class _MyQRScreenState extends ConsumerState<MyQRScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareQR(String profileUrl) async {
    try {
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/linkmeup_qr.png').create();
        await imagePath.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath.path)], 
          text: 'Scan this code to connect with me on LinkMeUp!\nhttps://$profileUrl',
          subject: 'My LinkMeUp QR Code',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing QR: $e')),
        );
      }
    }
  }

  Future<void> _saveQR() async {
    try {
      // Permission Handling
      if (Platform.isAndroid) {
        // Android 13+ doesn't need manual permission for Gal usually, 
        // but for safety we check photos
        final status = await Permission.photos.request();
        if (!status.isGranted && !status.isLimited) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission denied to save photos.')),
            );
          }
          return;
        }
      }

      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
      );
      
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/qr_to_save.png').create();
        await imagePath.writeAsBytes(image);
        
        await Gal.putImage(imagePath.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code saved to gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving QR: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Main QR Section (Captured for sharing)
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // QR Code itself
                    QrImageView(
                      data: 'https://$profileUrl',
                      version: QrVersions.auto,
                      size: 280.0,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF5B62F4)),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF5B62F4)),
                    ),
                    const SizedBox(height: 40),
                    // Title
                    const Text(
                      'Here is your code !!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3172), 
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      'Scan this unique QR Code to view\nmy full digital identity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Copy Link - styled subtely
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
            const Spacer(flex: 2),
            // Bottom Actions
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomAction(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onPressed: () => _shareQR(profileUrl),
                  ),
                  _buildBottomAction(
                    icon: Icons.save_alt_rounded,
                    label: 'Save',
                    onPressed: _saveQR,
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
