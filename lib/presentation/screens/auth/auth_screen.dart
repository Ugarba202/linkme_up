import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_button.dart';
import '../../../application/providers/auth_providers.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/error/error_handling.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                'Let\'s get started',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Create your professional digital card\nin just a few steps.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              // Modern Minimalist Graphic
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Primary Action: Continue as Guest
              PrimaryButton(
                text: 'Continue as Guest',
                isLoading: _isLoading,
                onPressed: () => _handleAuth(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAuth(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final uid = await ref.read(authRepositoryProvider).signInAnonymously();
      
      if (uid != null) {
        final existingUser = await ref.read(userRepositoryProvider).getUser(uid);
        
        if (existingUser != null) {
          // User already has a profile
          ref.read(userProvider.notifier).setUserLocal(existingUser);
          if (mounted) {
            context.go(existingUser.profileCompleted ? '/home' : '/setup');
          }
        } else {
          // Initialize fresh user profile
          final newUser = UserEntity(
            uid: uid,
            name: 'Anonymous User',
            createdAt: DateTime.now(),
          );
          
          await ref.read(userProvider.notifier).setUser(newUser);
          
          if (mounted) {
            context.go('/setup');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        GlobalErrorHandler.handleError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
