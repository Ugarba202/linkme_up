import 'package:flutter/material.dart';
import 'package:linkmeup_app/core/themes/app_colors.dart';
import 'package:linkmeup_app/presentation/widgets/gradient_button.dart';

class ConnectSocialsStep extends StatelessWidget {
  final VoidCallback onFinish;

  const ConnectSocialsStep({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Connect your socials",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your links now. You can always edit these later.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildSocialTile(Icons.camera_alt_rounded, "Instagram", AppColors.instagram.colors.first),
                _buildSocialTile(Icons.audiotrack_rounded, "TikTok", AppColors.tiktokAccent),
                _buildSocialTile(Icons.work_rounded, "LinkedIn", AppColors.linkedin),
                _buildSocialTile(Icons.play_arrow_rounded, "YouTube", AppColors.youtube),
              ],
            ),
          ),
          GradientButton(
            text: "Finish Setup",
            onPressed: onFinish,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTile(IconData icon, String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const Text(
            "Connect",
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
