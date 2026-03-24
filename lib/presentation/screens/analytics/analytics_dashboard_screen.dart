import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linkmeup_app/core/themes/app_colors.dart';
import 'package:linkmeup_app/presentation/widgets/metric_card.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Analytics",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: const MetricCard(
                    title: "Total Scans",
                    value: "1,248",
                    change: "+12.5%",
                    isPositive: true,
                    icon: Icons.qr_code_scanner_rounded,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: const MetricCard(
                    title: "New Links",
                    value: "342",
                    change: "+5.2%",
                    isPositive: true,
                    icon: Icons.person_add_rounded,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              "Activity Over Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            _buildBarChart().animate().fadeIn(delay: 400.ms).scale(duration: 400.ms),
            const SizedBox(height: 32),
            const Text(
              "Top Regions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 450.ms),
            const SizedBox(height: 16),
            _buildMapPlaceholder().animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 16),
            _buildActivityList().animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final data = [4, 8, 3, 10, 6, 12, 5];
    final maxData = 12;
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          final heightFactor = data[index] / maxData;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: 130 * heightFactor,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.map_rounded, size: 80, color: AppColors.primaryPurple.withValues(alpha: 0.2)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ]
            ),
            child: const Text(
              "Top Location: New York, USA", 
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          _buildActivityTile("Scanned by @alex", "Just now", Icons.qr_code_rounded),
          Divider(color: AppColors.gray200, height: 1),
          _buildActivityTile("New connection: @sarah_v", "2 hrs ago", Icons.group_add_rounded),
          Divider(color: AppColors.gray200, height: 1),
          _buildActivityTile("Profile viewed in London", "5 hrs ago", Icons.public_rounded),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String title, String time, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    );
  }
}
