import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/entities/social_link_entity.dart';
import '../../widgets/setup/add_link_bottom_sheet.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final bool isFromSetup;
  final bool isTab;
  const EditProfileScreen({super.key, this.isFromSetup = false, this.isTab = false});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController;
  late List<SocialLinkEntity> _socialLinks;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _displayNameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    
    // Initialize social platforms from global state
    _socialLinks = List<SocialLinkEntity>.from(user?.socialLinks ?? []);
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
    await notifier.updateSocialLinks(_socialLinks);
    
    if (mounted) {
      if (widget.isTab) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: (widget.isFromSetup || widget.isTab) ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
                      image: user?.photoBytes != null 
                        ? DecorationImage(image: MemoryImage(user!.photoBytes!), fit: BoxFit.cover)
                        : user?.photoUrl != null
                          ? DecorationImage(image: NetworkImage(user!.photoUrl!), fit: BoxFit.cover)
                          : const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  if (user?.photoBytes == null && user?.photoUrl == null)
                    const Icon(Icons.person_rounded, size: 40, color: Colors.grey),
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
              hintText: 'linkmeup-95263.web.app/arivera',
              readOnly: true,
              suffixIcon: Icon(Icons.lock_rounded, size: 18, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 40),
            const SizedBox(height: 24),
            _buildSectionLabel('CONNECTED PLATFORMS'),
            const SizedBox(height: 16),
            ...List.generate(_socialLinks.length, (index) {
              final item = _socialLinks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSocialItem(
                  index: index,
                  icon: item.platform.icon,
                  name: item.platform.displayName,
                  handle: item.username,
                  color: item.platform.color,
                  isVisible: item.isVisible,
                ),
              );
            }),
            const SizedBox(height: 24),
            _buildAddAccountButton(),
            const SizedBox(height: 48),
            _buildSectionLabel('JOIN OUR COMMUNITY'),
            const SizedBox(height: 16),
            _buildCommunityTile(
              icon: Icons.alternate_email_rounded,
              title: 'Follow us on X (Twitter)',
              subtitle: 'Stay updated with the latest features',
              color: Colors.black87,
              onTap: () => _launchUrl('https://x.com/linkmeupapp'),
            ),
            const SizedBox(height: 12),
            _buildCommunityTile(
              icon: Icons.chat_bubble_rounded,
              title: 'Join our WhatsApp Channel',
              subtitle: 'Be part of the LinkMeUp community',
              color: const Color(0xFF25D366),
              onTap: () => _launchUrl('https://whatsapp.com/channel/0029Vb7vDTVGU3BCU3VVXi1j'),
            ),
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
    required bool isVisible,
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
            value: isVisible,
            onChanged: (val) {
              setState(() {
                _socialLinks[index] = _socialLinks[index].copyWith(isVisible: val);
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 22),
            onPressed: () {
              setState(() {
                _socialLinks.removeAt(index);
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
        onPressed: () => _showAddSocialBottomSheet(),
        icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.primary),
        label: const Text(
          'Add Account',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showAddSocialBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLinkBottomSheet(
        onAdd: (newLink) {
          setState(() {
            _socialLinks.add(newLink);
          });
        },
      ),
    );
  }

  Widget _buildDeleteAccountSection() {
    return Column(
      children: [
        TextButton(
          onPressed: () => _showDeleteConfirmation(context),
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

  Widget _buildCommunityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: color.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action is permanent and will remove all your data, social links, and analytics. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(userProvider.notifier).deleteAccount();
              if (mounted) context.go('/auth');
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
