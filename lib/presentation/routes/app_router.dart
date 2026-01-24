import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

// Auth Provider

final routerProvider = Provider<GoRouter>((ref) {
  // final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',

    routes: [
      // Splash
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Auth Flow
      // GoRoute(
      //   path: '/auth/name',
      //   builder: (_, __) => const NameScreen(),
      // ),

      // GoRoute(
      //   path: '/auth/phone',
      //   builder: (_, __) => const PhoneScreen(),
      // ),

      // GoRoute(
      //   path: '/auth/otp',
      //   builder: (_, __) => const OtpScreen(),
      // ),

      // TODO (Next Sprints)
      // /setup
      // /home
      // /qr
      // /profile
    ],

    // redirect: (context, state) {
    //   final isLoggedIn = authState.value ?? false;
    //
    //   final isAuthRoute =
    //       state.fullPath!.startsWith('/auth');
    //
    //   // If logged in, block auth pages
    //   if (isLoggedIn && isAuthRoute) {
    //     return '/home';
    //   }
    //
    //   return null;
    // },
  );
});
