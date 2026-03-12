import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
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

class _AddSocialsScreenState extends ConsumerState<AddSocialsScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isProcessing = false;
  SocialPlatform? _activeSyncPlatform;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _activeSyncPlatform != null) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;

    final text = data!.text!.trim();
    final platform = _activeSyncPlatform;
    if (platform == null) return;

    // Check if the link matches the active platform
    // We can use the baseUrl for simple validation
    if (platform.baseUrl != null && text.contains(platform.baseUrl!)) {
      _handleAddHandle(platform, text);
      setState(() => _activeSyncPlatform = null);
    }
  }

  List<SocialPlatform> get _filteredPlatforms {
    final allPlatforms = SocialPlatform.values.toList();
    if (_searchQuery.isEmpty) return allPlatforms;
    return allPlatforms
        .where(
          (p) =>
              p.displayName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Future<void> _syncPlatform(SocialPlatform platform) async {
    final url = platform.baseUrl != null ? Uri.parse(platform.baseUrl!) : null;

    if (url != null) {
      setState(() => _activeSyncPlatform = platform);

      // Try to launch the app
      final success = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        // Fallback to manual entry if app can't launch
        _showHandleEntry(platform);
        setState(() => _activeSyncPlatform = null);
      }
    } else {
      _showHandleEntry(platform);
    }
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
        username: handle.startsWith('http') ? handle.split('/').last : handle,
        url: url,
        createdAt: DateTime.now(),
      );

      await ref.read(userProvider.notifier).addSocialLink(link);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text("Smart-Synced ${platform.displayName}!"),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Magic Sync"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  "Tap an app to Magic Sync",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "We'll open the app, you copy your link, and we'll handle the rest!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                CustomInput(
                  controller: _searchController,
                  hintText: "Search apps...",
                  label: "",
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                final isSyncing = _activeSyncPlatform == platform;

                return _PlatformTile(
                      platform: platform,
                      isSyncing: isSyncing,
                      onTap: () => _syncPlatform(platform),
                    )
                    .animate(delay: (20 * index).ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.9, 0.9));
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GradientButton(
          text: "Done",
          onPressed: () => context.go('/dashboard'),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 1),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final SocialPlatform platform;
  final bool isSyncing;
  final VoidCallback onTap;

  const _PlatformTile({
    required this.platform,
    required this.onTap,
    this.isSyncing = false,
  });

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
            color: isSyncing
                ? platform.color
                : platform.color.withValues(alpha: 0.2),
            width: isSyncing ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: platform.color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: platform.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: isSyncing
                        ? SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                platform.color,
                              ),
                            ),
                          )
                        : Icon(platform.icon, color: platform.color, size: 28),
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
            if (isSyncing)
              Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: platform.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "SYNC",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1.5.seconds),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                  const Icon(
                    Icons.link_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _previewUrl,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
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
