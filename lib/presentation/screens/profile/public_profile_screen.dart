import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/entities/user_entity.dart';
import '../../widgets/common/shimmer_loading.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String? username;
  final String? uid;
  
  const PublicProfileScreen({
    super.key, 
    this.username,
    this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brandPurple = Color(0xFF6366F1);
    
    final asyncProfile = username != null 
      ? ref.watch(publicProfileByUsernameProvider(username!.replaceAll('@', '')))
      : ref.watch(publicProfileByUidProvider(uid!));

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
          'LinkMeUp',
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
      body: asyncProfile.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Profile not found', style: TextStyle(color: Colors.white)));
          }
          // Trigger view analytics
          WidgetsBinding.instance.addPostFrameCallback((_) {
             ref.read(userRepositoryProvider).incrementViews(user.uid);
          });
          
          return _buildProfileContent(context, ref, user);
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(40.0),
          child: ShimmerProfileSkeleton(),
        ),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserEntity user) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Card
            _buildProfileCard(user),
            const SizedBox(height: 24),
            // Social Links
            _buildSocialLinksList(context, ref, user),
            const SizedBox(height: 32),
            // Footer Button
            _buildFooterAction(context),
            const SizedBox(height: 16),
            Text(
              'POWERED BY LINKMEUP',
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
  ),
);
  }

  Widget _buildProfileCard(UserEntity user) {
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
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.photoUrl != null 
                    ? NetworkImage(user.photoUrl!) 
                    : null,
                  child: user.photoUrl == null 
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
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
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (user.username != null && user.username!.isNotEmpty)
            Text(
              '@${user.username!.toUpperCase()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            user.bio.isEmpty ? 'Digital identity explorer.' : user.bio,
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

  Widget _buildSocialLinksList(BuildContext context, WidgetRef ref, UserEntity user) {
    return Column(
      children: user.socialLinks.where((l) => l.isVisible).map((link) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSocialTile(
            context,
            ref,
            uid: user.uid,
            icon: link.platform.icon,
            name: link.platform.displayName,
            handle: link.username,
            color: link.platform.color,
            url: link.url,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSocialTile(
    BuildContext context,
    WidgetRef ref, {
    required String uid,
    required IconData icon,
    required String name,
    required String handle,
    required Color color,
    required String url,
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
      child: InkWell(
        onTap: () async {
          // Log click analytics
          ref.read(userRepositoryProvider).incrementClicks(uid);
          
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open $url')),
              );
            }
          }
        },
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
                    name.toUpperCase(),
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
