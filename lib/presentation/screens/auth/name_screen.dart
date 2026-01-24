import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What should we call you?",
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                "This will appear on your profile",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter your name",
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();

                  if (name.isEmpty) return;

                  // TEMP: Pass name forward (later store in state)
                  context.go('/auth/phone', extra: name);
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
