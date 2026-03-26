import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../domain/models/social_link_model.dart';
import '../../../../core/themes/app_colors.dart';
import '../common/custom_input.dart';
import '../common/custom_button.dart';

class AddLinkBottomSheet extends StatefulWidget {
  final Function(SocialLinkModel) onAdd;
  final SocialLinkModel? editLink;

  const AddLinkBottomSheet({super.key, required this.onAdd, this.editLink});

  @override
  State<AddLinkBottomSheet> createState() => _AddLinkBottomSheetState();
}

class _AddLinkBottomSheetState extends State<AddLinkBottomSheet> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedPlatform = 'Facebook';
  IconData _selectedIcon = Icons.facebook;

  final Map<String, IconData> _platforms = {
    'Facebook': Icons.facebook,
    'LinkedIn': FontAwesomeIcons.linkedin,
    'Twitter / X': FontAwesomeIcons.xTwitter,
    'Instagram': FontAwesomeIcons.instagram,
    'TikTok': FontAwesomeIcons.tiktok,
    'YouTube': FontAwesomeIcons.youtube,
    'Custom Website': Icons.link,
  };

  @override
  void initState() {
    super.initState();
    if (widget.editLink != null) {
      _urlController.text = widget.editLink!.urlOrUsername;
      _selectedPlatform = widget.editLink!.platformName;
      _selectedIcon = widget.editLink!.icon;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _save() {
    if (_urlController.text.isEmpty) return;
    
    final link = SocialLinkModel(
      id: widget.editLink?.id ?? const Uuid().v4(),
      platformName: _selectedPlatform,
      urlOrUsername: _urlController.text,
      icon: _selectedIcon,
      isVisible: widget.editLink?.isVisible ?? true,
    );
    
    widget.onAdd(link);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.editLink != null ? 'Edit Link' : 'Add New Link',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _selectedPlatform,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _platforms.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    Icon(entry.value, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(entry.key),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPlatform = val;
                  _selectedIcon = _platforms[val]!;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          CustomInputField(
            controller: _urlController,
            hintText: 'Username or URL',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: widget.editLink != null ? 'Update' : 'Save Link',
            onPressed: _save,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
