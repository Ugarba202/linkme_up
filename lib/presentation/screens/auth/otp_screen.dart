import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class OtpScreen extends ConsumerWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController otpController = TextEditingController();
    final repo =
        ref.read(authRepositoryProvider) as FirebaseAuthRepository;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verify your number",
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                "Enter the 6-digit code sent to you",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "123456",
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  await repo.verifyOtp(
                    verificationId: repo.verificationId!,
                    smsCode: otpController.text.trim(),
                  );
                },
                child: const Text("Verify"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
