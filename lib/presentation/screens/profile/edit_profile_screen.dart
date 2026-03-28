import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/entities/social_link_entity.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController;
  late List<Map<String, dynamic>> _socialPlatforms;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _displayNameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    
    // Initialize social platforms from global state
    _socialPlatforms = (user?.socialLinks ?? []).map((link) {
      return {
        'id': link.id,
        'platform': link.platform,
        'icon': _getIconForPlatform(link.platform),
        'name': _getNameForPlatform(link.platform),
        'handle': link.username,
        'color': _getColorForPlatform(link.platform),
        'isEnabled': true, // Mock logic for enabled/disabled
      };
    }).toList();
  }

  IconData _getIconForPlatform(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram: return Icons.camera_alt_rounded;
      case SocialPlatform.linkedin: return Icons.work_rounded;
      case SocialPlatform.twitter: return Icons.alternate_email_rounded;
      case SocialPlatform.tiktok: return Icons.music_note_rounded;
      case SocialPlatform.youtube: return Icons.play_arrow_rounded;
      default: return Icons.link_rounded;
    }
  }

  String _getNameForPlatform(SocialPlatform platform) {
    return platform.name[0].toUpperCase() + platform.name.substring(1);
  }

  Color _getColorForPlatform(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram: return Colors.pink;
      case SocialPlatform.linkedin: return Colors.blue;
      case SocialPlatform.twitter: return Colors.black87;
      case SocialPlatform.tiktok: return Colors.black;
      case SocialPlatform.youtube: return Colors.red;
      default: return AppColors.primary;
    }
  }


  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final notifier = ref.read(userProvider.notifier);
    await notifier.updateName(_displayNameController.text);
    await notifier.updateBio(_bioController.text);
    await notifier.updateUsername(_usernameController.text);

    // Sync socials
    final updatedLinks = _socialPlatforms.map((item) {
      final platform = item['platform'] as SocialPlatform;
      return SocialLinkEntity(
        id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        platform: platform,
        username: item['handle'],
        url: platform.constructUrl(item['handle']),
        createdAt: DateTime.now(),
      );
    }).toList();
    
    await notifier.updateSocialLinks(updatedLinks);
    
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                        ),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildSectionLabel('DISPLAY NAME'),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _displayNameController,
              hintText: 'Alex Rivera',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel('BIO'),
                Text(
                  '${_bioController.text.length}/160',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _bioController,
              hintText: 'Tell us about yourself...',
              maxLines: 4,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 24),
            _buildSectionLabel('USERNAME'),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _usernameController,
              hintText: 'linkqr.me/arivera',
              readOnly: true,
              suffixIcon: Icon(Icons.lock_rounded, size: 18, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 40),
            const SizedBox(height: 24),
            _buildSectionLabel('CONNECTED PLATFORMS'),
            const SizedBox(height: 16),
            ...List.generate(_socialPlatforms.length, (index) {
              final item = _socialPlatforms[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSocialItem(
                  index: index,
                  icon: item['icon'],
                  name: item['name'],
                  handle: item['handle'],
                  color: item['color'],
                  isEnabled: item['isEnabled'],
                ),
              );
            }),
            const SizedBox(height: 24),
            _buildAddAccountButton(),
            const SizedBox(height: 48),
            _buildLogoutButton(),
            const SizedBox(height: 24),
            _buildDeleteAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          // Logout logic (mock)
          context.go('/auth');
        },
        icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
        label: const Text(
          'LOGOUT',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }


  Widget _buildSocialItem({
    required int index,
    required IconData icon,
    required String name,
    required String handle,
    required Color color,
    required bool isEnabled,
  }) {
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
          Icon(Icons.drag_indicator_rounded, color: Colors.grey.shade300),
          const SizedBox(width: 8),
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(handle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (val) {
              setState(() {
                _socialPlatforms[index]['isEnabled'] = val;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 22),
            onPressed: () {
              setState(() {
                _socialPlatforms.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
          style: BorderStyle.solid, // Dash effect in Flutter is tricky, solid for now
        ),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.primary),
        label: const Text(
          'Add Account',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountSection() {
    return Column(
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'DELETE ACCOUNT',
            style: TextStyle(color: Color(0xFFD32D41), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Text(
          'This action is permanent and will remove\nall your QR data.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF1F4FF), // Light lavender tint from design
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        ),
      ),
    );
  }
}
