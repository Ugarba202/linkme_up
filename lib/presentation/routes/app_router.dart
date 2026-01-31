import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/main_wrapper.dart';

// Auth Flow
import '../screens/auth/name_screen.dart';
import '../screens/auth/email_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/username_screen.dart';

// Profile Setup
import '../screens/profile/welcome_screen.dart';
import '../screens/profile/add_socials_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/manage_socials_screen.dart';

// Dashboard
import '../screens/dashboard/dashboard_screen.dart';

// QR
import '../screens/qr/qr_screen.dart';
import '../screens/qr/full_qr_screen.dart';
import '../screens/qr/scanner_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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

      // Profile Setup
      GoRoute(path: '/profile/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/profile/add-socials', builder: (context, state) => const AddSocialsScreen()),

      // Main Navigation with Bottom Bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) {
                  final rawLinks = state.extra as String?;
                  return DashboardScreen(rawLinks: rawLinks);
                },
              ),
            ],
          ),
          
          // Branch 2: QR
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/qr',
                builder: (context, state) => const QrScreen(),
                routes: [
                   GoRoute(
                    path: 'full',
                    parentNavigatorKey: rootNavigatorKey, // Open full screen on top
                    builder: (context, state) => const FullQrScreen(),
                  ),
                  GoRoute(
                    path: 'scan',
                    parentNavigatorKey: rootNavigatorKey, // Open scanner on top (hide nav bar)
                    builder: (context, state) => const ScannerScreen(),
                  ),
                ],
              ),
            ],
          ),
          
          // Branch 3: Profile/Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'manage-socials', // /profile/settings/manage-socials
                    builder: (context, state) => const ManageSocialsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Compatibility Redirects or Global Routes if needed
      GoRoute(path: '/profile/manage-socials', redirect: (_, __) => '/profile/settings/manage-socials'), // Redirect old path
    ],
  );
});
