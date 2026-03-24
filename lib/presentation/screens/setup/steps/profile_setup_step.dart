import 'package:flutter/material.dart';
import 'package:linkmeup_app/core/themes/app_colors.dart';
import 'package:linkmeup_app/presentation/widgets/custom_input.dart';
import 'package:linkmeup_app/presentation/widgets/gradient_button.dart';

class ProfileSetupStep extends StatefulWidget {
  final String initialName;
  final String initialBio;
  final Function(String, String) onSaved;

  const ProfileSetupStep({super.key, required this.initialName, required this.initialBio, required this.onSaved});

  @override
  State<ProfileSetupStep> createState() => _ProfileSetupStepState();
}

class _ProfileSetupStepState extends State<ProfileSetupStep> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Setup your profile",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "Add a photo, name, and bio to help people recognize you.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.gray200,
                  child: const Icon(Icons.person, size: 50, color: AppColors.gray400),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CustomInput(
            controller: _nameController,
            hintText: "Alex Carter",
            label: "Display Name",
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: _bioController,
            hintText: "Digital creator & dev...",
            label: "Bio",
            maxLines: 3,
          ),
          const Spacer(),
          GradientButton(
            text: "Continue",
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                widget.onSaved(_nameController.text.trim(), _bioController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}
