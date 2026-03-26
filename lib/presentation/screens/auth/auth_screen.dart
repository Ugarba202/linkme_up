import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/auth_providers.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF5B62F4);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'LinkQR',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Join LinkQR',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Elevate your digital presence.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Central World Map Asset Graphic
              const Center(child: _WorldMapGraphic()),
              const Spacer(),
              // Social Login Buttons
              _SocialButton(
                icon: FontAwesomeIcons.apple,
                text: 'Continue with Apple',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: () => _handleAuth(context, ref),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: FontAwesomeIcons.google,
                text: 'Continue with Google',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                borderColor: Colors.grey.shade300,
                onPressed: () => _handleAuth(context, ref),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: Icons.phone_android,
                text: 'Continue with Phone',
                backgroundColor: primaryColor,
                textColor: Colors.white,
                onPressed: () => _handleAuth(context, ref),
              ),
              const SizedBox(height: 24),
              const Center(child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12))),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _handleAuth(context, ref),
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAuth(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
      if (context.mounted) {
        context.go('/setup');
      }
    } catch (_) {
      // Handle error
    }
  }
}

class _WorldMapGraphic extends StatelessWidget {
  const _WorldMapGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated World Map lines
          CustomPaint(
            size: const Size(200, 120),
            painter: _MapPainter(),
          ),
          // Floating QR Card
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
                ],
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, color: Colors.black, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw some random map-like dots or grid
    for (var i = 1; i < 10; i++) {
      canvas.drawLine(Offset(0, size.height * (i / 10)), Offset(size.width, size.height * (i / 10)), paint);
      canvas.drawLine(Offset(size.width * (i / 10), 0), Offset(size.width * (i / 10), size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
