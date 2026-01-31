import 'package:flutter/material.dart';

class AppColors {
  // ===========================================================================
  // BRAND IDENTITY
  // ===========================================================================
  
  // Primary Colors
  static const Color primaryPurple = Color(0xFF8B5CF6); // Vibrant Purple
  static const Color primaryBlue = Color(0xFF3B82F6);   // Tech Blue

  // Main Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(135 * 3.14159 / 180), // 135 deg approx
  );

  // Accent Colors
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentAmber = Color(0xFFF59E0B);

  // ===========================================================================
  // NEUTRAL COLORS (UI Foundation)
  // ===========================================================================
  
  // Light Mode
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC);  // Backgrounds (Slate 50)
  static const Color gray100 = Color(0xFFF1F5F9); // Secondary (Slate 100)
  static const Color gray200 = Color(0xFFE2E8F0); // Borders/Dividers (Slate 200)
  static const Color gray300 = Color(0xFFCBD5E1); // Disabled (Slate 300)
  static const Color gray400 = Color(0xFF94A3B8); // Placeholder (Slate 400)
  static const Color gray500 = Color(0xFF64748B); // Secondary text (Slate 500)
  static const Color gray600 = Color(0xFF475569); // Body text (Slate 600)
  static const Color gray700 = Color(0xFF334155); // Headings (Slate 700)
  static const Color gray800 = Color(0xFF1E293B); // Dark headings (Slate 800)
  static const Color gray900 = Color(0xFF0F172A); // Max contrast (Slate 900)

  // Dark Mode
  static const Color darkBg = Color(0xFF0F172A);      // Main Background
  static const Color darkSurface = Color(0xFF1E293B); // Surface/Card
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkText = Color(0xFFF8FAFC);

  // Glass Utilities
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% White
  static const Color glassBlack = Color(0x1A000000); // 10% Black
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% White for borders

  // ... (Keep Semantic Colors ...)

  // ===========================================================================
  // SEMANTIC COLORS (Feedback)
  // ===========================================================================

  // Success
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);

  // Warning
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);

  // Error
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);

  // Info
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);

  // ... (Keep Social Media Colors ...)
  
  static const Color tiktok = Color(0xFF000000);
  static const Color tiktokAccent = Color(0xFFFE2C55);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color snapchat = Color(0xFFFFFC00);
  static const Color youtube = Color(0xFFFF0000);
  static const Color facebook = Color(0xFF1877F2);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color discord = Color(0xFF5865F2);
  static const Color pinterest = Color(0xFFE60023);
  static const Color reddit = Color(0xFFFF4500);
  static const Color telegram = Color(0xFF0088CC);

  static const Gradient instagram = LinearGradient(
    colors: [
      Color(0xFFF09433),
      Color(0xFFE6683C),
      Color(0xFFDC2743),
      Color(0xFFCC2366),
      Color(0xFFBC1888),
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  // ===========================================================================
  // APP COMPATIBILITY ALIASES
  // ===========================================================================

  static const Color primary = primaryPurple;
  static const Color primaryLight = Color(0xFFA78BFA); 
  static const Color primarySoft = Color(0xFFF5F3FF);

  static const Color background = gray50;
  static const Color surface = white;
  
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textMuted = gray400;

  static const Color border = gray200;
}
