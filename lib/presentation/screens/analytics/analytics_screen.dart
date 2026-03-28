import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Insights', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Large Stat Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B62F4), Color(0xFF8187F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B62F4).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL PASS SCANS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1,245',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '+12% this week',
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Social Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 20),
            _buildInteractionCard('Instagram', '643 taps', Icons.camera_alt_rounded, Colors.pink),
            const SizedBox(height: 12),
            _buildInteractionCard('TikTok', '412 taps', Icons.music_note_rounded, Colors.black),
            const SizedBox(height: 12),
            _buildInteractionCard('LinkedIn', '312 taps', Icons.work_rounded, Colors.blue),
            
            const SizedBox(height: 40),
            const Text(
              'Top Locations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            _buildLocationRow('New York, USA', '45%', 0.45),
            const SizedBox(height: 16),
            _buildLocationRow('London, UK', '25%', 0.25),
            const SizedBox(height: 16),
            _buildLocationRow('Berlin, DE', '15%', 0.15),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionCard(String platform, String stats, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              platform,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            stats,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String location, String percentage, double value) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: Color(0xFF5B62F4), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                location,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Text(
              percentage,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B62F4)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
