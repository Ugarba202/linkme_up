// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../screens/splash/splash_screen.dart';
// import '../screens/onboarding/onboarding_screen.dart';
// import '../screens/auth/phone_screen.dart';
// import '../../application/providers/auth_provider.dart';

// final routerProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authStateProvider);

//   return GoRouter(
//     initialLocation: '/splash',
//     routes: [
//       GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
//       GoRoute(
//         path: '/onboarding',
//         builder: (_, __) => const OnboardingScreen(),
//       ),
//       GoRoute(path: '/auth', builder: (_, __) => PhoneScreen()),
//     ],
//     redirect: (_, __) {
//       final loggedIn = authState.value ?? false;

//       if (loggedIn) {
//         return '/home';
//       }

//       return null;
//     },
//   );
// });
