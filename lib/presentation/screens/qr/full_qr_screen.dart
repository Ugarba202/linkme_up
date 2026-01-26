import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../application/providers/user_provider.dart';


class FullQrScreen extends ConsumerWidget {
  const FullQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final username = user?.name ?? "User";
    final shareUrl = "https://linkup.to/${username.replaceAll(' ', '').toLowerCase()}";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Very dark blue/black
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
              ),
            ),
            const Spacer(),
            
            // Central QR
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: QrImageView(
                data: shareUrl,
                version: QrVersions.auto,
                size: 300.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Colors.black,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            Text(
              username,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Scan to connect with me",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const Spacer(flex: 2),
            
            const Text(
              "Keep this screen open for others to scan",
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
