import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/glass_container.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Screen Scanner
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  controller.stop();
                  final String code = barcode.rawValue!;
                  
                  // Simple logic: extract username from linkmeup urls
                  String username = 'user';
                  if (code.contains('linkmeup.ugarba/')) {
                    username = code.split('/').last;
                  }

                  // Navigate to external profile
                  context.pushReplacement('/profile/$username');
                  break;
                }
              }
            },
          ),
          
          // Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(
              borderColor: AppColors.primaryPurple,
              borderRadius: 24,
              borderLength: 40,
              borderWidth: 6,
              cutOutSize: 300,
            ),
            child: Container(),
          ),

          // Top Bar (Back Button & Title)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const Text(
                      "Scan QR Code",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance back button
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls (Torch & Switch Camera)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GlassContainer(
                width: 200,
                height: 70,
                borderRadius: 35,
                color: Colors.black.withValues(alpha: 0.4),
                blur: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, state, child) {
                         final isTorchOn = state.torchState == TorchState.on;
                         return IconButton(
                           icon: Icon(
                             isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                             color: isTorchOn ? AppColors.background : Colors.white,
                             size: 28,
                           ),
                           onPressed: () => controller.toggleTorch(),
                         );
                      },
                    ),
                    Container(width: 1, height: 30, color: Colors.white24),
                    IconButton(
                        icon: const Icon(
                          Icons.cameraswitch_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => controller.switchCamera(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double cutOutWidth = cutOutSize;
    final double cutOutHeight = cutOutSize;
    final double left = (width - cutOutWidth) / 2;
    final double top = (height - cutOutHeight) / 2;
    final double right = left + cutOutWidth;
    final double bottom = top + cutOutHeight;

    // Draw Background with hole
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cutOutWidth, cutOutHeight),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    final paintBackground = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawPath(backgroundPath, paintBackground);

    // Draw Corners
    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderWidth;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + borderLength)
        ..lineTo(left, top + borderRadius)
        ..arcToPoint(Offset(left + borderRadius, top), radius: Radius.circular(borderRadius))
        ..lineTo(left + borderLength, top),
      paintBorder,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(right - borderLength, top)
        ..lineTo(right - borderRadius, top)
        ..arcToPoint(Offset(right, top + borderRadius), radius: Radius.circular(borderRadius))
        ..lineTo(right, top + borderLength),
      paintBorder,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - borderLength)
        ..lineTo(right, bottom - borderRadius)
        ..arcToPoint(Offset(right - borderRadius, bottom), radius: Radius.circular(borderRadius))
        ..lineTo(right - borderLength, bottom),
      paintBorder,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(left + borderLength, bottom)
        ..lineTo(left + borderRadius, bottom)
        ..arcToPoint(Offset(left, bottom - borderRadius), radius: Radius.circular(borderRadius))
        ..lineTo(left, bottom - borderLength),
      paintBorder,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
