import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../application/providers/user_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanComplete = false;
  String? _scannedUsername;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanComplete) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        if (code.contains('linkmeup.app/')) {
          final username = code.split('linkmeup.app/').last.split('?').first.replaceAll('/', '');
          setState(() {
            _scannedUsername = username;
            _isScanComplete = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Camera Overlay Fill
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5B62F4).withValues(alpha: 0.2), // Subtle purple/green gradient at top? Actually let's use dark teal/green
                  Color(0xFF0F2027).withValues(alpha: 0.8), // Dark bottom
                ],
              ),
            ),
          ),

          // Scanner Frame & Controls
          SafeArea(
            child: Column(
              children: [
                // Top Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTopButton(
                        icon: Icons.close_rounded,
                        onPressed: () {
                          if (_isScanComplete) {
                            setState(() {
                               _isScanComplete = false;
                               _scannedUsername = null;
                            });
                          } else {
                            context.pop();
                          }
                        },
                      ),
                      Row(
                        children: [
                          _buildTopButton(
                            icon: Icons.flashlight_on_rounded,
                            onPressed: () => cameraController.toggleTorch(),
                          ),
                          const SizedBox(width: 12),
                          _buildTopButton(
                            icon: Icons.image_rounded,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // QR Frame
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Stack(
                          children: [
                            _buildFrameCorner(top: 0, left: 0, rotation: 0),
                            _buildFrameCorner(top: 0, right: 0, rotation: 1),
                            _buildFrameCorner(bottom: 0, left: 0, rotation: 3),
                            _buildFrameCorner(bottom: 0, right: 0, rotation: 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Point camera at a LinkMeUp code',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),

          // Floating Result Card
          if (_isScanComplete && _scannedUsername != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: _buildResultCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFrameCorner({double? top, double? bottom, double? left, double? right, required int rotation}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: RotatedBox(
        quarterTurns: rotation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: const Border(
              top: BorderSide(color: Color(0xFF4ADE80), width: 4),
              left: BorderSide(color: Color(0xFF4ADE80), width: 4),
            ),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final asyncProfile = ref.watch(publicProfileByUsernameProvider(_scannedUsername!));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: asyncProfile.when(
          data: (user) {
            if (user == null) {
               return const Center(child: Text('User not found'));
            }
            return Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                        child: user.photoUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.check, size: 8, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.bio != null && user.bio.isNotEmpty)
                        Text(
                          user.bio!,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          '@${user.username}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push('/profile/${user.username}').then((_) {
                       if (mounted) {
                          setState(() {
                             _isScanComplete = false;
                             _scannedUsername = null;
                          });
                       }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            );
          },
          loading: () => const Padding(
             padding: EdgeInsets.all(12),
             child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
          ),
          error: (err, stack) => const Center(child: Text('Error loading profile')),
        ),
      ),
    );
  }
}
