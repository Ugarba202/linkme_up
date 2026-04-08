import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/social_link_entity.dart';
import '../../../../core/themes/app_colors.dart';
import '../common/custom_input.dart';
import '../common/custom_button.dart';

class AddLinkBottomSheet extends StatefulWidget {
  final Function(SocialLinkEntity) onAdd;
  final SocialLinkEntity? editLink;

  const AddLinkBottomSheet({super.key, required this.onAdd, this.editLink});

  @override
  State<AddLinkBottomSheet> createState() => _AddLinkBottomSheetState();
}

class _AddLinkBottomSheetState extends State<AddLinkBottomSheet> {
  final TextEditingController _usernameController = TextEditingController();
  SocialPlatform _selectedPlatform = SocialPlatform.instagram;

  @override
  void initState() {
    super.initState();
    if (widget.editLink != null) {
      _usernameController.text = widget.editLink!.username;
      _selectedPlatform = widget.editLink!.platform;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_usernameController.text.isEmpty) return;
    
    final username = _usernameController.text.trim();
    final url = _selectedPlatform.constructUrl(username);
    
    final link = SocialLinkEntity(
      id: widget.editLink?.id ?? const Uuid().v4(),
      platform: _selectedPlatform,
      username: username,
      url: url,
      isVisible: widget.editLink?.isVisible ?? true,
      createdAt: widget.editLink?.createdAt ?? DateTime.now(),
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
          DropdownButtonFormField<SocialPlatform>(
            value: _selectedPlatform,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: SocialPlatform.values.map((platform) {
              return DropdownMenuItem<SocialPlatform>(
                value: platform,
                child: Row(
                  children: [
                    Icon(platform.icon, color: platform.color, size: 20),
                    const SizedBox(width: 12),
                    Text(platform.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPlatform = val;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          CustomInputField(
            controller: _usernameController,
            hintText: _selectedPlatform.handleHint,
            prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          if (_usernameController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Preview: ${_selectedPlatform.constructUrl(_usernameController.text)}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
