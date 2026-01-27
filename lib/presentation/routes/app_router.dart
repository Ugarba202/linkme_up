import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/name_screen.dart';
import '../screens/auth/email_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/username_screen.dart';

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
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

      // Onboarding
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),

      // Auth Flow
      GoRoute(path: '/auth/name', builder: (context, state) => const NameScreen()),
      GoRoute(
        path: '/auth/email',
        builder: (context, state) {
          final name = state.extra as String? ?? "User";
          return EmailScreen(userName: name);
        },
      ),
      GoRoute(path: '/auth/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/auth/username', builder: (context, state) => const UsernameScreen()),

      // Profile Setup (Section 3)
      GoRoute(path: '/profile/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/profile/add-socials', builder: (context, state) => const AddSocialsScreen()),

      // Dashboard (Section 4)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // QR (Section 5)
      GoRoute(path: '/qr', builder: (context, state) => const QrScreen()),
      GoRoute(path: '/qr/full', builder: (context, state) => const FullQrScreen()),

      // Profile & Settings (Section 6)
      GoRoute(path: '/profile/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/profile/manage-socials', builder: (context, state) => const ManageSocialsScreen()),
    ],
  );
});
