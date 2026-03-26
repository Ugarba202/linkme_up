import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../widgets/common/custom_input.dart';
import '../../widgets/common/custom_button.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_a_photo, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const CustomInputField(hintText: 'Display Name'),
            const SizedBox(height: 16),
            const CustomInputField(hintText: 'Bio'),
            const SizedBox(height: 16),
            const CustomInputField(hintText: 'Job Title / Role'),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'Save Changes',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
