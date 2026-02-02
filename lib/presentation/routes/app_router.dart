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
import '../screens/auth/verification_screen.dart';
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

// New Screens
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/external_profile_screen.dart';
import '../screens/profile/profile_landing_screen.dart';

// Domain
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/social_link_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Flow
      GoRoute(
        path: '/auth/name',
        builder: (context, state) => const NameScreen(),
      ),
      GoRoute(
        path: '/auth/email',
        builder: (context, state) {
          final name = state.extra as String? ?? "User";
          return EmailScreen(userName: name);
        },
      ),
      GoRoute(
        path: '/auth/verify',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/auth/username',
        builder: (context, state) => const UsernameScreen(),
      ),

      // Profile Setup
      GoRoute(
        path: '/profile/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/profile/add-socials',
        builder: (context, state) => const AddSocialsScreen(),
      ),

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
                    parentNavigatorKey:
                        rootNavigatorKey, // Open full screen on top
                    builder: (context, state) => const FullQrScreen(),
                  ),
                  GoRoute(
                    path: 'scan',
                    parentNavigatorKey:
                        rootNavigatorKey, // Open scanner on top (hide nav bar)
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

      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // External Profile (View scanned user)
      GoRoute(
        path: '/profile/:username',
        builder: (context, state) {
          final username = state.pathParameters['username'] ?? 'user';
          // Mock data for demonstration if no extra passed
          final user =
              state.extra as UserEntity? ??
              UserEntity(
                uid: 'scanned_user_123',
                name: 'Scanned User',
                username: username,
                email: 'scanned@example.com',
                phoneNumber: '+2348000000001',
                country: 'Nigeria',
                photoUrl: 'https://api.dicebear.com/9.x/avataaars/png?seed=$username',
                bannerUrl: 'https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2000', // Premium gradient-like banner
                bio: 'Tech enthusiast, digital nomad, and coffee lover. Let\'s connect and build something amazing together! 🚀☕️',
                socialLinks: [
                  SocialLinkEntity(
                    id: 's1',
                    platform: SocialPlatform.instagram,
                    username: 'uceeee',
                    url: 'https://instagram.com/uceeee',
                  ),
                  SocialLinkEntity(
                    id: 's2',
                    platform: SocialPlatform.twitter,
                    username: 'uceeee',
                    url: 'https://twitter.com/uceeee',
                  ),
                ],
                createdAt: DateTime.now(),
              );
          return ExternalProfileScreen(user: user);
        },
      ),

      // Landing Page (Web simulation)
      GoRoute(
        path: '/landing/:username',
        builder: (context, state) {
          final username = state.pathParameters['username'] ?? 'user';
          final user =
              state.extra as UserEntity? ??
              UserEntity(
                uid: 'landing_123',
                name: 'Web User',
                username: username,
                email: 'web@example.com',
                phoneNumber: '',
                country: 'Nigeria',
                photoUrl: 'https://api.dicebear.com/9.x/avataaars/png?seed=$username',
                bannerUrl: 'https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2000',
                bio: 'Welcome to my official LinkMeUp profile! Check out my socials below and let\'s stay in touch.',
                socialLinks: [
                  SocialLinkEntity(
                    id: 'w1',
                    platform: SocialPlatform.linkedin,
                    username: 'webuser',
                    url: 'https://linkedin.com',
                  ),
                ],
                createdAt: DateTime.now(),
              );
          return ProfileLandingScreen(user: user);
        },
      ),

      // Compatibility Redirects or Global Routes if needed
      GoRoute(
        path: '/profile/manage-socials',
        redirect: (_, __) => '/profile/settings/manage-socials',
      ), // Redirect old path
    ],
  );
});
