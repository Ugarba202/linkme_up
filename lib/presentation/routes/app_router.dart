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
import '../screens/dashboard/notification_screen.dart';
import '../../application/providers/auth_providers.dart';
import '../../application/providers/user_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth and user changes to re-trigger redirect if needed
  // (In more complex apps, we'd use a Listenable, but for now we'll rely on the manual navigation from nodes)
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final authRepository = ref.read(authRepositoryProvider);
      final user = ref.read(userProvider);
      final userId = authRepository.currentUserId;
      
      final isSplashing = state.uri.path == '/';
      final isOnboarding = state.uri.path == '/onboarding';
      final isAuth = state.uri.path == '/auth';
      final isPublicProfile = state.uri.path.startsWith('/profile/') || state.uri.path.length > 1 && !state.uri.path.contains('/', 1);

      // If we are on public profile, don't redirect
      if (isPublicProfile) return null;

      // If not authenticated, only allow Splash or Onboarding or Auth
      if (userId == null) {
        if (isSplashing || isOnboarding || isAuth) return null;
        return '/onboarding';
      }

      // If authenticated but profile not complete
      if (user != null && !user.profileCompleted) {
        if (state.uri.path == '/setup') return null;
        return '/setup';
      }

      // If authenticated and profile complete, but trying to go to auth/onboarding
      if (user != null && user.profileCompleted) {
        if (isSplashing || isOnboarding || isAuth || state.uri.path == '/setup') {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
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
      GoRoute(
        path: '/:username',
        builder: (context, state) {
          final username = state.pathParameters['username'];
          return PublicProfileScreen(username: username);
        },
      ),
    ],
  );
});
