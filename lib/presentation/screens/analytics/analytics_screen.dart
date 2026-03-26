import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  Text('Total Scans', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('1,245', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 16),
                      Text(' +12% this week', style: TextStyle(color: Colors.greenAccent)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Social Interactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInteractionCard('Instagram', '643 clicks', Icons.camera_alt, Colors.pink),
            const SizedBox(height: 12),
            _buildInteractionCard('LinkedIn', '312 clicks', Icons.work, Colors.blue),
            const SizedBox(height: 12),
            _buildInteractionCard('Twitter/X', '290 clicks', Icons.alternate_email, Colors.black),
            
            const SizedBox(height: 32),
            const Text('Top Scan Locations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildLocationRow('New York, USA', '45%'),
            const SizedBox(height: 12),
            _buildLocationRow('London, UK', '25%'),
            const SizedBox(height: 12),
            _buildLocationRow('Berlin, DE', '15%'),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionCard(String platform, String stats, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: iconColor.withValues(alpha: 0.1), child: Icon(icon, color: iconColor)),
          const SizedBox(width: 16),
          Expanded(child: Text(platform, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(stats, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String location, String percentage) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(child: Text(location, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(percentage),
      ],
    );
  }
}
