import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';



class PhoneScreen extends ConsumerWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your phone number",
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                "We’ll send you a verification code",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "+234 812 345 6789",
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  final phone = phoneController.text.trim();

                  if (phone.isEmpty) return;

                  await ref
                      .read(authRepositoryProvider)
                      .sendOtp(phone);

                  context.go('/auth/otp');
                },
                child: const Text("Continue"),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text("← Go back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
