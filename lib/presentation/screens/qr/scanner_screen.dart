import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Scan QR Code",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
            if (barcode.rawValue != null) {
              // Stop scanning and navigate or show result
              controller.stop();

              // For now, just show a dialog or snackbar, or handle deeper logic
              // If it triggers multiple times, we need a flag or stop()
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Found: ${barcode.rawValue}")),
              );
              context.pop(); // Go back after scan
              break;
            }
          }
        },
        overlayBuilder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}
