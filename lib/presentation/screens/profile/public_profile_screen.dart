import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: brandPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'LinkQR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Card
              _buildProfileCard(),
              const SizedBox(height: 24),
              // Social Links
              _buildSocialLinksList(),
              const SizedBox(height: 32),
              // Footer Button
              _buildFooterAction(context),
              const SizedBox(height: 16),
              Text(
                'POWERED BY LINKQR',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          // Avatar with Status
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade100, width: 1),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400'),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Alex Harrison',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '@ALEXC',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Digital designer and urban explorer. Let\'s connect through tech and art.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksList() {
    return Column(
      children: [
        _buildSocialTile(
          icon: Icons.camera_alt_rounded,
          name: 'INSTAGRAM',
          handle: '@alexharrison.design',
          color: Colors.pink,
        ),
        const SizedBox(height: 12),
        _buildSocialTile(
          icon: Icons.video_library_rounded,
          name: 'TIKTOK',
          handle: '@alexc_visuals',
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        _buildSocialTile(
          icon: Icons.close_rounded,
          name: 'TWITTER / X',
          handle: '@alexh_dev',
          color: Colors.black87,
        ),
        const SizedBox(height: 12),
        _buildSocialTile(
          icon: Icons.play_circle_fill_rounded,
          name: 'YOUTUBE',
          handle: 'Alex Harrison Design',
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _buildSocialTile(
          icon: Icons.work_rounded,
          name: 'LINKEDIN',
          handle: 'in/alexharrison',
          color: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildSocialTile({
    required IconData icon,
    required String name,
    required String handle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  handle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.north_east_rounded, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Widget _buildFooterAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/auth'),
        icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF6366F1)),
        label: const Text(
          'Create your own free QR',
          style: TextStyle(
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
