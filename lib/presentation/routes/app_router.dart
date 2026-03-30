import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/setup/setup_wizard.dart';
import '../screens/main_wrapper.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/public_profile_screen.dart';
import '../screens/scanner/qr_scanner_screen.dart';
import '../screens/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) {
          final step = int.tryParse(state.uri.queryParameters['step'] ?? '0') ?? 0;
          return SetupWizardScreen(initialStep: step);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainWrapperScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/qr/scan',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/profile/:username',
        builder: (context, state) {
          final username = state.pathParameters['username'];
          return PublicProfileScreen(username: username);
        },
      ),
      GoRoute(
        path: '/profile/id/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'];
          return PublicProfileScreen(uid: uid);
        },
      ),
    ],
  );
});
