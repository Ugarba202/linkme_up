import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/name_screen.dart';
import '../screens/auth/phone_screen.dart';
import '../screens/auth/otp_screen.dart';

// Profile Screens
import '../screens/profile/welcome_screen.dart';
import '../screens/profile/add_socials_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/manage_socials_screen.dart';

// Dashboard
import '../screens/dashboard/dashboard_screen.dart';

// QR
import '../screens/qr/qr_screen.dart';
import '../screens/qr/full_qr_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

      // Onboarding
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

      // Auth Flow
      GoRoute(path: '/auth/name', builder: (_, __) => const NameScreen()),
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) {
          final name = state.extra as String? ?? "User";
          return PhoneScreen(userName: name);
        },
      ),
      GoRoute(path: '/auth/otp', builder: (_, __) => const OtpScreen()),

      // Profile Setup (Section 3)
      GoRoute(path: '/profile/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/profile/add-socials', builder: (_, __) => const AddSocialsScreen()),

      // Dashboard (Section 4)
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),

      // QR (Section 5)
      GoRoute(path: '/qr', builder: (_, __) => const QrScreen()),
      GoRoute(path: '/qr/full', builder: (_, __) => const FullQrScreen()),

      // Profile & Settings (Section 6)
      GoRoute(path: '/profile/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/profile/manage-socials', builder: (_, __) => const ManageSocialsScreen()),
    ],
  );
});
