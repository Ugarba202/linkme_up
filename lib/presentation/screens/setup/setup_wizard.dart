import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_input.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/entities/social_link_entity.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  final int initialStep;
  const SetupWizardScreen({super.key, this.initialStep = 0});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  late int _currentStep; // 0: Username, 1: Profile, 2: Socials

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _profileImageBytes;
  File? _profileImageFile;
  String? _usernameError;
  String? _profileError;
  bool _isGenerating = false;
  bool _isCheckingUsername = false;
  bool? _isUsernameValid;
  Timer? _debounce;

  // Track connected socials: { 'platform': 'Instagram', 'username': '...', 'icon': ..., 'color': ... }
  final List<Map<String, dynamic>> _connectedSocials = [];

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (val.trim().isEmpty) {
      setState(() {
        _isUsernameValid = null;
        _isCheckingUsername = false;
        _usernameError = null;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
      _isUsernameValid = null;
    });

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final isAvailable = await ref.read(userRepositoryProvider).isUsernameAvailable(val.trim());
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameValid = isAvailable;
            if (!isAvailable) {
              _usernameError = 'username is already taken';
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
          });
        }
      }
    });
  }

  Map<String, String>? _detectPlatformFromUrl(String input) {
    final url = input.toLowerCase().trim();
    if (url.isEmpty) return null;

    // List of common patterns
    if (url.contains('instagram.com/')) {
      final handle = url.split('instagram.com/').last.split('?').first.replaceAll('/', '');
      return {'platform': 'Instagram', 'handle': handle};
    }
    if (url.contains('tiktok.com/@')) {
      final handle = url.split('tiktok.com/@').last.split('?').first.replaceAll('/', '');
      return {'platform': 'TikTok', 'handle': handle};
    }
    if (url.contains('twitter.com/') || url.contains('x.com/')) {
      final handle = url.split('/').last.split('?').first;
      return {'platform': 'Twitter / X', 'handle': handle};
    }
    if (url.contains('youtube.com/@') || url.contains('youtube.com/c/')) {
      final handle = url.split('/').last.split('?').first;
      return {'platform': 'YouTube', 'handle': handle};
    }
    if (url.contains('linkedin.com/in/')) {
      final handle = url.split('linkedin.com/in/').last.split('?').first.replaceAll('/', '');
      return {'platform': 'LinkedIn', 'handle': handle};
    }
    return null;
  }

  bool _validateCurrentStep() {
    setState(() {
      _usernameError = null;
      _profileError = null;
    });

    if (_currentStep == 0) {
      if (_usernameController.text.trim().isEmpty) {
        setState(() => _usernameError = 'username is required');
        return false;
      }
      if (_isUsernameValid == false) {
        return false;
      }
    } else if (_currentStep == 1) {
      if (_nameController.text.trim().isEmpty ||
          _bioController.text.trim().isEmpty) {
        setState(() => _profileError = 'display name and bio is required');
        return false;
      }
    } else if (_currentStep == 2) {
      if (_connectedSocials.isEmpty) {
        // Optional: show a snackbar or similar if at least one social is required
        return true;
      }
    }
    return true;
  }

  Future<void> _saveStepData() async {
    final notifier = ref.read(userProvider.notifier);

    if (_currentStep == 0) {
      if (_usernameController.text.isNotEmpty) {
        await notifier.updateUsername(_usernameController.text);
      }
    } else if (_currentStep == 1) {
      if (_nameController.text.isNotEmpty) {
        await notifier.updateName(_nameController.text);
      }
      await notifier.updateBio(_bioController.text);
      if (_profileImageBytes != null) {
        await notifier.updatePhotoBytes(_profileImageBytes!);
      }
    } else if (_currentStep == 2) {
      // Clear existing to avoid duplicates in mock
      // (Simplified: in a real app we'd update specifically)
      for (final social in _connectedSocials) {
        final platform = SocialPlatform.values.firstWhere(
          (p) =>
              p.name.toLowerCase() ==
              (social['name'] as String).toLowerCase().replaceAll(' ', ''),
          orElse: () => SocialPlatform.other,
        );

        final link = SocialLinkEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          platform: platform,
          username: social['username'],
          url: platform.constructUrl(social['username']),
          createdAt: DateTime.now(),
        );
        await notifier.addSocialLink(link);
      }
      
      // Upload image to Supabase if exists
      if (_profileImageFile != null) {
        await notifier.uploadProfileImage(_profileImageFile!);
      }
    }
  }

  void _nextStep() async {
    if (!_validateCurrentStep()) return;

    await _saveStepData();
    if (!mounted) return;

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Final Step: Generation Ceremony
      setState(() => _isGenerating = true);
      
      final notifier = ref.read(userProvider.notifier);
      // Perform final save and completion
      await notifier.completeSetup();
      
      // Short delay for the premium "generation" effect
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        context.go('/home');
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.go('/auth');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _profileImageFile = File(pickedFile.path);
      });
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
          onPressed: _prevStep,
        ),
        title: const Text(
          'LinkMeUp',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _ProgressHeader(
                  currentStep: _currentStep + 2,
                ), // Mockup says Step 2 of 4 for Username
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: IndexedStack(
                      index: _currentStep,
                      children: [
                        _buildUsernameStep(),
                        _buildProfileSetupStep(),
                        _buildConnectSocialsStep(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: PrimaryButton(
                    text: _currentStep == 0
                        ? 'Next'
                        : _currentStep == 1
                        ? 'Continue to Final Step'
                        : 'Generate My QR',
                    onPressed: _nextStep,
                  ),
                ),
              ],
            ),
            if (_isGenerating) _buildGenerationOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationOverlay() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated QR Symbol
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 3),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      color: const Color(0xFF5B62F4),
                      backgroundColor: const Color(0xFF5B62F4).withValues(alpha: 0.1),
                    ),
                  ),
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 60,
                    color: const Color(0xFF5B62F4).withValues(alpha: value),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
          const Text(
            'GENERATING YOUR PASS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Color(0xFF5B62F4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Compiling your digital identity...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 48),
          // Progress Status bits
          _buildStatusBit('Analyzing social connections...', 0.3),
          _buildStatusBit('Securing your unique handle...', 0.6),
          _buildStatusBit('Finalizing premium QR pass...', 0.9),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildStatusBit(String text, double visibleAt) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 4),
      builder: (context, value, child) {
        final isVisible = value >= visibleAt;
        return AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: 300.ms,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your\nusername',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This will be your permanent link:',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const Text(
          'linkmeup.app/[username]',
          style: TextStyle(
            color: Color(0xFF5B62F4),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'USERNAME',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          controller: _usernameController,
          hintText: 'enter username',
          prefixIcon: const Icon(
            Icons.alternate_email,
            size: 18,
            color: Color(0xFF5B62F4),
          ),
          suffixIcon: _isCheckingUsername
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5B62F4)),
                  ),
                )
              : _isUsernameValid == true
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  : _isUsernameValid == false
                      ? const Icon(Icons.error_outline, color: Colors.red, size: 20)
                      : null,
          onChanged: _onUsernameChanged,
        ),
        const SizedBox(height: 8),
        if (_usernameError != null)
          Text(
            _usernameError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          )
        else if (_isUsernameValid == true)
          Text(
            '${_usernameController.text} is available!',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 48),
        _PersonalBrandBanner(),
      ],
    );
  }

  Widget _buildProfileSetupStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create your profile',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalize how others see your digital identity when they scan your code.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              if (_profileError != null) ...[
                Text(
                  _profileError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null,
                    child: _profileImageBytes == null
                        ? Icon(
                            Icons.person_outline,
                            size: 40,
                            color: Colors.grey.shade400,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B62F4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'ADD PROFILE PICTURE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B62F4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'DISPLAY NAME',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          controller: _nameController,
          hintText: 'enter your fullname',
          onChanged: (val) {
            setState(() {
              _profileError = null;
            });
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'BIO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              '${_bioController.text.length}/100',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomInputField(
          controller: _bioController,
          hintText: 'Bio',
          maxLines: 3,
          onChanged: (val) {
            setState(() {
              _profileError = null;
            });
          },
        ),
        const SizedBox(height: 40),
        _LivePreviewCard(
          name: _nameController.text.isEmpty
              ? 'Your Name'
              : _nameController.text,
          bio: _bioController.text.isEmpty
              ? 'Your bio will appear here'
              : _bioController.text,
          imageBytes: _profileImageBytes,
          connectedSocials: _connectedSocials,
        ),
      ],
    );
  }

  void _showAddSocialBottomSheet(
    Map<String, dynamic> platform, {
    bool isCustom = false,
  }) {
    final TextEditingController linkController = TextEditingController(
      text: _connectedSocials.firstWhere(
        (element) => element['name'] == platform['name'],
        orElse: () => {'username': ''},
      )['username'],
    );
    final TextEditingController customNameController = TextEditingController(
      text: isCustom ? platform['name'] : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (platform['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    platform['icon'] as IconData,
                    color: platform['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  isCustom ? 'Add Custom Link' : 'Connect ${platform['name']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (isCustom) ...[
              const Text(
                'PLATFORM NAME',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              CustomInputField(
                controller: customNameController,
                hintText: 'e.g. Portfolio, Blog',
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'USERNAME OR LINK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: linkController,
              hintText: isCustom ? 'https://...' : 'your_username',
              prefixIcon: Icon(
                isCustom ? Icons.link : Icons.alternate_email,
                size: 18,
                color: const Color(0xFF5B62F4),
              ),
              onChanged: (val) {
                if (!isCustom) {
                  final detected = _detectPlatformFromUrl(val);
                  if (detected != null && detected['platform'] == platform['name']) {
                    linkController.text = detected['handle']!;
                  }
                }
              },
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Save Connection',
              onPressed: () {
                if (linkController.text.isNotEmpty) {
                  setState(() {
                    // Remove if already exists
                    _connectedSocials.removeWhere(
                      (element) => element['name'] == platform['name'],
                    );

                    _connectedSocials.add({
                      'name': isCustom
                          ? customNameController.text
                          : platform['name'],
                      'username': linkController.text,
                      'icon': platform['icon'],
                      'color': platform['color'],
                      'isCustom': isCustom,
                    });
                  });
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectSocialsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect your\naccounts',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add at least one to generate your QR.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        ..._buildMockSocialList(),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => _showAddSocialBottomSheet({
              'name': 'Custom',
              'icon': Icons.link,
              'color': const Color(0xFF5B62F4),
            }, isCustom: true),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Add Custom Link',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5B62F4),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMockSocialList() {
    final platforms = [
      {
        'name': 'Instagram',
        'icon': FontAwesomeIcons.instagram,
        'color': Colors.pink,
      },
      {
        'name': 'TikTok',
        'icon': FontAwesomeIcons.tiktok,
        'color': Colors.black,
      },
      {
        'name': 'Twitter / X',
        'icon': FontAwesomeIcons.xTwitter,
        'color': Colors.black,
      },
      {
        'name': 'YouTube',
        'icon': FontAwesomeIcons.youtube,
        'color': Colors.red,
      },
      {
        'name': 'LinkedIn',
        'icon': FontAwesomeIcons.linkedin,
        'color': Colors.blue,
      },
      {
        'name': 'Snapchat',
        'icon': FontAwesomeIcons.snapchat,
        'color': Colors.yellow.shade700,
      },
    ];

    return platforms.map((p) {
      final connected = _connectedSocials.firstWhere(
        (element) => element['name'] == p['name'],
        orElse: () => {},
      );
      final isConnected = connected.isNotEmpty;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected
                ? const Color(0xFF5B62F4).withValues(alpha: 0.2)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (p['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              p['icon'] as IconData,
              color: p['color'] as Color,
              size: 20,
            ),
          ),
          title: Text(
            p['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isConnected ? '@${connected['username']}' : 'NOT CONNECTED',
            style: TextStyle(
              fontSize: 10,
              color: isConnected ? const Color(0xFF5B62F4) : Colors.grey,
              fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: Icon(
            isConnected ? Icons.check_circle : Icons.add_circle_outline,
            color: isConnected ? Colors.green : Colors.grey.shade400,
          ),
          onTap: () => _showAddSocialBottomSheet(p),
        ),
      );
    }).toList();
  }
}

class _ProgressHeader extends StatelessWidget {
  final int currentStep;
  const _ProgressHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    double progress = currentStep / 4;
    String status = currentStep == 4
        ? 'ALMOST THERE'
        : '${(progress * 100).toInt()}% COMPLETE';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP $currentStep OF 4',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B62F4),
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF5B62F4),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalBrandBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Personal Brand',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'A unique username makes your QR codes more memorable and professional for your audience.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.qr_code_2, size: 60, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  final String name;
  final String bio;
  final Uint8List? imageBytes;
  final List<Map<String, dynamic>> connectedSocials;

  const _LivePreviewCard({
    required this.name,
    required this.bio,
    this.imageBytes,
    required this.connectedSocials,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'LIVE PREVIEW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              backgroundColor: Colors.black,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: imageBytes != null
                    ? MemoryImage(imageBytes!)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: connectedSocials.isEmpty
                          ? [
                              _SmallCircle(color: Colors.pink, size: 8),
                              const SizedBox(width: 4),
                              _SmallCircle(color: Colors.black, size: 8),
                              const SizedBox(width: 4),
                              _SmallCircle(color: Colors.blue, size: 8),
                              const SizedBox(width: 4),
                              _SmallCircle(color: Colors.purple, size: 8),
                            ]
                          : connectedSocials
                                .take(4)
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Icon(
                                      s['icon'] as IconData,
                                      color: s['color'] as Color,
                                      size: 10,
                                    ),
                                  ),
                                )
                                .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _SmallCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
