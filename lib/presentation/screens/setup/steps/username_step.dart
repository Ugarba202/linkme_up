import 'package:flutter/material.dart';
import 'package:linkmeup_app/presentation/widgets/custom_input.dart';
import 'package:linkmeup_app/presentation/widgets/gradient_button.dart';

class UsernameStep extends StatefulWidget {
  final String initialValue;
  final Function(String) onSaved;

  const UsernameStep({super.key, required this.initialValue, required this.onSaved});

  @override
  State<UsernameStep> createState() => _UsernameStepState();
}

class _UsernameStepState extends State<UsernameStep> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose your username",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "This will be your unique @handle.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          CustomInput(
            controller: _controller,
            hintText: "alexc",
            label: "Username",
            prefixIcon: Icons.alternate_email_rounded,
          ),
          const Spacer(),
          GradientButton(
            text: "Continue",
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSaved(_controller.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}
