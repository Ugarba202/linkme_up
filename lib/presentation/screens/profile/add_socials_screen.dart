import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../application/providers/user_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/social_link_entity.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';

class AddSocialsScreen extends ConsumerStatefulWidget {
  const AddSocialsScreen({super.key});

  @override
  ConsumerState<AddSocialsScreen> createState() => _AddSocialsScreenState();
}

class _AddSocialsScreenState extends ConsumerState<AddSocialsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isProcessing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SocialPlatform> get _filteredPlatforms {
    final allPlatforms = SocialPlatform.values.where((p) => p != SocialPlatform.other).toList();
    if (_searchQuery.isEmpty) return allPlatforms;
    return allPlatforms.where((p) => p.displayName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _showHandleEntry(SocialPlatform platform) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HandleEntrySheet(
        platform: platform,
        onAdd: (handle) => _handleAddHandle(platform, handle),
      ),
    );
  }

  Future<void> _handleAddHandle(SocialPlatform platform, String handle) async {
    final url = platform.constructUrl(handle);
    
    setState(() => _isProcessing = true);

    try {
      final link = SocialLinkEntity(
        id: '', // Backend generates ID
        platform: platform,
        username: handle,
        url: url,
        createdAt: DateTime.now(),
      );

      await ref.read(userProvider.notifier).addSocialLink(link);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Added ${platform.displayName} link!")),
        );
        // We stay on this screen to allow adding more, or we can go back?
        // User said "add all in the same app", suggesting a workflow.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Select Platform"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomInput(
              controller: _searchController,
              hintText: "Search platforms...",
              label: "",
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: _filteredPlatforms.length,
              itemBuilder: (context, index) {
                final platform = _filteredPlatforms[index];
                return _PlatformTile(
                  platform: platform,
                  onTap: () => _showHandleEntry(platform),
                ).animate(delay: (20 * index).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GradientButton(
          text: "Done Adding",
          onPressed: () => context.go('/dashboard'),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 1),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final SocialPlatform platform;
  final VoidCallback onTap;

  const _PlatformTile({required this.platform, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: platform.color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: platform.color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: platform.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                platform.icon,
                color: platform.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              platform.displayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HandleEntrySheet extends StatefulWidget {
  final SocialPlatform platform;
  final Function(String) onAdd;

  const _HandleEntrySheet({required this.platform, required this.onAdd});

  @override
  State<_HandleEntrySheet> createState() => _HandleEntrySheetState();
}

class _HandleEntrySheetState extends State<_HandleEntrySheet> {
  final TextEditingController _controller = TextEditingController();
  String _previewUrl = "";

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.platform.constructUrl("");
  }

  void _updatePreview(String val) {
    setState(() {
      _previewUrl = widget.platform.constructUrl(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 32,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.platform.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.platform.icon, color: widget.platform.color),
              ),
              const SizedBox(width: 16),
              Text(
                "Add ${widget.platform.displayName}",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomInput(
            controller: _controller,
            hintText: widget.platform.handleHint,
            label: "Enter ${widget.platform.handleHint}",
            prefixIcon: Icons.alternate_email_rounded,
            onChanged: _updatePreview,
          ),
          const SizedBox(height: 16),
          if (_controller.text.isNotEmpty) 
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _previewUrl,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 32),
          GradientButton(
            text: "Add to Profile",
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onAdd(_controller.text.trim());
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
